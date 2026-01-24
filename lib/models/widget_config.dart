enum HomeWidget {
  clock,
  date,
  battery,
  none,
}

enum SearchEngine {
  duckduckgo,
  google,
}

class WidgetConfig {
  final HomeWidget topWidget;
  final HomeWidget centerWidget;
  final HomeWidget bottomWidget;
  final bool showFlashlight;
  final SearchEngine searchEngine;
  final List<String> commonApps;

  const WidgetConfig({
    this.topWidget = HomeWidget.none,
    this.centerWidget = HomeWidget.clock,
    this.bottomWidget = HomeWidget.date,
    this.showFlashlight = true,
    this.searchEngine = SearchEngine.duckduckgo,
    this.commonApps = const [],
  });

  WidgetConfig copyWith({
    HomeWidget? topWidget,
    HomeWidget? centerWidget,
    HomeWidget? bottomWidget,
    bool? showFlashlight,
    SearchEngine? searchEngine,
    List<String>? commonApps,
  }) {
    return WidgetConfig(
      topWidget: topWidget ?? this.topWidget,
      centerWidget: centerWidget ?? this.centerWidget,
      bottomWidget: bottomWidget ?? this.bottomWidget,
      showFlashlight: showFlashlight ?? this.showFlashlight,
      searchEngine: searchEngine ?? this.searchEngine,
      commonApps: commonApps ?? this.commonApps,
    );
  }

  Map<String, dynamic> toJson() => {
        'topWidget': topWidget.index,
        'centerWidget': centerWidget.index,
        'bottomWidget': bottomWidget.index,
        'showFlashlight': showFlashlight,
        'searchEngine': searchEngine.index,
        'commonApps': commonApps,
      };

  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    return WidgetConfig(
      topWidget: HomeWidget.values[json['topWidget'] ?? 3],
      centerWidget: HomeWidget.values[json['centerWidget'] ?? 0],
      bottomWidget: HomeWidget.values[json['bottomWidget'] ?? 1],
      showFlashlight: json['showFlashlight'] ?? true,
      searchEngine: SearchEngine.values[json['searchEngine'] ?? 0],
      commonApps: json['commonApps'] != null 
          ? List<String>.from(json['commonApps']).take(6).toList()
          : const [],
    );
  }
}
