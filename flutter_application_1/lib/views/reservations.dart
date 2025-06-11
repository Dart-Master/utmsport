import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reservations yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data!.docs[index];
              final data = booking.data() as Map<String, dynamic>;
              return _ReservationCard(
                bookingId: booking.id,
                sport: data['sport'],
                date: (data['date'] as Timestamp).toDate(),
                timeSlot: data['timeSlot'],
                status: data['status'] ?? 'confirmed',
                pax: data['pax'],
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatefulWidget {
  final String bookingId;
  final String sport;
  final DateTime date;
  final String timeSlot;
  final String status;
  final int pax;
  final DateTime createdAt;

  const _ReservationCard({
    required this.bookingId,
    required this.sport,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.pax,
    required this.createdAt,
  });

  @override
  State<_ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<_ReservationCard> {
  bool _expanded = false;

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

  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'status': newStatus});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
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
                Text(
                  widget.sport,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(widget.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(widget.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, y').format(widget.date),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${widget.timeSlot}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Pax: ${widget.pax}',
              style: const TextStyle(fontSize: 16),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                'Booking ID: ${widget.bookingId}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Booked on: ${DateFormat('MMM d, y - h:mm a').format(widget.createdAt)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (widget.status == 'confirmed')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus('checked in'),
                        child: const Text('Check In'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus('cancelled'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Text(
                  _expanded ? 'Show Less' : 'Show More',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}