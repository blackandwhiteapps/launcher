import 'package:hive_flutter/hive_flutter.dart';

class SearchHistoryService {
  static const String _boxName = 'searchHistory';
  static const int _maxHistoryItems = 50;

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  static Box<String>? get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      return null;
    }
    return Hive.box<String>(_boxName);
  }

  /// Add a search query to history
  static Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    final box = _box;
    if (box == null) return;

    final trimmedQuery = query.trim();
    
    // Remove if it already exists (to move to top)
    await box.delete(trimmedQuery);
    
    // Add to the end (most recent)
    await box.put(trimmedQuery, trimmedQuery);
    
    // Limit history size
    final keys = box.keys.toList();
    if (keys.length > _maxHistoryItems) {
      // Remove oldest items (from the beginning)
      final itemsToRemove = keys.sublist(0, keys.length - _maxHistoryItems);
      for (final key in itemsToRemove) {
        await box.delete(key);
      }
    }
  }

  /// Get all search history (most recent first)
  static List<String> getAllHistory() {
    final box = _box;
    if (box == null) return [];
    // Reverse so most recent items appear first
    return box.values.toList().reversed.toList();
  }

  /// Get filtered search history based on query
  static List<String> getFilteredHistory(String query) {
    final box = _box;
    if (box == null) return [];
    
    if (query.trim().isEmpty) {
      return getAllHistory();
    }
    
    final lowerQuery = query.toLowerCase();
    // Filter and reverse so most recent matches appear first
    return box.values
        .where((item) => item.toLowerCase().contains(lowerQuery))
        .toList()
        .reversed
        .toList();
  }

  /// Clear all search history
  static Future<void> clearHistory() async {
    final box = _box;
    if (box == null) return;
    await box.clear();
  }

  /// Remove a specific search from history
  static Future<void> removeSearch(String query) async {
    final box = _box;
    if (box == null) return;
    await box.delete(query);
  }
}

