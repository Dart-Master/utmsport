import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/event_viewmodel.dart';

class EventBookingPage extends StatefulWidget {
  const EventBookingPage({super.key});

  @override
  State<EventBookingPage> createState() => _EventBookingPageState();
}

class _EventBookingPageState extends State<EventBookingPage> {
  final EventBookingViewModel viewModel = EventBookingViewModel();
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _registrationFeeController = TextEditingController();
  bool _isBooking = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    viewModel.initialize();
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _registrationFeeController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() ||
        viewModel.selectedCourts.value.isEmpty ||
        viewModel.selectedTimeSlots.value.isEmpty) {
      if (viewModel.selectedCourts.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one court')),
        );
      }
      if (viewModel.selectedTimeSlots.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one time slot')),
        );
      }
      return;
    }

    setState(() => _isBooking = true);
    try {
      viewModel.initialize();
      await viewModel.submitEventBooking(
        eventName: _eventNameController.text.trim(),
        description: _descriptionController.text.trim(),
        maxPax: int.parse(_maxParticipantsController.text),
        registrationFee: double.tryParse(_registrationFeeController.text) ?? 0,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Event Created'),
          content: Text(viewModel.bookingConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      // Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating event: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userEmail != null)
                  Text(
                    'Logged in as: $userEmail',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 20),

                // Event Name
                TextFormField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter event name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Event Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Sport Selection
                const Text('Select Sport:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: viewModel.selectedSport,
                  builder: (context, sport, _) {
                    return DropdownButtonFormField<String>(
                      value: sport,
                      items: viewModel.sports.map((sport) {
                        return DropdownMenuItem<String>(
                          value: sport,
                          child: Text(sport),
                        );
                      }).toList(),
                      onChanged: (value) {
                        viewModel.selectedSport.value = value!;
                        viewModel.selectedTimeSlots.value = [];
                        viewModel.selectedCourts.value = [];
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Date Selection
                const Text('Select a date:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ValueListenableBuilder<DateTime>(
                  valueListenable: viewModel.selectedDate,
                  builder: (context, selectedDate, _) {
                    return InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          viewModel.selectedDate.value = picked;
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Event Date *',
                        ),
                        child:
                            Text(DateFormat('d MMM yyyy').format(selectedDate)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Time Slots Selection (multi-select)
                const Text('Select Time Slots:',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: viewModel.selectedSport,
                  builder: (context, sport, _) {
                    final slots = viewModel.getTimeSlotsForSelectedSport();
                    return ValueListenableBuilder<List<String>>(
                      valueListenable: viewModel.selectedTimeSlots,
                      builder: (context, selectedSlots, _) {
                        return Wrap(
                          spacing: 8,
                          children: slots.map((slot) {
                            final isSelected = selectedSlots.contains(slot);
                            return FilterChip(
                              label: Text(slot),
                              selected: isSelected,
                              onSelected: (selected) {
                                final updated =
                                    List<String>.from(selectedSlots);
                                if (selected) {
                                  updated.add(slot);
                                } else {
                                  updated.remove(slot);
                                }
                                viewModel.selectedTimeSlots.value = updated;
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Court Selection (multi-select)
                const Text('Select Courts:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: viewModel.selectedSport,
                  builder: (context, sport, _) {
                    final courts = viewModel.getCourtsForSelectedSport();
                    return ValueListenableBuilder<List<int>>(
                      valueListenable: viewModel.selectedCourts,
                      builder: (context, selectedCourts, _) {
                        return Wrap(
                          spacing: 8,
                          children: courts.map((court) {
                            final isSelected = selectedCourts.contains(court);
                            return FilterChip(
                              label: Text('Court $court'),
                              selected: isSelected,
                              onSelected: (selected) {
                                final updated = List<int>.from(selectedCourts);
                                if (selected) {
                                  updated.add(court);
                                } else {
                                  updated.remove(court);
                                }
                                viewModel.selectedCourts.value = updated;
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Max Participants
                TextFormField(
                  controller: _maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Participants *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter maximum participants';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Registration Fee
                TextFormField(
                  controller: _registrationFeeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Registration Fee (RM)',
                    border: OutlineInputBorder(),
                    hintText: '0.00',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Create Event Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isBooking ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF870C14),
                      foregroundColor: Colors.white,
                    ),
                    child: _isBooking
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Create Event',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
