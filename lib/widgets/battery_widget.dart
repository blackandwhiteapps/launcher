import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BatteryWidget extends StatefulWidget {
  const BatteryWidget({super.key});

  @override
  State<BatteryWidget> createState() => _BatteryWidgetState();
}

class _BatteryWidgetState extends State<BatteryWidget> {
  static const platform = MethodChannel('com.blackandwhite.launcher/battery');
  int _batteryLevel = -1;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    // Update battery level every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _getBatteryLevel();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      if (mounted) {
        setState(() {
          _batteryLevel = result;
        });
      }
    } on PlatformException {
      if (mounted) {
        setState(() {
          _batteryLevel = -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _batteryLevel >= 0 ? '$_batteryLevel%' : '--';
    
    return Text(
      displayText,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.foregroundMuted,
            fontWeight: FontWeight.w300,
          ),
    );
  }
}
