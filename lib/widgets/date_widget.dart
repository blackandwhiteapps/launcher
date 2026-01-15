import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_service.dart';

class DateWidget extends StatefulWidget {
  const DateWidget({super.key});

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    // Update once per minute is enough for date
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDate() {
    final weekday = _weekdays[_now.weekday - 1];
    final month = _months[_now.month - 1];
    final day = _now.day;
    return '$weekday, $month $day';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppService.launchCalendar(),
      child: Text(
        _formatDate(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.foregroundMuted,
              fontWeight: FontWeight.w300,
            ),
      ),
    );
  }
}
