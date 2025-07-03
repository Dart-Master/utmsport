import 'package:flutter/material.dart';
import 'package:flutter_application_1/viewmodels/booking_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SportsCourtBooking extends StatefulWidget {
  const SportsCourtBooking({super.key});

  @override
  State<SportsCourtBooking> createState() => _SportsCourtBookingState();
}

class _SportsCourtBookingState extends State<SportsCourtBooking> {
  final SportsCourtBookingViewModel viewModel = SportsCourtBookingViewModel();
  bool _isBooking = false;
  String? userEmail;

  // Theme colors
  static const Color primaryColor = Color(0xFF870C14);
  static const Color primaryLight = Color(0xFFB91C1C);
  static const Color primaryDark = Color(0xFF5F0A0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

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
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Court Reservation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info card
              if (userEmail != null) _buildUserInfoCard(),
              const SizedBox(height: 24),

              // Sport selection
              _buildSectionCard(
                title: 'Select Sport',
                child: _buildSportSelector(),
              ),
              const SizedBox(height: 20),

              // Court title
              ValueListenableBuilder<String>(
                valueListenable: viewModel.selectedSport,
                builder: (context, sport, _) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$sport Court',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date selection
              _buildSectionCard(
                title: 'Select Date',
                child: _buildCalendar(),
              ),
              const SizedBox(height: 20),

              // Time slots
              _buildSectionCard(
                title: 'Select Time',
                child: _buildTimeSlots(),
              ),
              const SizedBox(height: 20),

              // Court selection
              _buildSectionCard(
                title: 'Select Court',
                child: _buildCourtSelector(),
              ),
              const SizedBox(height: 20),

              // PAX selection
              _buildSectionCard(
                title: 'Number of Players',
                child: _buildPaxSelector(),
              ),
              const SizedBox(height: 32),

              // Book button
              Center(
                child: ValueListenableBuilder<String?>(
                  valueListenable: viewModel.selectedTimeSlot,
                  builder: (context, timeSlot, _) {
                    return Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: (timeSlot == null || _isBooking)
                            ? null
                            : LinearGradient(
                                colors: [primaryColor, primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: (timeSlot == null || _isBooking)
                            ? []
                            : [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: (timeSlot == null || _isBooking)
                            ? null
                            : () => _bookCourt(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isBooking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Book Court',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logged in as',
                  style: TextStyle(
                    fontSize: 12,
                    color: textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSportSelector() {
    return ValueListenableBuilder<String>(
      valueListenable: viewModel.selectedSport,
      builder: (context, sport, _) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
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
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: cardColor,
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
          dayWidgets.add(const SizedBox(width: 40, height: 40));
        }

        for (int day = 1; day <= daysInMonth; day++) {
          DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, day);
          bool isSelected = viewModel.isSameDay(currentDay, selectedDate);
          dayWidgets.add(
            GestureDetector(
              onTap: () => viewModel.selectedDate.value = currentDay,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : textDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${viewModel.getMonthName(selectedDate.month)} ${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: primaryColor),
                      onPressed: () {
                        viewModel.selectedDate.value =
                            DateTime(selectedDate.year, selectedDate.month - 1, 1);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: primaryColor),
                      onPressed: () {
                        viewModel.selectedDate.value =
                            DateTime(selectedDate.year, selectedDate.month + 1, 1);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeekDaysRow(),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: dayWidgets),
          ],
        );
      },
    );
  }

  Widget _buildWeekDaysRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
          .map((day) => SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textLight,
                    fontSize: 14,
                  ),
                ),
              ))
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
                bool isSelected = selectedSlot == slot;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      slot,
                      style: TextStyle(
                        color: isSelected ? primaryColor : textDark,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    value: slot,
                    groupValue: selectedSlot,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      viewModel.selectedTimeSlot.value = value;
                      viewModel.selectedCourt.value = null;
                    },
                  ),
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
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, color: textLight),
                SizedBox(width: 8),
                Text(
                  "Please select a time slot first",
                  style: TextStyle(color: textLight),
                ),
              ],
            ),
          );
        }

        return FutureBuilder<Map<int, bool>>(
          future: viewModel.getCourtAvailabilityMap(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Text("Unable to load court availability.");
            }

            final availabilityMap = snapshot.data!;
            return GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
                          ? primaryColor
                          : (isAvailable ? cardColor : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : (isAvailable ? primaryColor.withOpacity(0.3) : Colors.grey.shade400),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isAvailable ? Icons.sports_tennis : Icons.block,
                          color: isSelected
                              ? Colors.white
                              : (isAvailable ? primaryColor : Colors.grey),
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Court $court',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isAvailable ? textDark : Colors.grey),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: const Icon(Icons.remove, color: primaryColor),
                onPressed: count > 1 ? () => viewModel.paxCount.value-- : null,
              ),
            ),
            const SizedBox(width: 24),
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: primaryColor),
                onPressed: () => viewModel.paxCount.value++,
              ),
            ),
          ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'Booking Successful',
                style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            viewModel.bookingConfirmationMessage,
            style: const TextStyle(color: textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Booking Failed',
                style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            e.toString(),
            style: const TextStyle(color: textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
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