import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/widget_config.dart';

class SettingsService {
  static const String _widgetConfigKey = 'widget_config';
  static const String _hiddenAppsKey = 'hidden_apps';

  static Future<WidgetConfig> loadWidgetConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_widgetConfigKey);
      if (jsonString != null) {
        return WidgetConfig.fromJson(json.decode(jsonString));
      }
    } catch (e) {
      // Return default config on error
    }
    return const WidgetConfig();
  }

  static Future<void> saveWidgetConfig(WidgetConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_widgetConfigKey, json.encode(config.toJson()));
  }

  // Important apps that should never be hidden
  static const List<String> _neverHideApps = [
    'com.google.android.gm', // Gmail
    'com.android.vending', // Play Store
  ];

  static Future<List<String>> loadHiddenApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hiddenAppsList = prefs.getStringList(_hiddenAppsKey);
      final hiddenApps = hiddenAppsList ?? [];
      
      // Remove any important apps from the hidden list
      final cleanedHiddenApps = hiddenApps
          .where((packageName) => !_neverHideApps.contains(packageName))
          .toList();
      
      // If we removed any, save the cleaned list
      if (cleanedHiddenApps.length != hiddenApps.length) {
        await saveHiddenApps(cleanedHiddenApps);
      }
      
      return cleanedHiddenApps;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHiddenApps(List<String> hiddenApps) async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure important apps are never saved as hidden
    final cleanedHiddenApps = hiddenApps
        .where((packageName) => !_neverHideApps.contains(packageName))
        .toList();
    await prefs.setStringList(_hiddenAppsKey, cleanedHiddenApps);
  }
}
