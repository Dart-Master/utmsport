import 'package:flutter/material.dart';

class SportsCourtBooking extends StatefulWidget {
  const SportsCourtBooking({super.key});

  @override
  State<SportsCourtBooking> dart pub global activate flutterfire_clicreateState() => _SportsCourtBookingState();
}

class _SportsCourtBookingState extends State<SportsCourtBooking> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  int _paxCount = 1;
  String _selectedSport = 'Badminton';
  final List<String> _sports = ['Badminton', 'Ping Pong', 'Volleyball', 'Squash'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Sport:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            _buildSportSelector(),
            const SizedBox(height: 20),
            Text(
              '$_selectedSport Court',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Select a date:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            _buildCalendar(),
            const SizedBox(height: 20),
            const Text('Select a period:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            _buildTimeSlots(),
            const SizedBox(height: 20),
            const Text('PAX:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            _buildPaxSelector(),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _selectedTimeSlot == null ? null : _bookCourt,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Book', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedSport,
      items: _sports.map((String sport) {
        return DropdownMenuItem<String>(
          value: sport,
          child: Text(sport),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedSport = newValue!;
          _selectedTimeSlot = null;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildWeekDaysRow(),
            _buildCalendarDays(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDaysRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
          .map((day) => Text(day, style: const TextStyle(fontWeight: FontWeight.bold)))
          .toList(),
    );
  }

  Widget _buildCalendarDays() {
    DateTime firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    int weekday = firstDayOfMonth.weekday;
    int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    List<Widget> dayWidgets = [];

    for (int i = 1; i < weekday; i++) {
      dayWidgets.add(const SizedBox(width: 30, height: 30));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(_selectedDate.year, _selectedDate.month, day);
      bool isSelected = _isSameDay(currentDay, _selectedDate);

      dayWidgets.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = currentDay),
          child: Container(
            width: 30,
            height: 30,
            decoration: isSelected
                ? BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  )
                : null,
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(color: isSelected ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildTimeSlots() {
    List<String> timeSlots = _getTimeSlotsForSport(_selectedSport);

    return Column(
      children: timeSlots.map((slot) {
        return RadioListTile<String>(
          title: Text(slot),
          value: slot,
          groupValue: _selectedTimeSlot,
          onChanged: (value) => setState(() => _selectedTimeSlot = value),
        );
      }).toList(),
    );
  }

  List<String> _getTimeSlotsForSport(String sport) {
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

  Widget _buildPaxSelector() {
    return Row(
      children: [
        Text('$_paxCount', style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _paxCount++),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _paxCount > 1 ? () => setState(() => _paxCount--) : null,
        ),
      ],
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
    });
  }

  void _bookCourt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmation'),
        content: Text(
          'You have booked the $_selectedSport court on '
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} '
          'from $_selectedTimeSlot for $_paxCount people.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ✅ Add this main() at the bottom:
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SportsCourtBooking(),
  ));
}
