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
  bool _isRescheduling = false;
  String? _newTimeSlot;

  // Define available time slots for each sport
  final Map<String, List<String>> _sportTimeSlots = {
    'Badminton': ['9:00 - 11:00', '11:00 - 13:00', '14:00 - 16:00', '16:00 - 18:00'],
    'Ping Pong': ['10:00 - 12:00', '12:00 - 14:00', '15:00 - 17:00'],
    'Volleyball': ['13:00 - 15:00', '16:00 - 18:00', '19:00 - 21:00'],
    'Squash': ['8:00 - 10:00', '11:00 - 13:00', '15:00 - 17:00'],
  };

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

  Future<bool> _isTimeSlotAvailable(String timeSlot) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('bookings')
          .where('sport', isEqualTo: widget.sport)
          .where('date', isEqualTo: Timestamp.fromDate(widget.date))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['confirmed', 'checked in'])
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking availability: $e')),
      );
      return false;
    }
  }

  Future<void> _rescheduleBooking() async {
    if (_newTimeSlot == null) return;

    final isAvailable = await _isTimeSlotAvailable(_newTimeSlot!);
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This time slot is already taken')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
            'timeSlot': _newTimeSlot,
            'status': 'rescheduled',
          });

      setState(() {
        _isRescheduling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rescheduled successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reschedule: $e')),
      );
    }
  }

  void _startRescheduling() {
    setState(() {
      _isRescheduling = true;
      _newTimeSlot = widget.timeSlot;
    });
  }

  void _cancelRescheduling() {
    setState(() {
      _isRescheduling = false;
      _newTimeSlot = null;
    });
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
            if (!_isRescheduling)
              Text(
                'Time: ${widget.timeSlot}',
                style: const TextStyle(fontSize: 16),
              ),
            if (_isRescheduling) ...[
              const SizedBox(height: 8),
              const Text(
                'Select new time slot:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _newTimeSlot,
                items: _sportTimeSlots[widget.sport]?.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _newTimeSlot = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
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
              if (widget.status == 'confirmed' && !_isRescheduling)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _startRescheduling,
                        child: const Text('Reschedule'),
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
              if (_isRescheduling)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _rescheduleBooking,
                        child: const Text('Confirm Reschedule'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelRescheduling,
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
                    if (!_expanded) _isRescheduling = false;
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