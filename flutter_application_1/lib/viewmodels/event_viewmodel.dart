import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventBookingViewModel {
  final ValueNotifier<String> selectedSport =
      ValueNotifier<String>('Badminton');
  final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now().add(const Duration(days: 1)));
  final ValueNotifier<List<String>> selectedTimeSlots =
      ValueNotifier<List<String>>([]);
  final ValueNotifier<List<int>> selectedCourts = ValueNotifier<List<int>>([]);
  final ValueNotifier<int> maxParticipants = ValueNotifier<int>(10);

  final List<String> sports = [
    'Badminton',
    'Ping Pong',
    'Volleyball',
    'Squash'
  ];
  String bookingConfirmationMessage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  void initialize() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User must be logged in to book an event.");
    }
  }

  List<String> getTimeSlotsForSelectedSport() {
    switch (selectedSport.value) {
      case 'Badminton':
        return [
          '8:00 - 10:00',
          '10:00 - 12:00',
          '14:00 - 16:00',
          '16:00 - 18:00'
        ];
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

  // Check availability for all selected courts and time slots
  Future<bool> areCourtsAvailable() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    for (final court in selectedCourts.value) {
      for (final slot in selectedTimeSlots.value) {
        final snapshot = await _firestore
            .collection('event')
            .where('sport', isEqualTo: selectedSport.value)
            .where('date', isEqualTo: formattedDate)
            .where('timeSlot', isEqualTo: slot)
            .where('courts', arrayContains: court)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  // Submit an event booking to Firestore
  Future<void> submitEventBooking({
    required String eventName,
    required String description,
    required int maxPax,
    required double registrationFee,
  }) async {
    if (selectedSport.value.isEmpty ||
        selectedTimeSlots.value.isEmpty ||
        selectedCourts.value.isEmpty) {
      throw Exception("Please complete all event booking fields.");
    }

    if (currentUser == null) {
      throw Exception("User must be logged in to create an event.");
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    // Prepare courts info for Firestore
    List<Map<String, dynamic>> courtsInfo = [];
    for (final court in selectedCourts.value) {
      for (final slot in selectedTimeSlots.value) {
        courtsInfo.add({
          'court': court,
          'date': formattedDate,
          'timeSlot': slot,
        });
      }
    }

    // Add event to Firestore
    await _firestore.collection('event').add({
      'organizerId': currentUser!.uid,
      'organizerEmail': currentUser!.email,
      'eventName': eventName,
      'description': description,
      'sport': selectedSport.value,
      'date': formattedDate,
      'timeSlots': selectedTimeSlots.value,
      'courts': courtsInfo,
      'maxParticipants': maxPax,
      'registrationFee': registrationFee,
      'status': 'Draft',
      'timestamp': FieldValue.serverTimestamp(),
      'registeredParticipants': [],
    });

    bookingConfirmationMessage =
        'Event "$eventName" created with ${selectedCourts.value.length} courts on $formattedDate.';
  }

  void dispose() {
    selectedSport.dispose();
    selectedDate.dispose();
    selectedTimeSlots.dispose();
    selectedCourts.dispose();
    maxParticipants.dispose();
  }
}
