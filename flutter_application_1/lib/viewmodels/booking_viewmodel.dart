import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SportsCourtBookingViewModel {
  final ValueNotifier<String> selectedSport = ValueNotifier<String>('Badminton');
  final ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<String?> selectedTimeSlot = ValueNotifier<String?>(null);
  final ValueNotifier<int?> selectedCourt = ValueNotifier<int?>(null);
  final ValueNotifier<int> paxCount = ValueNotifier<int>(1);

  final List<String> sports = ['Badminton', 'Ping Pong', 'Volleyball', 'Squash'];
  String bookingConfirmationMessage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> getTimeSlotsForSelectedSport() {
    switch (selectedSport.value) {
      case 'Badminton':
        return ['8:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00', '16:00 - 18:00'];
      case 'Ping Pong':
        return ['9:00 - 11:00', '13:00 - 15:00'];
      case 'Volleyball':
        return ['10:00 - 12:00', '14:00 - 16:00'];
      case 'Squash':
        return ['8:00 - 9:00', '9:00 - 10:00', '16:00 - 17:00'];
      default:
        return [];
    }
  }

  List<int> getCourtsForSelectedSport() {
    switch (selectedSport.value) {
      case 'Badminton':
        return List.generate(11, (index) => index + 1);
      case 'Ping Pong':
        return List.generate(5, (index) => index + 1);
      case 'Volleyball':
        return List.generate(4, (index) => index + 1);
      case 'Squash':
        return List.generate(3, (index) => index + 1);
      default:
        return [];
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<Map<int, bool>> getCourtAvailabilityMap() async {
    if (selectedTimeSlot.value == null) return {};

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    final snapshot = await _firestore.collection('bookings')
        .where('sport', isEqualTo: selectedSport.value)
        .where('date', isEqualTo: formattedDate)
        .where('timeSlot', isEqualTo: selectedTimeSlot.value)
        .get();

    Set<int> bookedCourts = snapshot.docs
        .map((doc) => doc['court'] as int)
        .toSet();

    List<int> allCourts = getCourtsForSelectedSport();

    return {for (var court in allCourts) court: !bookedCourts.contains(court)};
  }

  Future<void> submitBooking() async {
    if (selectedSport.value.isEmpty ||
        selectedTimeSlot.value == null ||
        selectedCourt.value == null) {
      throw Exception("Please complete all booking fields.");
    }

    bool available = await isCourtAvailable();

    if (!available) {
      throw Exception("Selected court is already booked at this time.");
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    await _firestore.collection('bookings').add({
      'sport': selectedSport.value,
      'date': formattedDate,
      'timeSlot': selectedTimeSlot.value,
      'court': selectedCourt.value,
      'pax': paxCount.value,
      'timestamp': FieldValue.serverTimestamp(),
    });

    bookingConfirmationMessage =
        'Court ${selectedCourt.value} booked on $formattedDate for ${selectedTimeSlot.value}.';
  }

  Future<bool> isCourtAvailable() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    final snapshot = await _firestore.collection('bookings')
        .where('sport', isEqualTo: selectedSport.value)
        .where('date', isEqualTo: formattedDate)
        .where('timeSlot', isEqualTo: selectedTimeSlot.value)
        .where('court', isEqualTo: selectedCourt.value)
        .get();

    return snapshot.docs.isEmpty;
  }

  String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(0, month));
  }

  void dispose() {
    selectedSport.dispose();
    selectedDate.dispose();
    selectedTimeSlot.dispose();
    selectedCourt.dispose();
    paxCount.dispose();
  }
}