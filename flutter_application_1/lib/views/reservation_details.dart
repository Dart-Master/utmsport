// reservation_details.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const ReservationDetailsPage({super.key, required this.booking});

  @override
  State<ReservationDetailsPage> createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  late DateTime selectedDate;
  late String selectedTimeSlot;
  bool updating = false;

  List<String> getTimeSlotsForSport(String sport) {
    switch (sport) {
      case 'Badminton':
        return ['9:00 - 11:00', '11:00 - 13:00', '14:00 - 16:00', '16:00 - 18:00'];
      case 'Ping Pong':
        return ['10:00 - 12:00', '12:00 - 14:00', '15:00 - 17:00'];
      case 'Volleyball':
        return ['13:00 - 15:00', '16:00 - 18:00', '19:00 - 21:00'];
      case 'Squash':
        return ['8:00 - 10:00', '11:00 - 13:00', '15:00 - 17:00'];
      default:
        return ['9:00 - 11:00', '11:00 - 13:00'];
    }
  }

  @override
  void initState() {
    super.initState();
    final dateField = widget.booking['date'];
    selectedDate = dateField is Timestamp
        ? dateField.toDate()
        : DateTime.tryParse(dateField.toString()) ?? DateTime.now();
    selectedTimeSlot = widget.booking['timeSlot'];
  }

  void _showRescheduleSheet() {
    final timeSlots = getTimeSlotsForSport(widget.booking['sport']);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Reschedule Booking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('d MMM yyyy').format(selectedDate)),
                  onPressed: () async {
                    DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (newDate != null) {
                      setModalState(() => selectedDate = newDate);
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Align(alignment: Alignment.centerLeft, child: Text('Select Time Slot:')),
                Wrap(
                  spacing: 10,
                  children: timeSlots.map((slot) {
                    return ChoiceChip(
                      label: Text(slot),
                      selected: selectedTimeSlot == slot,
                      onSelected: (_) => setModalState(() => selectedTimeSlot = slot),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Confirm Reschedule'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _rescheduleBooking();
                  },
                )
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _rescheduleBooking() async {
    setState(() => updating = true);
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.booking['id'])
          .update({
        'date': Timestamp.fromDate(selectedDate),
        'timeSlot': selectedTimeSlot,
        'status': 'rescheduled',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successfully rescheduled')),
      );
      Navigator.pop(context); // Close the detail page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reschedule booking')),
      );
    } finally {
      setState(() => updating = false);
    }
  }

  Future<void> _cancelBooking() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => updating = true);
      await FirebaseFirestore.instance.collection('bookings').doc(widget.booking['id']).update({
        'status': 'cancelled',
      });
      setState(() => updating = false);
      Navigator.pop(context); // Go back to reservations list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final qrData = booking['qrCode'] ?? booking['id'] ?? 'No QR';
    final isCheckedIn = (booking['status'] ?? '').toString().toLowerCase() == 'checked in' ||
        (booking['status'] ?? '').toString().toLowerCase() == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: updating
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${booking['sport']} Court',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Facility: ${booking['court'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                    Text('Date: ${DateFormat('d MMM yyyy').format(selectedDate)}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Time Slot: $selectedTimeSlot', style: const TextStyle(fontSize: 16)),
                    Text('Pax: ${booking['pax']}', style: const TextStyle(fontSize: 16)),
                    Text('Status: ${booking['status']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    const Text('Scan this QR code to check in:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Center(
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!isCheckedIn)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel'),
                            onPressed: _cancelBooking,
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            icon: const Icon(Icons.schedule),
                            label: const Text('Reschedule'),
                            onPressed: _showRescheduleSheet,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
