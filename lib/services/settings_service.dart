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

  static Future<List<String>> loadHiddenApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hiddenAppsList = prefs.getStringList(_hiddenAppsKey);
      return hiddenAppsList ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHiddenApps(List<String> hiddenApps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_hiddenAppsKey, hiddenApps);
  }
}
