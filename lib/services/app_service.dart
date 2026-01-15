import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'settings_service.dart';

class AppService {
  static Future<List<AppInfo>> getInstalledApps({bool excludeSystemApps = true}) async {
    try {
      // Positional args: excludeSystemApps, withIcon
      final apps = await InstalledApps.getInstalledApps(excludeSystemApps, false);
      
      // Get hidden apps and filter them out
      final hiddenApps = await SettingsService.loadHiddenApps();
      final filteredApps = apps.where((app) => !hiddenApps.contains(app.packageName)).toList();
      
      // Sort alphabetically by name
      filteredApps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return filteredApps;
    } catch (e) {
      return [];
    }
  }
  
  static Future<List<AppInfo>> getAllApps() async {
    try {
      // Get all apps including system apps
      final apps = await InstalledApps.getInstalledApps(false, false);
      // Sort alphabetically by name
      apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return apps;
    } catch (e) {
      return [];
    }
  }

  static Future<void> launchApp(String packageName) async {
    try {
      await InstalledApps.startApp(packageName);
    } catch (e) {
      // App couldn't be launched
    }
  }

  static Future<void> openAppSettings(String packageName) async {
    try {
      await InstalledApps.openSettings(packageName);
    } catch (e) {
      // Settings couldn't be opened
    }
  }

  static const MethodChannel _appChannel = MethodChannel('com.blackandwhite.launcher/app');
  static const MethodChannel _launcherChannel = MethodChannel('com.blackandwhite.launcher/launcher');

  static Future<void> launchPhone() async {
    try {
      await _appChannel.invokeMethod('launchPhone');
    } catch (e) {
      // Phone couldn't be launched
    }
  }

  static Future<void> launchMessages() async {
    try {
      await _appChannel.invokeMethod('launchMessages');
    } catch (e) {
      // Messages couldn't be launched
    }
  }

  static Future<void> launchCamera() async {
    try {
      await _appChannel.invokeMethod('launchCamera');
    } catch (e) {
      // Camera couldn't be launched
    }
  }

  static Future<void> openNotificationPanel() async {
    try {
      await _appChannel.invokeMethod('openNotificationPanel');
    } catch (e) {
      // Notification panel couldn't be opened
    }
  }

  static Future<void> launchClock() async {
    try {
      await _appChannel.invokeMethod('launchClock');
    } catch (e) {
      // Clock couldn't be launched
    }
  }

  static Future<void> launchCalendar() async {
    try {
      await _appChannel.invokeMethod('launchCalendar');
    } catch (e) {
      // Calendar couldn't be launched
    }
  }

  static Future<bool> isDefaultLauncher() async {
    try {
      final result = await _launcherChannel.invokeMethod<bool>('isDefaultLauncher');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openDefaultLauncherSettings() async {
    try {
      await _launcherChannel.invokeMethod('openDefaultLauncherSettings');
    } catch (e) {
      // Settings couldn't be opened
    }
  }
}
