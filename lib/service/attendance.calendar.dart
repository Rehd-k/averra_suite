import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'api.service.dart';

class AttendanceCalendar extends StatefulWidget {
  final String userId;
  const AttendanceCalendar({super.key, required this.userId});

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  final apiService = ApiService();
  late DateTime _focusedDay;
  Set<DateTime> _attendanceDates = <DateTime>{};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final month = _focusedDay.month;
    final year = _focusedDay.year;

    final res = await apiService.get(
      'attendance?userId=${widget.userId}&month=$month&year=$year',
    );
    if (res.statusCode == 200) {
      final data = res.data;
      setState(() {
        // Ensure `data` is treated as a List and produce a typed Set<DateTime>
        _attendanceDates = (data as List)
            .map<DateTime>((e) => DateTime.parse(e['date']).toLocal())
            .toSet();
      });
    }
  }

  Future<void> markToday() async {
    await apiService.post('attendance', {
      'userId': widget.userId,
      'date': DateTime.now().toIso8601String(),
      'status': 'present',
    });

    _loadAttendance();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: markToday,
        child: const Icon(Icons.check),
      ),
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        automaticallyImplyLeading: false,
      ),
      body: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
        ),
        eventLoader: (day) {
          // Return something non-empty if the day has attendance
          return _attendanceDates.any((d) => _isSameDay(d, day))
              ? ['attendance']
              : [];
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadAttendance(); // reload for new month
        },
      ),
    );
  }
}
