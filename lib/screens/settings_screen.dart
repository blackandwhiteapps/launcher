import 'package:flutter/material.dart';
import '../models/widget_config.dart';
import '../services/settings_service.dart';
import '../services/app_service.dart';
import '../theme/app_theme.dart';
import 'hidden_apps_screen.dart';

class SettingsScreen extends StatefulWidget {
  final WidgetConfig config;

  const SettingsScreen({super.key, required this.config});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late WidgetConfig _config;
  bool _isDefaultLauncher = false;
  bool _isCheckingLauncher = true;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
    _checkDefaultLauncher();
  }

  Future<void> _checkDefaultLauncher() async {
    final isDefault = await AppService.isDefaultLauncher();
    if (mounted) {
      setState(() {
        _isDefaultLauncher = isDefault;
        _isCheckingLauncher = false;
      });
    }
  }

  String _widgetName(HomeWidget widget) {
    switch (widget) {
      case HomeWidget.clock:
        return 'Clock';
      case HomeWidget.date:
        return 'Date';
      case HomeWidget.battery:
        return 'Battery';
      case HomeWidget.none:
        return 'None';
    }
  }

  Future<void> _saveAndPop() async {
    await SettingsService.saveWidgetConfig(_config);
    if (mounted) {
      Navigator.of(context).pop(_config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveAndPop,
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _saveAndPop();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Home Screen Widgets',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _WidgetSelector(
              label: 'Top',
              value: _config.topWidget,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(topWidget: value);
                });
              },
              widgetName: _widgetName,
            ),
            const SizedBox(height: 16),
            _WidgetSelector(
              label: 'Center',
              value: _config.centerWidget,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(centerWidget: value);
                });
              },
              widgetName: _widgetName,
            ),
            const SizedBox(height: 16),
            _WidgetSelector(
              label: 'Bottom',
              value: _config.bottomWidget,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(bottomWidget: value);
                });
              },
              widgetName: _widgetName,
            ),
            const SizedBox(height: 48),
            Text(
              'Gestures',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Swipe up: Open app drawer\nLong press: Open settings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.foregroundMuted,
                  ),
            ),
            const SizedBox(height: 48),
            Text(
              'App Management',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Hidden Apps'),
              subtitle: Text(
                'Hide apps from the app drawer',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.foregroundMuted,
                    ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.foregroundMuted,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HiddenAppsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            Text(
              'Launcher Settings',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (_isCheckingLauncher)
              const ListTile(
                title: Text('Checking launcher status...'),
              )
            else if (_isDefaultLauncher)
              ListTile(
                title: const Text('Default Launcher'),
                subtitle: Text(
                  'This app is set as your default launcher',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.foregroundMuted,
                      ),
                ),
                trailing: const Icon(
                  Icons.check_circle,
                  color: AppTheme.foreground,
                ),
              )
            else
              ListTile(
                title: const Text('Set as Default Launcher'),
                subtitle: Text(
                  'Tap to set this app as your default launcher',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.foregroundMuted,
                      ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.foregroundMuted,
                ),
                onTap: () async {
                  await AppService.openDefaultLauncherSettings();
                  // Recheck after a delay to see if user set it
                  Future.delayed(const Duration(seconds: 1), () {
                    _checkDefaultLauncher();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _WidgetSelector extends StatelessWidget {
  final String label;
  final HomeWidget value;
  final ValueChanged<HomeWidget> onChanged;
  final String Function(HomeWidget) widgetName;

  const _WidgetSelector({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.widgetName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<HomeWidget>(
            initialValue: value,
            dropdownColor: AppTheme.background,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.foregroundMuted),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.foreground),
              ),
            ),
            items: HomeWidget.values.map((widget) {
              return DropdownMenuItem(
                value: widget,
                child: Text(
                  widgetName(widget),
                  style: const TextStyle(color: AppTheme.foreground),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
