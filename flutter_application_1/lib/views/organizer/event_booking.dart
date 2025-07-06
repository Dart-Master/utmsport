import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/event_viewmodel.dart';

class EventBookingPage extends StatefulWidget {
  final Map<String, dynamic>? event;
  final bool isEdit;

  const EventBookingPage({
    super.key,
    this.event,
    this.isEdit = false,
  });

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

    // Pre-fill form fields if editing
    if (widget.isEdit && widget.event != null) {
      final event = widget.event!;
      _eventNameController.text = event['eventName'] ?? '';
      _descriptionController.text = event['description'] ?? '';
      _maxParticipantsController.text =
          (event['maxParticipants'] ?? '').toString();
      _registrationFeeController.text =
          (event['registrationFee'] ?? '').toString();

      // Set selected sport, date, time slots, courts
      viewModel.selectedSport.value = event['sport'] ?? 'Badminton';
      if (event['date'] != null) {
        if (event['date'] is Timestamp) {
          viewModel.selectedDate.value = (event['date'] as Timestamp).toDate();
        } else if (event['date'] is String) {
          viewModel.selectedDate.value =
              DateTime.tryParse(event['date']) ?? DateTime.now();
        }
      }
      if (event['timeSlots'] != null) {
        viewModel.selectedTimeSlots.value =
            List<String>.from(event['timeSlots']);
      }
      if (event['courts'] != null) {
        // If courts is a list of maps with a 'court' field
        try {
          viewModel.selectedCourts.value = List<int>.from(
            (event['courts'] as List)
                .map((c) =>
                    c is Map && c['court'] != null ? c['court'] as int : null)
                .where((c) => c != null),
          );
        } catch (_) {
          // fallback if courts is just a list of ints
          viewModel.selectedCourts.value = List<int>.from(event['courts']);
        }
      }
    }
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

      if (widget.isEdit &&
          widget.event != null &&
          widget.event!['id'] != null) {
        // EDIT MODE: Update existing event
        await FirebaseFirestore.instance
            .collection('event')
            .doc(widget.event!['id'])
            .update({
          'eventName': _eventNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'sport': viewModel.selectedSport.value,
          'date': DateFormat('yyyy-MM-dd').format(viewModel.selectedDate.value),
          'timeSlots': viewModel.selectedTimeSlots.value,
          'courts': viewModel.selectedCourts.value
              .map((court) => {
                    'court': court,
                    'date': DateFormat('yyyy-MM-dd')
                        .format(viewModel.selectedDate.value),
                    'timeSlot': viewModel.selectedTimeSlots.value.join(', '),
                  })
              .toList(),
          'maxParticipants': int.parse(_maxParticipantsController.text),
          'registrationFee':
              double.tryParse(_registrationFeeController.text) ?? 0,
          // add other fields as needed
        });
        if (!mounted) return;
        Navigator.pop(context, {
          ...widget.event!,
          'eventName': _eventNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'sport': viewModel.selectedSport.value,
          'date': DateFormat('yyyy-MM-dd').format(viewModel.selectedDate.value),
          'timeSlots': viewModel.selectedTimeSlots.value,
          'courts': viewModel.selectedCourts.value,
          'maxParticipants': int.parse(_maxParticipantsController.text),
          'registrationFee':
              double.tryParse(_registrationFeeController.text) ?? 0,
        });
      } else {
        // CREATE MODE: Create new event
        await viewModel.submitEventBooking(
          eventName: _eventNameController.text.trim(),
          description: _descriptionController.text.trim(),
          maxPax: int.parse(_maxParticipantsController.text),
          registrationFee:
              double.tryParse(_registrationFeeController.text) ?? 0,
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
      }
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Event' : 'Create Event',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userEmail != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Color(0xFF870C14)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            userEmail!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                _MinimalSection(
                  label: 'Event Name *',
                  child: TextFormField(
                    controller: _eventNameController,
                    decoration: _minimalInputDecoration('Event Name'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter event name'
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                _MinimalSection(
                  label: 'Event Description',
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _minimalInputDecoration('Event Description'),
                  ),
                ),
                const SizedBox(height: 14),
                _MinimalSection(
                  label: 'Select Sport',
                  child: ValueListenableBuilder<String>(
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
                        decoration: _minimalInputDecoration('Sport'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _MinimalSection(
                  label: 'Event Date *',
                  child: ValueListenableBuilder<DateTime>(
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
                          decoration: _minimalInputDecoration('Event Date'),
                          child: Text(
                              DateFormat('d MMM yyyy').format(selectedDate)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _MinimalSection(
                  label: 'Time Slots',
                  child: ValueListenableBuilder<String>(
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
                                selectedColor:
                                    const Color(0xFF870C14).withOpacity(0.12),
                                checkmarkColor: const Color(0xFF870C14),
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
                ),
                const SizedBox(height: 14),
                _MinimalSection(
                  label: 'Courts',
                  child: ValueListenableBuilder<String>(
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
                                selectedColor:
                                    const Color(0xFF870C14).withOpacity(0.12),
                                checkmarkColor: const Color(0xFF870C14),
                                onSelected: (selected) {
                                  final updated =
                                      List<int>.from(selectedCourts);
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
                ),
                const SizedBox(height: 14),
                _MinimalSection(
                  label: 'Maximum Participants *',
                  child: TextFormField(
                    controller: _maxParticipantsController,
                    keyboardType: TextInputType.number,
                    decoration: _minimalInputDecoration('Maximum Participants'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter maximum participants';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _MinimalSection(
                  label: 'Registration Fee (RM)',
                  child: TextFormField(
                    controller: _registrationFeeController,
                    keyboardType: TextInputType.number,
                    decoration: _minimalInputDecoration('0.00'),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isBooking ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF870C14),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isBooking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.isEdit ? 'Update Event' : 'Create Event',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

// Minimal section card for each field group
class _MinimalSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _MinimalSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF870C14),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// Minimal input decoration
InputDecoration _minimalInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF870C14), width: 1.5),
    ),
  );
}
