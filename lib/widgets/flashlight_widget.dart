import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class FlashlightWidget extends StatefulWidget {
  const FlashlightWidget({super.key});

  @override
  State<FlashlightWidget> createState() => _FlashlightWidgetState();
}

class _FlashlightWidgetState extends State<FlashlightWidget> {
  static const platform = MethodChannel('com.blackandwhite.launcher/app');
  bool _isOn = false;

  @override
  void initState() {
    super.initState();
    _checkFlashlightStatus();
  }

  Future<void> _checkFlashlightStatus() async {
    try {
      final bool? result = await platform.invokeMethod('isFlashlightOn');
      if (mounted && result != null) {
        setState(() {
          _isOn = result;
        });
      }
    } catch (e) {
      // Flashlight status not available
    }
  }

  Future<void> _toggleFlashlight() async {
    try {
      final bool? result = await platform.invokeMethod('toggleFlashlight');
      if (mounted && result != null) {
        setState(() {
          _isOn = result;
        });
      }
    } catch (e) {
      // Flashlight not available
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlashlight,
      child: Icon(
        _isOn ? Icons.flash_on : Icons.flash_off,
        color: AppTheme.foreground,
        size: 24,
      ),
    );
  }
}


