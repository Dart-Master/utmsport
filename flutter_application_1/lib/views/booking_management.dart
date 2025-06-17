import 'package:flutter/material.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  String selectedTab = 'Pending';
  
  // Sample booking data
  final List<BookingItem> bookings = [
    BookingItem(
      id: '1',
      title: 'Badminton Court Indoor Facilities - Court 8',
      date: '17 Nov 2021, 16:50-18:50',
      status: 'pending',
      imageUrl: 'assets/images/BadmintonCourt.jpeg',  // Local asset path
    ),
    BookingItem(
      id: '2',
      title: 'Basketball Court - Main Court',
      date: '16 Nov 2021, 16:50-18:50',
      status: 'pending',
      imageUrl: 'assets/images/BasketballCourt.jpeg',  // Local asset path
    ),
    BookingItem(
      id: '3',
      title: 'Basketball Court - Court 2',
      date: '15 Nov 2021, 16:50-18:50',
      status: 'pending',
      imageUrl: 'assets/images/BasketballCourt.jpeg',  // Local asset path
    ),
    BookingItem(
      id: '4',
      title: 'Tennis Court Outdoor - Court 3',
      date: '14 Nov 2021, 14:00-16:00',
      status: 'approved',
      imageUrl: 'assets/images/TennisCourt.jpeg',  // Local asset path
    ),
    BookingItem(
      id: '5',
      title: 'Basketball Court - Court A',
      date: '13 Nov 2021, 10:00-12:00',
      status: 'cancelled',
      imageUrl: 'assets/images/BasketballCourt.jpeg',  // Local asset path
    ),
  ];

  List<BookingItem> get filteredBookings {
    switch (selectedTab.toLowerCase()) {
      case 'pending':
        return bookings.where((booking) => booking.status == 'pending').toList();
      case 'approved':
        return bookings.where((booking) => booking.status == 'approved').toList();
      case 'cancelled':
        return bookings.where((booking) => booking.status == 'cancelled').toList();
      default:
        return bookings;
    }
  }

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
            child: Row(
              children: [
                _buildTabButton('Pending'),
                const SizedBox(width: 12),
                _buildTabButton('Approved'),
                const SizedBox(width: 12),
                _buildTabButton('Cancelled'),
              ],
            ),
          ),
          
          // Booking list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(filteredBookings[index]);
              },
            ),
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
                booking.imageUrl,  // Use Image.asset for local assets
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
                
                // Action buttons (only show for pending bookings)
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
                  // Status indicator for approved/cancelled bookings
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildActionButton(String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
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
