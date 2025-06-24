import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> event;
  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late Map<String, dynamic> eventData;
  late String eventId;

  @override
  void initState() {
    super.initState();
    eventData = widget.event;
    eventId = eventData['id'] ?? eventData['eventId'] ?? '';
  }

  Future<void> _cancelEvent() async {
    await FirebaseFirestore.instance
        .collection('event')
        .doc(eventId)
        .update({'status': 'Cancelled'});
    setState(() {
      eventData['status'] = 'Cancelled';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['eventName'] ?? 'Unknown Event';
    final sport = eventData['sport'] ?? 'Unknown';
    final status = eventData['status'] ?? 'Draft';
    final maxParticipants = eventData['maxParticipants'] ?? 0;
    final registeredCount = eventData['registeredParticipants']?.length ?? 0;
    final eventDate = eventData['date'] is Timestamp
        ? (eventData['date'] as Timestamp).toDate()
        : DateTime.tryParse(eventData['date'] ?? '') ?? DateTime.now();

    Color statusColor;
    Color statusBgColor;
    switch (status) {
      case 'Published':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[50]!;
        break;
      case 'Cancelled':
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red[50]!;
        break;
      case 'Completed':
        statusColor = Colors.blue[800]!;
        statusBgColor = Colors.blue[50]!;
        break;
      default:
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange[50]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                eventName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Sport: $sport', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('d MMM yyyy, hh:mm a').format(eventDate),
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Participants: $registeredCount/$maxParticipants',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 24),
          // Courts Section
          const Text(
            'Courts Booked for Event',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // If courts are stored as an array in the event document
          if (eventData['courts'] != null && eventData['courts'] is List)
            ...List<Widget>.from(
              (eventData['courts'] as List).map((court) {
                final courtName = court['courtName'] ?? 'Court';
                final date = court['date'] ?? '';
                final timeSlot = court['timeSlot'] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$courtName | $date | $timeSlot',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            )
          // If courts are stored as a subcollection
          else
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('event')
                  .doc(eventId)
                  .collection('courts')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No courts booked for this event.');
                }
                final courts = snapshot.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: courts.map((courtDoc) {
                    final data = courtDoc.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${data['courtName'] ?? 'Court'} | ${data['date'] ?? ''} | ${data['timeSlot'] ?? ''}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Event'),
                onPressed: () {
                  // TODO: Implement edit event navigation
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Book More Courts'),
                onPressed: () {
                  // TODO: Implement navigation to booking page for more courts
                },
              ),
              if (status != 'Cancelled')
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _cancelEvent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}