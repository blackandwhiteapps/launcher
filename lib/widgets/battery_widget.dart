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

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }

  Future<void> _getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      setState(() {
        _batteryLevel = result;
      });
    } on PlatformException {
      setState(() {
        _batteryLevel = -1;
      });
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
