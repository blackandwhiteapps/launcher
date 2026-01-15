import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import '../services/app_service.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _loadApps();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isAtTop = _scrollController.position.pixels <= 0;
    if (isAtTop != _isAtTop) {
      setState(() {
        _isAtTop = isAtTop;
      });
    }
  }

  void _closeDrawer() {
    if (!_isClosing && mounted) {
      _isClosing = true;
      Navigator.of(context).pop();
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    // Check if we're at the top using scroll controller
    final isAtTop =
        _scrollController.hasClients && _scrollController.position.pixels <= 0;

    // If at top and dragging down significantly, close the drawer
    if (isAtTop && details.primaryDelta != null && details.primaryDelta! > 10) {
      // Only close if we've dragged down enough
      _closeDrawer();
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // Check if we're at the top using scroll controller
    final isAtTop =
        _scrollController.hasClients && _scrollController.position.pixels <= 0;

    // Swipe down to close app drawer when at top
    if (isAtTop &&
        details.primaryVelocity != null &&
        details.primaryVelocity! > 500) {
      _closeDrawer();
    }
  }

  Future<void> _loadApps() async {
    final apps = await AppService.getInstalledApps();
    setState(() {
      _apps = apps;
      _filteredApps = apps;
      _isLoading = false;
    });
  }

  void _filterApps(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredApps = _apps;
      } else {
        _filteredApps = _apps
            .where(
              (app) => app.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _filterApps,
                style: const TextStyle(color: AppTheme.foreground),
                cursorColor: AppTheme.foreground,
                decoration: InputDecoration(
                  hintText: 'Search apps...',
                  hintStyle: const TextStyle(color: AppTheme.foregroundMuted),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.foregroundMuted,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppTheme.foregroundMuted,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterApps('');
                          },
                        )
                      : null,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.foregroundMuted),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.foreground),
                  ),
                ),
              ),
            ),

            // App list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.foreground,
                      ),
                    )
                  : _filteredApps.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No apps found'
                            : 'No matching apps',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.foregroundMuted,
                        ),
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification ||
                            notification is ScrollEndNotification) {
                          final isAtTop =
                              _scrollController.hasClients &&
                              _scrollController.position.pixels <= 0;
                          if (isAtTop != _isAtTop) {
                            setState(() {
                              _isAtTop = isAtTop;
                            });
                          }
                        }
                        // Allow overscroll notifications to pass through
                        return false;
                      },
                      child: Listener(
                        onPointerMove: (event) {
                          // Check if we're at top and dragging down
                          if (_isAtTop && event.delta.dy > 0) {
                            // User is dragging down at the top
                            // This will be handled by the gesture detector
                          }
                        },
                        child: GestureDetector(
                          onVerticalDragUpdate: _handleVerticalDragUpdate,
                          onVerticalDragEnd: _handleVerticalDragEnd,
                          behavior: HitTestBehavior.translucent,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: _isAtTop
                                ? const AlwaysScrollableScrollPhysics()
                                : const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredApps.length,
                            itemBuilder: (context, index) {
                              final app = _filteredApps[index];
                              return _AppListItem(
                                app: app,
                                onTap: () =>
                                    AppService.launchApp(app.packageName),
                                onLongPress: () =>
                                    AppService.openAppSettings(app.packageName),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppListItem extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _AppListItem({
    required this.app,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          app.name,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.foreground),
        ),
      ),
    );
  }
}
