import 'package:flutter/material.dart';
import '../models/widget_config.dart';
import '../services/settings_service.dart';
import '../services/app_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home_widget_display.dart';
import 'app_drawer.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WidgetConfig _widgetConfig = const WidgetConfig();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await SettingsService.loadWidgetConfig();
    setState(() {
      _widgetConfig = config;
    });
  }

  void _openAppDrawer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppDrawer(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _openSettings() async {
    final result = await Navigator.of(context).push<WidgetConfig>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(config: _widgetConfig),
      ),
    );
    if (result != null) {
      setState(() {
        _widgetConfig = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            // Swipe up to open app drawer
            if (details.primaryVelocity! < -500) {
              _openAppDrawer();
            }
            // Swipe down to open notification panel
            else if (details.primaryVelocity! > 500) {
              AppService.openNotificationPanel();
            }
          }
        },
        onLongPress: _openSettings,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: AppTheme.background,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top widget
                  if (_widgetConfig.topWidget != HomeWidget.none)
                    HomeWidgetDisplay(widgetType: _widgetConfig.topWidget),

                  const Spacer(),

                  // Center widget
                  if (_widgetConfig.centerWidget != HomeWidget.none)
                    HomeWidgetDisplay(widgetType: _widgetConfig.centerWidget),

                  const SizedBox(height: 8),

                  // Bottom widget
                  if (_widgetConfig.bottomWidget != HomeWidget.none)
                    HomeWidgetDisplay(widgetType: _widgetConfig.bottomWidget),

                  const Spacer(),

                  // Quick action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuickActionButton(
                        icon: Icons.phone,
                        onTap: () => AppService.launchPhone(),
                      ),
                      const SizedBox(width: 32),
                      _QuickActionButton(
                        icon: Icons.message,
                        onTap: () => AppService.launchMessages(),
                      ),
                      const SizedBox(width: 32),
                      _QuickActionButton(
                        icon: Icons.camera_alt,
                        onTap: () => AppService.launchCamera(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Swipe hint
                  Center(
                    child: Text(
                      'Swipe up for apps',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.foregroundMuted.withValues(alpha: 0.5),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.foregroundMuted.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.foreground,
          size: 24,
        ),
      ),
    );
  }
}
