enum HomeWidget {
  clock,
  date,
  battery,
  none,
}

class WidgetConfig {
  final HomeWidget topWidget;
  final HomeWidget centerWidget;
  final HomeWidget bottomWidget;

  const WidgetConfig({
    this.topWidget = HomeWidget.none,
    this.centerWidget = HomeWidget.clock,
    this.bottomWidget = HomeWidget.date,
  });

  WidgetConfig copyWith({
    HomeWidget? topWidget,
    HomeWidget? centerWidget,
    HomeWidget? bottomWidget,
  }) {
    return WidgetConfig(
      topWidget: topWidget ?? this.topWidget,
      centerWidget: centerWidget ?? this.centerWidget,
      bottomWidget: bottomWidget ?? this.bottomWidget,
    );
  }

  Map<String, dynamic> toJson() => {
        'topWidget': topWidget.index,
        'centerWidget': centerWidget.index,
        'bottomWidget': bottomWidget.index,
      };

  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    return WidgetConfig(
      topWidget: HomeWidget.values[json['topWidget'] ?? 3],
      centerWidget: HomeWidget.values[json['centerWidget'] ?? 0],
      bottomWidget: HomeWidget.values[json['bottomWidget'] ?? 1],
    );
  }
}
