import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reservation_details.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reservations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReservationList(statusFilter: ['confirmed', 'rescheduled']),
            _ReservationList(statusFilter: ['checked in', 'cancelled', 'completed']),
          ],
        ),
      ),
    );
  }
}

DateTime _parseDate(dynamic dateField) {
  if (dateField is Timestamp) {
    return dateField.toDate();
  } else if (dateField is String) {
    return DateTime.tryParse(dateField) ?? DateTime.now();
  } else {
    return DateTime.now();
  }
}

class _ReservationList extends StatelessWidget {
  final List<String> statusFilter;

  const _ReservationList({required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('email', isEqualTo: userEmail) // Get bookings for the logged-in user's email
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] ?? 'confirmed').toString().toLowerCase();
          return statusFilter.contains(status);
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('No reservations'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final sport = (data['sport'] ?? 'Unknown').toString();
            final timeSlot = (data['timeSlot'] ?? '-').toString();
            final status = (data['status'] ?? 'confirmed').toString();
            final pax = data['pax'] is int ? data['pax'] : int.tryParse(data['pax']?.toString() ?? '') ?? 0;
            final date = data['date'] is Timestamp
                ? _parseDate(data['date'])
                : DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now();

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReservationDetailsPage(
                      booking: {
                        ...data,
                        'id': doc.id,
                      },
                    ),
                  ),
                );
              },
              child: _ReservationCard(
                bookingId: doc.id,
                sport: sport,
                date: date,
                timeSlot: timeSlot,
                status: status,
                pax: pax,
              ),
            );
          },
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final String bookingId;
  final String sport;
  final DateTime date;
  final String timeSlot;
  final String status;
  final int pax;

  const _ReservationCard({
    required this.bookingId,
    required this.sport,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.pax,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'checked in':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Future<void> _checkIn(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Check In'),
        content: const Text('Are you sure you want to check in?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'checked in'});  // Update status to checked in
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked in successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(sport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status), width: 1),
                  ),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(DateFormat('EEEE, MMMM d, y').format(date)),
            Text('Time: $timeSlot'),
            Text('Pax: $pax'),
            const SizedBox(height: 8),
            if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'rescheduled')
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('Check In'),
                onPressed: () => _checkIn(context),
              ),
          ],
        ),
      ),
    );
  }
}
