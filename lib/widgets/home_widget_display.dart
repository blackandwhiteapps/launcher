import 'package:flutter/material.dart';
import '../models/widget_config.dart';
import 'clock_widget.dart';
import 'date_widget.dart';
import 'battery_widget.dart';

class HomeWidgetDisplay extends StatelessWidget {
  final HomeWidget widgetType;

  const HomeWidgetDisplay({
    super.key,
    required this.widgetType,
  });

  @override
  Widget build(BuildContext context) {
    switch (widgetType) {
      case HomeWidget.clock:
        return const ClockWidget();
      case HomeWidget.date:
        return const DateWidget();
      case HomeWidget.battery:
        return const BatteryWidget();
      case HomeWidget.none:
        return const SizedBox.shrink();
    }
  }
}
