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

  const WidgetConfig({
    this.topWidget = HomeWidget.none,
    this.centerWidget = HomeWidget.clock,
    this.bottomWidget = HomeWidget.date,
    this.showFlashlight = true,
    this.searchEngine = SearchEngine.duckduckgo,
  });

  WidgetConfig copyWith({
    HomeWidget? topWidget,
    HomeWidget? centerWidget,
    HomeWidget? bottomWidget,
    bool? showFlashlight,
    SearchEngine? searchEngine,
  }) {
    return WidgetConfig(
      topWidget: topWidget ?? this.topWidget,
      centerWidget: centerWidget ?? this.centerWidget,
      bottomWidget: bottomWidget ?? this.bottomWidget,
      showFlashlight: showFlashlight ?? this.showFlashlight,
      searchEngine: searchEngine ?? this.searchEngine,
    );
  }

  Map<String, dynamic> toJson() => {
        'topWidget': topWidget.index,
        'centerWidget': centerWidget.index,
        'bottomWidget': bottomWidget.index,
        'showFlashlight': showFlashlight,
        'searchEngine': searchEngine.index,
      };

  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    return WidgetConfig(
      topWidget: HomeWidget.values[json['topWidget'] ?? 3],
      centerWidget: HomeWidget.values[json['centerWidget'] ?? 0],
      bottomWidget: HomeWidget.values[json['bottomWidget'] ?? 1],
      showFlashlight: json['showFlashlight'] ?? true,
      searchEngine: SearchEngine.values[json['searchEngine'] ?? 0],
    );
  }
}
