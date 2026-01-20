import 'package:flutter/material.dart';
import '../models/widget_config.dart';
import '../services/settings_service.dart';
import '../services/app_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home_widget_display.dart';
import '../widgets/flashlight_widget.dart';
import 'app_drawer.dart';
import 'settings_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WidgetConfig _widgetConfig = const WidgetConfig();
  double? _dragStartX;
  bool _isOpeningDrawer = false;

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

  void _openAppDrawer({int? initialPage}) {
    // Prevent opening multiple drawers
    if (_isOpeningDrawer) {
      return;
    }
    
    // Check if drawer is already open by checking if we can pop
    // If we can pop and we're not on the home screen, drawer is likely open
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      // Check if current route is home screen
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        // Another route is on top, don't open drawer
        return;
      }
    }
    
    _isOpeningDrawer = true;
    
    navigator.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AppDrawer(initialPage: initialPage),
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
    ).then((_) {
      // Reset flag when drawer is closed
      if (mounted) {
        setState(() {
          _isOpeningDrawer = false;
        });
      }
    });
  }
  
  Future<int> _calculatePageFromPosition(double x, double screenWidth) async {
    // Get total number of apps to calculate pages
    final apps = await AppService.getInstalledApps();
    const appsPerPage = 6;
    final totalPages = (apps.length / appsPerPage).ceil();
    
    if (totalPages <= 1) return 0;
    
    // Calculate page based on horizontal position
    // Left edge (x = 0) = first page (0)
    // Right edge (x = screenWidth) = last page (totalPages - 1)
    final normalizedX = x.clamp(0.0, screenWidth);
    final pageIndex = ((normalizedX / screenWidth) * (totalPages - 1)).round();
    return pageIndex.clamp(0, totalPages - 1);
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
        onVerticalDragStart: (details) {
          _dragStartX = details.localPosition.dx;
        },
        onVerticalDragEnd: (details) async {
          if (details.primaryVelocity != null) {
            // Swipe up to open app drawer
            if (details.primaryVelocity! < -500) {
              // Prevent opening if already opening or drawer is open
              if (_isOpeningDrawer) {
                _dragStartX = null;
                return;
              }
              
              final screenWidth = MediaQuery.of(context).size.width;
              final startX = _dragStartX ?? screenWidth / 2;
              final targetPage = await _calculatePageFromPosition(startX, screenWidth);
              
              // Check again after async operation
              if (!_isOpeningDrawer && mounted) {
                _openAppDrawer(initialPage: targetPage);
              }
            }
            // Swipe down to open notification panel
            else if (details.primaryVelocity! > 500) {
              AppService.openNotificationPanel();
            }
          }
          _dragStartX = null;
        },
        onLongPress: _openSettings,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: AppTheme.background,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
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

                      // Search input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.foreground, width: 1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: AppTheme.foreground,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Search',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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
                // Flashlight toggle in upper right
                if (_widgetConfig.showFlashlight)
                  Positioned(
                    top: 16,
                    right: 24,
                    child: const FlashlightWidget(),
                  ),
              ],
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
