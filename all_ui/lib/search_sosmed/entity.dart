import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class SearchQueryExtractor {
  Future<SearchResult> extractSearchQuery(String input) async {
    // Detect language
    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    final language = await languageIdentifier.identifyLanguage(input);

    // Extract entities
    final entityExtractor = EntityExtractor(language: language);
    final entities = await entityExtractor.extractEntities(input);

    // Combine entities into a search query
    final String searchQuery = entities.map((e) => e.text).join(' ');

    // Fallback to basic extraction if no entities found
    final String finalQuery =
        searchQuery.isEmpty ? _basicExtraction(input) : searchQuery;

    // Determine the search platform based on keywords in the input
    final platform = _determinePlatform(input);

    return SearchResult(
      query: finalQuery,
      platform: platform,
      originalInput: input,
    );
  }

  String _basicExtraction(String input) {
    // Basic extraction logic for fallback
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

enum SearchPlatform { youtube, wordpress, blogger, all }

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
