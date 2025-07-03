import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  String selectedTab = 'Reservation Record';
  String selectedStatusFilter = 'All';
  String selectedSportFilter = 'All';
  DateTime? selectedDateFilter;

  // Theme colors
  static const Color primaryColor = Color(0xFF870C14);
  static const Color primaryLight = Color(0xFFB91C1C);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Booking Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab buttons
          Container(
            color: primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton('Reservation Record'),
                    const SizedBox(width: 12),
                    _buildTabButton('Approved'),
                    const SizedBox(width: 12),
                    _buildTabButton('Cancelled'),
                  ],
                ),
              ),
            ),
          ),
          // Filters for Reservation Record
          if (selectedTab == 'Reservation Record') _buildFilters(),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filter
                _buildFilterDropdown(
                  'Status',
                  selectedStatusFilter,
                  ['All', 'Pending', 'Approved', 'Cancelled'],
                  (value) => setState(() => selectedStatusFilter = value!),
                ),
                const SizedBox(width: 16),
                // Sport Filter
                _buildFilterDropdown(
                  'Sport',
                  selectedSportFilter,
                  ['All', 'Basketball', 'Badminton', 'Tennis', 'Football'],
                  (value) => setState(() => selectedSportFilter = value!),
                ),
                const SizedBox(width: 16),
                // Date Filter
                _buildDateFilter(),
                const SizedBox(width: 16),
                // Clear Filters Button
                _buildClearFiltersButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textLight,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
            style: const TextStyle(
              fontSize: 14,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textLight,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDateFilter ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: textDark,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                selectedDateFilter = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedDateFilter != null
                      ? DateFormat('MMM dd, yyyy').format(selectedDateFilter!)
                      : 'Select Date',
                  style: const TextStyle(
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textLight,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedStatusFilter = 'All';
              selectedSportFilter = 'All';
              selectedDateFilter = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.clear,
                  size: 16,
                  color: primaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Firestore Reservation Record Tab with Filters
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
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        final allDocs = snapshot.data!.docs;
        final filteredDocs = _applyFilters(allDocs);

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No bookings found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try adjusting your filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            final userId = data['userId'] ?? 'Unknown';
            final timeSlot = data['timeSlot'] ?? 'N/A';
            final pax = data['pax'] ?? 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sport Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          _getSportIcon(sport),
                          size: 32,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$sport Court',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(status).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on, 'Court $court'),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.access_time, timeSlot),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.calendar_today, 
                                DateFormat('MMM dd, yyyy').format(bookingDate)),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.people, '$pax Players'),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.person, userId),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textLight,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: textLight,
            ),
          ),
        ),
      ],
    );
  }

  List<QueryDocumentSnapshot> _applyFilters(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status']?.toString().toLowerCase() ?? 'pending';
      final sport = data['sport']?.toString().toLowerCase() ?? '';
      
      DateTime bookingDate;
      if (data['date'] is Timestamp) {
        bookingDate = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is String) {
        bookingDate = DateTime.tryParse(data['date']) ?? DateTime.now();
      } else {
        bookingDate = DateTime.now();
      }

      // Status filter
      if (selectedStatusFilter != 'All' && 
          status != selectedStatusFilter.toLowerCase()) {
        return false;
      }

      // Sport filter
      if (selectedSportFilter != 'All' && 
          !sport.contains(selectedSportFilter.toLowerCase())) {
        return false;
      }

      // Date filter
      if (selectedDateFilter != null) {
        if (!_isSameDate(bookingDate, selectedDateFilter!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'basketball':
        return Icons.sports_basketball;
      case 'badminton':
        return Icons.sports_tennis;
      case 'tennis':
        return Icons.sports_tennis;
      case 'football':
        return Icons.sports_soccer;
      default:
        return Icons.sports;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Local sample data for other tabs (removed pending bookings)
  final List<BookingItem> bookings = [
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(filteredBookings[index]);
      },
    );
  }

  Widget _buildBookingCard(BookingItem booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    color: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.sports, color: primaryColor),
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
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(booking.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isActive ? primaryColor : Colors.grey[400],
        size: 24,
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