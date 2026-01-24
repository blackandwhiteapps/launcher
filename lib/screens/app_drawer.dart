import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import '../services/app_service.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatefulWidget {
  final int? initialPage;

  const AppDrawer({super.key, this.initialPage});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final PageController _pageController;
  bool _isClosing = false;
  int _currentPage = 0;
  static const int _appsPerPage = 8;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? 0;
    _pageController = PageController(initialPage: _currentPage);
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _closeDrawer() {
    if (!_isClosing && mounted) {
      _isClosing = true;
      Navigator.of(context).pop();
    }
  }

  void _goToHome() {
    if (!_isClosing && mounted) {
      _isClosing = true;
      // Go to home screen (pop until we reach the first route)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    // If dragging down significantly, close the drawer
    if (details.primaryDelta != null && details.primaryDelta! > 10) {
      _closeDrawer();
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity != null) {
      // Swipe down to close app drawer
      if (details.primaryVelocity! > 500) {
        _closeDrawer();
      }
      // Swipe up to go home (close drawer and return to home)
      else if (details.primaryVelocity! < -500) {
        _goToHome();
      }
    }
  }

  int _getPageCount() {
    if (_filteredApps.isEmpty) return 1;
    return (_filteredApps.length / _appsPerPage).ceil();
  }

  List<AppInfo> _getAppsForPage(int pageIndex) {
    final startIndex = pageIndex * _appsPerPage;
    final endIndex = (startIndex + _appsPerPage).clamp(0, _filteredApps.length);
    return _filteredApps.sublist(startIndex, endIndex);
  }

  Future<void> _loadApps() async {
    // First, check if we have cached apps to show immediately
    if (AppService.hasCachedApps()) {
      final cachedApps = AppService.getCachedApps();
      setState(() {
        _apps = cachedApps;
        _filteredApps = cachedApps;
        _isLoading = false;
      });
      // Ensure initial page is valid after loading apps
      if (widget.initialPage != null && _pageController.hasClients) {
        final pageCount = _getPageCount();
        final targetPage = widget.initialPage!.clamp(0, pageCount - 1);
        if (targetPage != _pageController.page?.round()) {
          _pageController.jumpToPage(targetPage);
        }
      }
    }

    // Then refresh in the background to ensure we have the latest apps
    final apps = await AppService.getInstalledApps();
    if (mounted) {
      setState(() {
        _apps = apps;
        _filteredApps = apps;
        _isLoading = false;
      });
      // Ensure initial page is valid after loading apps
      if (widget.initialPage != null && _pageController.hasClients) {
        final pageCount = _getPageCount();
        final targetPage = widget.initialPage!.clamp(0, pageCount - 1);
        if (targetPage != _pageController.page?.round()) {
          _pageController.jumpToPage(targetPage);
        }
      }
    }
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
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // Go to home screen (pop until we reach the first route)
            _goToHome();
          }
        },
        child: SafeArea(
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
                    hintStyle: const TextStyle(color: AppTheme.foreground),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.foreground,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppTheme.foreground,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterApps('');
                            },
                          )
                        : null,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.foreground),
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.foreground),
                        ),
                      )
                    : GestureDetector(
                        onVerticalDragUpdate: _handleVerticalDragUpdate,
                        onVerticalDragEnd: _handleVerticalDragEnd,
                        behavior: HitTestBehavior.translucent,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _getPageCount(),
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemBuilder: (context, pageIndex) {
                            final pageApps = _getAppsForPage(pageIndex);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pageApps.length,
                                itemBuilder: (context, index) {
                                  final app = pageApps[index];
                                  return _AppListItem(
                                    app: app,
                                    onTap: () =>
                                        AppService.launchApp(app.packageName),
                                    onLongPress: () =>
                                        AppService.openAppSettings(
                                          app.packageName,
                                        ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),

              // Page indicator
              if (!_isLoading &&
                  _filteredApps.isNotEmpty &&
                  _getPageCount() > 1)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${_currentPage + 1} / ${_getPageCount()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.foreground,
                    ),
                  ),
                ),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 20),
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
