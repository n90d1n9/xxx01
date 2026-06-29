import 'package:flutter/material.dart';
import 'package:google_mlkit_language/google_mlkit_language.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Import the search services
import 'entity.dart';
import 'search_services.dart';

void main() {
  runApp(const UnifiedSearchApp());
}

class UnifiedSearchApp extends StatelessWidget {
  const UnifiedSearchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unified Search',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SearchQueryExtractor _extractor = SearchQueryExtractor();
  late TabController _tabController;

  // Search state
  bool _isLoading = false;
  String _extractedQuery = '';
  SearchPlatform _selectedPlatform = SearchPlatform.all;
  Map<String, List<SearchItem>> _searchResults = {};
  String _errorMessage = '';

  // Services
  late UnifiedSearchService _unifiedSearchService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize search services - replace with your API keys
    _unifiedSearchService = UnifiedSearchService(
      youtubeService: YouTubeSearchService(apiKey: 'YOUR_YOUTUBE_API_KEY'),
      wordpressService: WordPressSearchService(
        siteUrl: 'https://your-wordpress-site.com',
      ),
      bloggerService: BloggerSearchService(
        apiKey: 'YOUR_BLOGGER_API_KEY',
        blogId: 'YOUR_BLOG_ID',
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final userInput = _searchController.text;
    if (userInput.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Extract the search query using MLKit
      final searchResult = await _extractor.extractSearchQuery(userInput);

      _extractedQuery = searchResult.query;
      _selectedPlatform = searchResult.platform;

      // Set tab based on platform
      switch (_selectedPlatform) {
        case SearchPlatform.youtube:
          _tabController.animateTo(1);
          break;
        case SearchPlatform.wordpress:
          _tabController.animateTo(2);
          break;
        case SearchPlatform.blogger:
          _tabController.animateTo(3);
          break;
        case SearchPlatform.all:
          _tabController.animateTo(0);
          break;
      }

      // Execute search
      final results = await _unifiedSearchService.searchAll(_extractedQuery);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Search error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'YouTube'),
            Tab(text: 'WordPress'),
            Tab(text: 'Blogger'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter natural language search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Extracted query display
          if (_extractedQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Extracted query: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      '"$_extractedQuery"',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Error message
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          // Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Results Tab
                _buildResultsList(
                  _searchResults.values.expand((x) => x).toList(),
                ),

                // YouTube Results Tab
                _buildResultsList(_searchResults['YouTube'] ?? []),

                // WordPress Results Tab
                _buildResultsList(_searchResults['WordPress'] ?? []),

                // Blogger Results Tab
                _buildResultsList(_searchResults['Blogger'] ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchItem> results) {
    if (results.isEmpty && !_isLoading && _extractedQuery.isNotEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            leading:
                item.thumbnailUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.thumbnailUrl!,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (ctx, _, __) => Container(
                              width: 80,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                      ),
                    )
                    : null,
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Source: ${item.source}',
                  style: TextStyle(
                    color: _getSourceColor(item.source),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Open the URL (you'd use url_launcher package in a real app)
              _showUrlDialog(context, item);
            },
          ),
        );
      },
    );
  }

  void _showUrlDialog(BuildContext context, SearchItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(item.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Would open URL:'),
                const SizedBox(height: 8),
                Text(
                  item.url,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'In a real app, this would open using the url_launcher package.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source) {
      case 'YouTube':
        return Colors.red;
      case 'WordPress':
        return Colors.blue;
      case 'Blogger':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Search query extractor class
class SearchQueryExtractor {
  Future<SearchResult> extractSearchQuery(String input) async {
    try {
      // Detect language
      final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
      final language = await languageIdentifier.identifyLanguage(input);

      // Extract entities (simplified for demo - in a real app you'd use more robust NLP)
      // In this simplified version, we'll use our basic extraction as MLKit entity extraction
      // requires additional setup that's beyond the scope of this example
      final String searchQuery = _basicExtraction(input);

      // Determine the search platform based on keywords in the input
      final platform = _determinePlatform(input);

      return SearchResult(
        query: searchQuery,
        platform: platform,
        originalInput: input,
      );
    } catch (e) {
      // Fallback to basic extraction
      return SearchResult(
        query: _basicExtraction(input),
        platform: _determinePlatform(input),
        originalInput: input,
      );
    }
  }

  String _basicExtraction(String input) {
    // Basic extraction logic
    return input
        .toLowerCase()
        .replaceAll(
          RegExp(
            r'\b(search for|find|show me|look up|on youtube|on wordpress|on blogger)\b',
          ),
          '',
        )
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }

  SearchPlatform _determinePlatform(String input) {
    final lowercaseInput = input.toLowerCase();

    if (lowercaseInput.contains('youtube') ||
        lowercaseInput.contains('video') ||
        lowercaseInput.contains('watch')) {
      return SearchPlatform.youtube;
    } else if (lowercaseInput.contains('wordpress') ||
        lowercaseInput.contains('blog post') ||
        lowercaseInput.contains('article')) {
      return SearchPlatform.wordpress;
    } else if (lowercaseInput.contains('blogger')) {
      return SearchPlatform.blogger;
    }

    return SearchPlatform.all;
  }
}

class SearchResult {
  final String query;
  final SearchPlatform platform;
  final String originalInput;

  SearchResult({
    required this.query,
    required this.platform,
    required this.originalInput,
  });
}
