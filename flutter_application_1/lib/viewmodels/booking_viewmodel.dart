import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SportsCourtBookingViewModel {
  // State management
  final ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<String?> selectedTimeSlot = ValueNotifier(null);
  final ValueNotifier<int> paxCount = ValueNotifier(1);
  final ValueNotifier<String> selectedSport = ValueNotifier('Badminton');
  final ValueNotifier<User?> currentUser = ValueNotifier(null);

  // Firebase services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Available sports
  final List<String> sports = ['Badminton', 'Ping Pong', 'Volleyball', 'Squash'];

  SportsCourtBookingViewModel() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
    });
  }

  // Authentication methods
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Authentication failed';
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Registration failed';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Booking methods
  Future<void> submitBooking() async {
    if (currentUser.value == null) {
      throw 'You must be logged in to book a court';
    }

    if (selectedTimeSlot.value == null) {
      throw 'Please select a time slot';
    }

    final bookingData = {
      'userId': currentUser.value!.uid,
      'userEmail': currentUser.value!.email,
      'sport': selectedSport.value,
      'date': Timestamp.fromDate(selectedDate.value),
      'timeSlot': selectedTimeSlot.value,
      'pax': paxCount.value,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'confirmed',
    };

    try {
      final docRef = await _firestore.collection('bookings').add(bookingData);
      debugPrint('Booking created with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('Error creating booking: $e');
      rethrow;
    }
  }

  // Fetch user bookings
  Stream<QuerySnapshot> getUserBookings() {
    if (currentUser.value == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: currentUser.value!.uid)
        .orderBy('date', descending: false)
        .snapshots();
  }

  // Helper methods
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  List<String> getTimeSlotsForSelectedSport() {
    switch (selectedSport.value) {
      case 'Badminton':
        return ['9:00 - 11:00', '11:00 - 13:00', '14:00 - 16:00', '16:00 - 18:00'];
      case 'Ping Pong':
        return ['10:00 - 12:00', '12:00 - 14:00', '15:00 - 17:00'];
      case 'Volleyball':
        return ['13:00 - 15:00', '16:00 - 18:00', '19:00 - 21:00'];
      case 'Squash':
        return ['8:00 - 10:00', '11:00 - 13:00', '15:00 - 17:00'];
      default:
        return ['9:00 - 11:00', '11:00 - 13:00'];
    }
  }

  String get bookingConfirmationMessage {
    return 'You have booked the ${selectedSport.value} court on '
        '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year} '
        'from ${selectedTimeSlot.value} for ${paxCount.value} people.';
  }

  void dispose() {
    selectedDate.dispose();
    selectedTimeSlot.dispose();
    paxCount.dispose();
    selectedSport.dispose();
    currentUser.dispose();
  }
}