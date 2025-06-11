import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const ReservationDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${booking['sport']} Court', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Facility: ${booking['court'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Date: ${DateFormat('d MMM yyyy, HH:mm').format((booking['date'] as Timestamp).toDate())}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Status: ${booking['status']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            // Add more fields here if needed
          ],
        ),
      ),
    );
  }
}
