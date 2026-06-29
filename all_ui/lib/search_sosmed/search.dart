import 'package:http/http.dart' as http;
import 'dart:convert';

// Abstract base class for search services
abstract class SearchService {
  Future<List<SearchItem>> search(String query);
}

// YouTube search service
class YouTubeSearchService implements SearchService {
  final String apiKey;

  YouTubeSearchService({required this.apiKey});

  @override
  Future<List<SearchItem>> search(String query) async {
    final Uri url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'];

      return items.map((item) {
        final snippet = item['snippet'];
        final videoId = item['id']['videoId'];

        return SearchItem(
          title: snippet['title'],
          description: snippet['description'],
          url: 'https://www.youtube.com/watch?v=$videoId',
          thumbnailUrl: snippet['thumbnails']['medium']['url'],
          source: 'YouTube',
        );
      }).toList();
    } else {
      throw Exception('Failed to load YouTube search results');
    }
  }
}

// WordPress search service
class WordPressSearchService implements SearchService {
  final String siteUrl;

  WordPressSearchService({required this.siteUrl});

  @override
  Future<List<SearchItem>> search(String query) async {
    // Ensure URL ends with /wp-json
    final baseUrl =
        siteUrl.endsWith('/') ? '${siteUrl}wp-json' : '$siteUrl/wp-json';
    final Uri url = Uri.parse('$baseUrl/wp/v2/posts?search=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> posts = json.decode(response.body);

      return posts.map((post) {
        String? featuredMediaUrl;
        if (post['featured_media'] != null && post['featured_media'] != 0) {
          featuredMediaUrl =
              post['_embedded']?['wp:featuredmedia']?[0]?['source_url'];
        }

        return SearchItem(
          title: post['title']['rendered'],
          description: post['excerpt']['rendered'],
          url: post['link'],
          thumbnailUrl: featuredMediaUrl,
          source: 'WordPress',
        );
      }).toList();
    } else {
      throw Exception('Failed to load WordPress search results');
    }
  }
}

// Blogger search service
class BloggerSearchService implements SearchService {
  final String apiKey;
  final String blogId;

  BloggerSearchService({required this.apiKey, required this.blogId});

  @override
  Future<List<SearchItem>> search(String query) async {
    final Uri url = Uri.parse(
      'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts/search?q=$query&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'] ?? [];

      return items.map((item) {
        return SearchItem(
          title: item['title'],
          description:
              item['content'].toString().length > 100
                  ? '${item['content'].toString().substring(0, 100)}...'
                  : item['content'].toString(),
          url: item['url'],
          thumbnailUrl: _extractFirstImage(item['content']),
          source: 'Blogger',
        );
      }).toList();
    } else {
      throw Exception('Failed to load Blogger search results');
    }
  }

  String? _extractFirstImage(String htmlContent) {
    // Basic regex to extract first image src
    final imgRegex = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = imgRegex.firstMatch(htmlContent);
    return match?.group(1);
  }
}

// Universal search service that combines results
class UnifiedSearchService {
  final YouTubeSearchService? youtubeService;
  final WordPressSearchService? wordpressService;
  final BloggerSearchService? bloggerService;

  UnifiedSearchService({
    this.youtubeService,
    this.wordpressService,
    this.bloggerService,
  });

  Future<Map<String, List<SearchItem>>> searchAll(String query) async {
    final results = <String, List<SearchItem>>{};

    // Run searches in parallel
    final futures = <Future>[];

    if (youtubeService != null) {
      futures.add(
        youtubeService!
            .search(query)
            .then((items) {
              results['YouTube'] = items;
            })
            .catchError((e) {
              print('YouTube search error: $e');
              results['YouTube'] = [];
            }),
      );
    }

    if (wordpressService != null) {
      futures.add(
        wordpressService!
            .search(query)
            .then((items) {
              results['WordPress'] = items;
            })
            .catchError((e) {
              print('WordPress search error: $e');
              results['WordPress'] = [];
            }),
      );
    }

    if (bloggerService != null) {
      futures.add(
        bloggerService!
            .search(query)
            .then((items) {
              results['Blogger'] = items;
            })
            .catchError((e) {
              print('Blogger search error: $e');
              results['Blogger'] = [];
            }),
      );
    }

    await Future.wait(futures);
    return results;
  }

  Future<List<SearchItem>> search(String query, SearchPlatform platform) async {
    switch (platform) {
      case SearchPlatform.youtube:
        if (youtubeService == null)
          throw Exception('YouTube service not configured');
        return youtubeService!.search(query);
      case SearchPlatform.wordpress:
        if (wordpressService == null)
          throw Exception('WordPress service not configured');
        return wordpressService!.search(query);
      case SearchPlatform.blogger:
        if (bloggerService == null)
          throw Exception('Blogger service not configured');
        return bloggerService!.search(query);
      case SearchPlatform.all:
        final allResults = await searchAll(query);
        return allResults.values.expand((x) => x).toList();
    }
  }
}

// Search result item model
class SearchItem {
  final String title;
  final String description;
  final String url;
  final String? thumbnailUrl;
  final String source;

  SearchItem({
    required this.title,
    required this.description,
    required this.url,
    this.thumbnailUrl,
    required this.source,
  });
}

// Enum for search platforms (duplicated from previous code)
enum SearchPlatform { youtube, wordpress, blogger, all }
