import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/profile.dart';
import 'package:flutter_application_1/views/reservations.dart';
import '../user_auth/login_page.dart';
import 'package:intl/intl.dart';
import 'event_details.dart';
import 'event_booking.dart';

class OrganizerPage extends StatefulWidget {
  const OrganizerPage({super.key});

  @override
  State<OrganizerPage> createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  String? userName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = doc['name'] ?? 'No name set';
      });
    }
  }

  Widget _buildTabButton(int index, String label) {
    final bool isSelected = selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF870C14) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF870C14) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              selectedTabIndex = index;
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            textStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
              letterSpacing: 0.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Future<void> _publishEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('event').doc(eventId).update({
      'status': 'Published',
      'publishedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully!')),
    );
  }

  Future<void> _cancelEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('event').doc(eventId).update({
      'status': 'Cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event cancelled successfully!')),
    );
  }

  Widget _buildEventCard(DocumentSnapshot event) {
    final data = event.data() as Map<String, dynamic>;
    data['id'] = event.id; // Add event ID to data

    DateTime eventDate;
    if (data['date'] is Timestamp) {
      eventDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      eventDate = DateTime.tryParse(data['date']) ?? DateTime.now();
    } else {
      eventDate = DateTime.now();
    }

    final eventName = data['eventName'] ?? 'Unknown Event';
    final sport = data['sport'] ?? 'Unknown';
    final status = data['status'] ?? 'Draft';
    final courts = data['courts'] as List<dynamic>? ?? [];
    final maxParticipants = data['maxParticipants'] ?? 0;
    final registeredCount = data['registeredParticipants']?.length ?? 0;

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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!, width: 1.2),
        // Removed boxShadow for minimalism
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  eventName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Sport: $sport',
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
          const SizedBox(height: 2),
          Text(
            'Courts: ${courts.length} booked',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 2),
          Text(
            'Participants: $registeredCount/$maxParticipants',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                DateFormat('d MMM yyyy, hh:mm a').format(eventDate),
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (status == 'Draft')
                TextButton.icon(
                  onPressed: () => _showPublishDialog(event.id),
                  icon: const Icon(Icons.publish, size: 16),
                  label: const Text('Publish'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              if (status == 'Published')
                TextButton.icon(
                  onPressed: () => _showCancelDialog(event.id),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsPage(event: data),
                    ),
                  );
                },
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showPublishDialog(String eventId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Event'),
        content: const Text(
            'Are you sure you want to publish this event? Once published, participants can register for it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _publishEvent(eventId);
    }
  }

  Future<void> _showCancelDialog(String eventId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text(
            'Are you sure you want to cancel this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Event'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _cancelEvent(eventId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome,', style: TextStyle(fontSize: 16)),
            Text(
              userName ?? 'Loading...',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton(0, 'My Events'),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Published Events'),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Past Events'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('event')
                    .where('organizerId', isEqualTo: userId)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading events'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDocs = snapshot.data!.docs;
                  final now = DateTime.now();

                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final eventDate = data['date'] is Timestamp
                        ? (data['date'] as Timestamp).toDate()
                        : DateTime.now();

                    final status = data['status'] ?? 'Draft';

                    // 0 = My Events (all), 1 = Published Events, 2 = Past Events
                    switch (selectedTabIndex) {
                      case 0:
                        return eventDate.isAfter(now) || status == 'Draft';
                      case 1:
                        return status == 'Published' && eventDate.isAfter(now);
                      case 2:
                        return eventDate.isBefore(now) ||
                            status == 'Completed' ||
                            status == 'Cancelled';
                      default:
                        return true;
                    }
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    String message;
                    switch (selectedTabIndex) {
                      case 0:
                        message =
                            'No upcoming events found.\nTap + to create your first event!';
                        break;
                      case 1:
                        message = 'No published events found.';
                        break;
                      case 2:
                        message = 'No past events found.';
                        break;
                      default:
                        message = 'No events found.';
                    }

                    return Center(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(filteredDocs[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.home), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.add_circle,
                    size: 32, color: Color(0xFF870C14)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventBookingPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
