import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import '../services/app_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class CommonAppsScreen extends StatefulWidget {
  final List<String> initialCommonApps;

  const CommonAppsScreen({super.key, this.initialCommonApps = const []});

  @override
  State<CommonAppsScreen> createState() => _CommonAppsScreenState();
}

class _CommonAppsScreenState extends State<CommonAppsScreen> {
  List<AppInfo> _allApps = [];
  List<String> _commonApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  static const int _maxCommonApps = 6;

  @override
  void initState() {
    super.initState();
    _commonApps = List<String>.from(widget.initialCommonApps).take(_maxCommonApps).toList();
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

    setState(() {
      _allApps = allApps;
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

  Future<void> _toggleAppSelection(AppInfo app) async {
    setState(() {
      if (_commonApps.contains(app.packageName)) {
        _commonApps.remove(app.packageName);
      } else {
        if (_commonApps.length < _maxCommonApps) {
          _commonApps.add(app.packageName);
        } else {
          // Show a message that max is reached
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum of $_maxCommonApps common apps allowed'),
              backgroundColor: AppTheme.foreground,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  bool _isAppSelected(AppInfo app) {
    return _commonApps.contains(app.packageName);
  }

  Future<void> _saveAndPop() async {
    final config = await SettingsService.loadWidgetConfig();
    final updatedConfig = config.copyWith(commonApps: _commonApps);
    await SettingsService.saveWidgetConfig(updatedConfig);
    if (mounted) {
      Navigator.of(context).pop(_commonApps);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Common Apps'),
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.foreground,
                ),
              )
            : Column(
                children: [
                  // Info banner
                  if (_commonApps.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: AppTheme.foregroundMuted.withValues(alpha: 0.1),
                      child: Text(
                        '${_commonApps.length} / $_maxCommonApps apps selected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.foreground,
                            ),
                      ),
                    ),

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
                              final isSelected = _isAppSelected(app);
                              final canSelect = !isSelected && _commonApps.length < _maxCommonApps;
                              return _AppListItem(
                                app: app,
                                isSelected: isSelected,
                                canSelect: canSelect,
                                onTap: () => _toggleAppSelection(app),
                              );
                            },
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
  final bool isSelected;
  final bool canSelect;
  final VoidCallback onTap;

  const _AppListItem({
    required this.app,
    required this.isSelected,
    required this.canSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: canSelect || isSelected ? onTap : null,
      child: Opacity(
        opacity: canSelect || isSelected ? 1.0 : 0.5,
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
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? AppTheme.foreground
                    : AppTheme.foregroundMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

