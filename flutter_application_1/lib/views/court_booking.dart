import 'package:flutter/material.dart';
import 'package:flutter_application_1/viewmodels/booking_viewmodel.dart';

class SportsCourtBooking extends StatefulWidget {
  const SportsCourtBooking({super.key});

  @override
  State<SportsCourtBooking> createState() => _SportsCourtBookingState();
}

class _SportsCourtBookingState extends State<SportsCourtBooking> {
  final SportsCourtBookingViewModel viewModel = SportsCourtBookingViewModel();
  bool _isBooking = false;

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Sport:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              _buildSportSelector(),
              const SizedBox(height: 20),
              ValueListenableBuilder<String>(
                valueListenable: viewModel.selectedSport,
                builder: (context, sport, _) => Text(
                  '$sport Court',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Select a date:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              _buildCalendar(),
              const SizedBox(height: 20),
              const Text('Select a period:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              _buildTimeSlots(),
              const SizedBox(height: 20),
              const Text('Select Court:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              _buildCourtSelector(),
              const SizedBox(height: 20),
              const Text('PAX:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              _buildPaxSelector(),
              const SizedBox(height: 30),
              Center(
                child: ValueListenableBuilder<String?>(
                  valueListenable: viewModel.selectedTimeSlot,
                  builder: (context, timeSlot, _) {
                    return ElevatedButton(
                      onPressed: (timeSlot == null || _isBooking)
                          ? null
                          : () => _bookCourt(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: _isBooking
                          ? const CircularProgressIndicator()
                          : const Text('Book', style: TextStyle(fontSize: 18)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportSelector() {
    return ValueListenableBuilder<String>(
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
            viewModel.selectedTimeSlot.value = null;
            viewModel.selectedCourt.value = null;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: viewModel.selectedDate,
      builder: (context, selectedDate, _) {
        DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
        int weekday = firstDayOfMonth.weekday;
        int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

        List<Widget> dayWidgets = [];
        for (int i = 1; i < weekday; i++) {
          dayWidgets.add(const SizedBox(width: 30, height: 30));
        }

        for (int day = 1; day <= daysInMonth; day++) {
          DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, day);
          bool isSelected = viewModel.isSameDay(currentDay, selectedDate);
          dayWidgets.add(
            GestureDetector(
              onTap: () => viewModel.selectedDate.value = currentDay,
              child: Container(
                width: 30,
                height: 30,
                decoration: isSelected
                    ? BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      )
                    : null,
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${viewModel.getMonthName(selectedDate.month)} ${selectedDate.year}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            viewModel.selectedDate.value =
                                DateTime(selectedDate.year, selectedDate.month - 1, 1);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            viewModel.selectedDate.value =
                                DateTime(selectedDate.year, selectedDate.month + 1, 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildWeekDaysRow(),
                Wrap(spacing: 8, runSpacing: 8, children: dayWidgets),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekDaysRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
          .map((day) => Text(day, style: const TextStyle(fontWeight: FontWeight.bold)))
          .toList(),
    );
  }

  Widget _buildTimeSlots() {
    return ValueListenableBuilder<String>(
      valueListenable: viewModel.selectedSport,
      builder: (context, sport, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: viewModel.selectedTimeSlot,
          builder: (context, selectedSlot, _) {
            List<String> slots = viewModel.getTimeSlotsForSelectedSport();
            return Column(
              children: slots.map((slot) {
                return RadioListTile<String>(
                  title: Text(slot),
                  value: slot,
                  groupValue: selectedSlot,
                  onChanged: (value) {
                    viewModel.selectedTimeSlot.value = value;
                    viewModel.selectedCourt.value = null;
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildCourtSelector() {
    return ValueListenableBuilder<String?>(
      valueListenable: viewModel.selectedTimeSlot,
      builder: (context, timeSlot, _) {
        if (timeSlot == null) {
          return const Text("Please select a time slot first.");
        }

        return FutureBuilder<Map<int, bool>>(
          future: viewModel.getCourtAvailabilityMap(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Text("Unable to load court availability.");
            }

            final availabilityMap = snapshot.data!;
            return GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: availabilityMap.entries.map((entry) {
                final court = entry.key;
                final isAvailable = entry.value;
                final isSelected = viewModel.selectedCourt.value == court;

                return GestureDetector(
                  onTap: isAvailable
                      ? () => setState(() {
                            viewModel.selectedCourt.value = court;
                          })
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green
                          : (isAvailable ? Colors.white : Colors.grey.shade300),
                      border: Border.all(
                        color: isAvailable ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Court $court',
                      style: TextStyle(
                        color: isAvailable ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildPaxSelector() {
    return ValueListenableBuilder<int>(
      valueListenable: viewModel.paxCount,
      builder: (context, count, _) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$count', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: count > 1 ? () => viewModel.paxCount.value-- : null,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => viewModel.paxCount.value++,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _bookCourt(BuildContext context) async {
    setState(() => _isBooking = true);
    try {
      await viewModel.submitBooking();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Successful'),
          content: Text(viewModel.bookingConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }
}