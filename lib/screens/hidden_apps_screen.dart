import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import '../services/app_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class HiddenAppsScreen extends StatefulWidget {
  const HiddenAppsScreen({super.key});

  @override
  State<HiddenAppsScreen> createState() => _HiddenAppsScreenState();
}

class _HiddenAppsScreenState extends State<HiddenAppsScreen> {
  List<AppInfo> _allApps = [];
  List<String> _hiddenApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final allApps = await AppService.getAllApps();
    final hiddenApps = await SettingsService.loadHiddenApps();

    setState(() {
      _allApps = allApps;
      _hiddenApps = hiddenApps;
      _filteredApps = allApps;
      _isLoading = false;
    });
  }

  void _filterApps(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredApps = _allApps;
      } else {
        _filteredApps = _allApps
            .where(
              (app) => app.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _toggleAppVisibility(AppInfo app) async {
    setState(() {
      if (_hiddenApps.contains(app.packageName)) {
        _hiddenApps.remove(app.packageName);
      } else {
        _hiddenApps.add(app.packageName);
      }
    });

    await SettingsService.saveHiddenApps(_hiddenApps);
    // Clear cache so drawer will show updated app list
    AppService.clearCache();
  }

  bool _isAppHidden(AppInfo app) {
    return _hiddenApps.contains(app.packageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hidden Apps'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.foreground,
              ),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterApps,
                    style: const TextStyle(color: AppTheme.foreground),
                    cursorColor: AppTheme.foreground,
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      hintStyle: const TextStyle(
                        color: AppTheme.foregroundMuted,
                      ),
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
                  child: _filteredApps.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'No apps found'
                                : 'No matching apps',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppTheme.foregroundMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredApps.length,
                          itemBuilder: (context, index) {
                            final app = _filteredApps[index];
                            final isHidden = _isAppHidden(app);
                            return _AppListItem(
                              app: app,
                              isHidden: isHidden,
                              onTap: () => _toggleAppVisibility(app),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _AppListItem extends StatelessWidget {
  final AppInfo app;
  final bool isHidden;
  final VoidCallback onTap;

  const _AppListItem({
    required this.app,
    required this.isHidden,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                app.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.foreground,
                    ),
              ),
            ),
            Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: isHidden
                  ? AppTheme.foregroundMuted
                  : AppTheme.foreground,
            ),
          ],
        ),
      ),
    );
  }
}





