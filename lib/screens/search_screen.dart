import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/widget_config.dart';
import '../services/settings_service.dart';
import '../services/search_history_service.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  SearchEngine _searchEngine = SearchEngine.duckduckgo;
  bool _isLoading = true;
  List<String> _searchHistory = [];
  List<String> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchEngine();
    _loadSearchHistory();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    // Listen to text changes to update UI and filter history
    _searchController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      final query = _searchController.text;
      _filteredHistory = SearchHistoryService.getFilteredHistory(query);
    });
  }

  void _loadSearchHistory() {
    setState(() {
      _searchHistory = SearchHistoryService.getAllHistory();
      _filteredHistory = _searchHistory;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchEngine() async {
    final config = await SettingsService.loadWidgetConfig();
    setState(() {
      _searchEngine = config.searchEngine;
      _isLoading = false;
    });
  }

  Future<void> _performSearch([String? query]) async {
    final searchQuery = query ?? _searchController.text.trim();
    if (searchQuery.isEmpty) return;

    // Save to search history
    await SearchHistoryService.addSearch(searchQuery);

    // Update the text field if a history item was tapped
    if (query != null) {
      _searchController.text = query;
    }

    try {
      if (_searchEngine == SearchEngine.google) {
        // Try to open Google app first
        final googleAppUri = Uri.parse(
          'googleapp://search?q=${Uri.encodeComponent(searchQuery)}',
        );
        if (await canLaunchUrl(googleAppUri)) {
          await launchUrl(googleAppUri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to Chrome with Google search
          final url =
              'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}';
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        // DuckDuckGo in Chrome
        final url =
            'https://duckduckgo.com/?q=${Uri.encodeComponent(searchQuery)}';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
      // Close search screen after launching
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Could not launch URL
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.foreground),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // Go to home screen (pop until we reach the first route)
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            // Swipe up to go home
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -500) {
              // Go to home screen (pop until we reach the first route)
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          behavior: HitTestBehavior.translucent,
          child: SafeArea(
            child: Column(
              children: [
                // Search input
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSubmitted: (_) => _performSearch(),
                    style: const TextStyle(color: AppTheme.foreground),
                    cursorColor: AppTheme.foreground,
                    decoration: InputDecoration(
                      hintText: 'Search...',
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
                              },
                            )
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.foreground,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.foreground,
                        ),
                      ),
                    ),
                  ),
                ),

                // Search button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.foreground,
                        foregroundColor: AppTheme.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Search'),
                    ),
                  ),
                ),

                // Search history / autocomplete
                if (_filteredHistory.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem = _filteredHistory[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: AppTheme.foreground,
                            size: 20,
                          ),
                          title: Text(
                            historyItem,
                            style: const TextStyle(color: AppTheme.foreground),
                          ),
                          onTap: () => _performSearch(historyItem),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppTheme.foreground,
                              size: 18,
                            ),
                            onPressed: () async {
                              await SearchHistoryService.removeSearch(
                                historyItem,
                              );
                              setState(() {
                                _searchHistory =
                                    SearchHistoryService.getAllHistory();
                                _filteredHistory =
                                    SearchHistoryService.getFilteredHistory(
                                      _searchController.text,
                                    );
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
