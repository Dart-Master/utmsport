import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/profile.dart';
import 'package:flutter_application_1/views/reservations.dart';
import '../user_auth/login_page.dart';
import '../court_booking.dart';
import 'package:intl/intl.dart';
import '../reservation_details.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
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
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = doc['name'] ?? 'No name set';
      });
    }
  }

  Widget _buildTabButton(int index, String label) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: selectedTabIndex == index ? Color(0xFF870C14) : Colors.grey[600],
          fontWeight: selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _checkInBooking(String bookingId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': 'Checked-In',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully checked in!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
                  _buildTabButton(0, 'Reservation Record'),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'My Reservation Record'),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Past Reservation'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading bookings'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDocs = snapshot.data!.docs;
                  final now = DateTime.now();

                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final bookingDate = data['date'] is Timestamp
                        ? (data['date'] as Timestamp).toDate()
                        : DateTime.now();

                    final status = data['status'] ?? '';

                    if (selectedTabIndex == 0) {
                      return true; // All bookings
                    }

                    if (selectedTabIndex == 1) {
                      return data['userId'] == userId &&
                          status != 'Checked-In' &&
                          bookingDate.isAfter(now);
                    }

                    if (selectedTabIndex == 2) {
                      return data['userId'] == userId &&
                          (status == 'Checked-In' || bookingDate.isBefore(now));
                    }

                    return false;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final booking = filteredDocs[index];
                      final data = booking.data() as Map<String, dynamic>;

                      DateTime bookingDate;
                      if (data['date'] is Timestamp) {
                        bookingDate = (data['date'] as Timestamp).toDate();
                      } else if (data['date'] is String) {
                        bookingDate = DateTime.tryParse(data['date']) ?? DateTime.now();
                      } else {
                        bookingDate = DateTime.now();
                      }

                      final sport = data['sport'] ?? 'Unknown';
                      final court = data['court'] ?? 'N/A';
                      final status = data['status'] ?? 'Pending';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$sport Court',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'Facility: $court',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('d MMM yyyy, hh:mm a').format(bookingDate),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (data['userId'] == userId && status == 'Upcoming')
                                      TextButton.icon(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Confirm Check-In'),
                                              content: const Text(
                                                  'Are you sure you want to check in for this booking?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Check-In'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _checkInBooking(booking.id);
                                          }
                                        },
                                        icon: const Icon(Icons.login),
                                        label: const Text('Check In'),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReservationDetailsPage(booking: data),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
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
                icon: const Icon(Icons.book_online_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReservationsPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 32, color: Color(0xFF870C14)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SportsCourtBooking()),
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileView()),
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
