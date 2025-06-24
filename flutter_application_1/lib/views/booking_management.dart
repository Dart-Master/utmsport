import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  String selectedTab = 'Pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Booking Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('Pending'),
                  const SizedBox(width: 12),
                  _buildTabButton('Reservation Record'),
                  const SizedBox(width: 12),
                  _buildTabButton('Approved'),
                  const SizedBox(width: 12),
                  _buildTabButton('Cancelled'),
                ],
              ),
            ),
          ),
          // Tab content
          Expanded(
            child: selectedTab == 'Reservation Record'
                ? _buildReservationRecordTab()
                : _buildLocalBookingList(),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, false),
            _buildNavItem(Icons.person_outline, false),
            _buildNavItem(Icons.group_outlined, false),
            _buildNavItem(Icons.mail_outline, false),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue[800] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Firestore Reservation Record Tab
  Widget _buildReservationRecordTab() {
    return StreamBuilder<QuerySnapshot>(
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

        if (allDocs.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: allDocs.length,
          itemBuilder: (context, index) {
            final booking = allDocs[index];
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
            final userId = data['userId'] ?? 'Unknown';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon or image placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child:
                        const Icon(Icons.sports, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$sport Court',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Facility: $court',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('d MMM yyyy, hh:mm a').format(bookingDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'User ID: $userId',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'approved'
                                ? Colors.green[100]
                                : status == 'pending'
                                    ? Colors.yellow[100]
                                    : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: status == 'approved'
                                  ? Colors.green[700]
                                  : status == 'pending'
                                      ? Colors.orange[700]
                                      : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Local sample data for other tabs
  final List<BookingItem> bookings = [
    BookingItem(
      id: '1',
      title: 'Badminton Court Indoor Facilities - Court 8',
      date: '17 Nov 2021, 16:50-18:50',
      status: 'pending',
      imageUrl: 'assets/images/BadmintonCourt.jpeg',
    ),
    BookingItem(
      id: '2',
      title: 'Basketball Court - Main Court',
      date: '16 Nov 2021, 16:50-18:50',
      status: 'pending',
      imageUrl: 'assets/images/BasketballCourt.jpeg',
    ),
    BookingItem(
      id: '3',
      title: 'Basketball Court - Court 2',
      date: '15 Nov 2021, 16:50-18:50',
      status: 'pending',
      imageUrl: 'assets/images/BasketballCourt.jpeg',
    ),
    BookingItem(
      id: '4',
      title: 'Tennis Court Outdoor - Court 3',
      date: '14 Nov 2021, 14:00-16:00',
      status: 'approved',
      imageUrl: 'assets/images/TennisCourt.jpeg',
    ),
    BookingItem(
      id: '5',
      title: 'Basketball Court - Court A',
      date: '13 Nov 2021, 10:00-12:00',
      status: 'cancelled',
      imageUrl: 'assets/images/BasketballCourt.jpeg',
    ),
  ];

  List<BookingItem> get filteredBookings {
    switch (selectedTab.toLowerCase()) {
      case 'pending':
        return bookings
            .where((booking) => booking.status == 'pending')
            .toList();
      case 'approved':
        return bookings
            .where((booking) => booking.status == 'approved')
            .toList();
      case 'cancelled':
        return bookings
            .where((booking) => booking.status == 'cancelled')
            .toList();
      default:
        return bookings;
    }
  }

  Widget _buildLocalBookingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(filteredBookings[index]);
      },
    );
  }

  Widget _buildBookingCard(BookingItem booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                booking.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.sports, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                if (booking.status == 'pending') ...[
                  Row(
                    children: [
                      _buildActionButton(
                        'Approve',
                        Colors.blue,
                        Colors.white,
                        () => _approveBooking(booking),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        'Reject',
                        Colors.red[100]!,
                        Colors.red[700]!,
                        () => _rejectBooking(booking),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: booking.status == 'approved'
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: booking.status == 'approved'
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color backgroundColor, Color textColor,
      VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isActive ? Colors.blue : Colors.grey[400],
        size: 24,
      ),
    );
  }

  void _approveBooking(BookingItem booking) {
    setState(() {
      booking.status = 'approved';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${booking.id} approved successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _rejectBooking(BookingItem booking) {
    setState(() {
      booking.status = 'cancelled';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${booking.id} rejected'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class BookingItem {
  final String id;
  final String title;
  final String date;
  String status;
  final String imageUrl;

  BookingItem({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.imageUrl,
  });
}
