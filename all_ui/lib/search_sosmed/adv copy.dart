import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language.dart';

class AdvancedSearchQueryExtractor {
  // Keywords that help identify the platform intent
  static const Map<SearchPlatform, List<String>> _platformKeywords = {
    SearchPlatform.youtube: [
      'youtube',
      'video',
      'watch',
      'channel',
      'playlist',
      'subscribe',
      'youtuber',
      'tube',
      'streaming',
      'streamer',
      'film',
      'movie',
    ],
    SearchPlatform.wordpress: [
      'wordpress',
      'blog',
      'post',
      'article',
      'website',
      'page',
      'content',
      'writer',
      'writing',
      'blogger',
      'publish',
    ],
    SearchPlatform.blogger: ['blogger', 'blogspot', 'blog post', 'blog entry'],
  };

  // Common phrases to strip out for cleaner extraction
  static const List<String> _commonPhrases = [
    'search for',
    'find',
    'show me',
    'look up',
    'how to',
    'what is',
    'who is',
    'tell me about',
    'i want to see',
    'can you show',
    'please find',
    'i need information on',
    'get me',
    'locate',
    'results for',
    'videos about',
    'articles about',
    'blogs about',
    'posts on',
    'information about',
    'details on',
    'data regarding',
  ];

  // Action verbs that indicate search intent
  static const List<String> _actionVerbs = [
    'search',
    'find',
    'look',
    'get',
    'show',
    'display',
    'retrieve',
    'query',
    'seek',
    'hunt',
    'locate',
    'discover',
    'uncover',
    'explore',
  ];

  // Cache the language identifier to avoid recreating it
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(
    confidenceThreshold: 0.5,
  );

  // Optional: You can add an on-device entity extractor when available for your use case
  // final EntityExtractor _entityExtractor = EntityExtractor(language: 'en');

  Future<SearchExtraction> extractSearchQuery(String input) async {
    try {
      // Start with the original input
      String originalInput = input.trim();

      // Detect language if available
      String language = 'en'; // Default to English
      try {
        language = await _languageIdentifier.identifyLanguage(input);
        // If language identification fails or returns "und" (undetermined), default to English
        if (language == 'und') language = 'en';
      } catch (e) {
        // Language identification failed, continue with default
        debugPrint('Language identification failed: $e');
      }

      // Clean input by removing punctuation and excess whitespace
      String cleanedInput = _cleanText(input);

      // First attempt: Try to identify specific search patterns
      final RegExpMatch? searchPattern = RegExp(
        r'(?:search|find|look up|show)\s+(?:for|me)?\s+(.+?)(?:\s+on\s+(youtube|wordpress|blogger))?$',
        caseSensitive: false,
      ).firstMatch(cleanedInput);

      String extractedQuery = '';
      SearchPlatform detectedPlatform = SearchPlatform.all;

      if (searchPattern != null) {
        // Extract the query from the pattern
        extractedQuery = searchPattern.group(1) ?? '';

        // Check if platform is specified in the pattern
        if (searchPattern.group(2) != null) {
          String platformStr = searchPattern.group(2)!.toLowerCase();
          if (platformStr == 'youtube') {
            detectedPlatform = SearchPlatform.youtube;
          } else if (platformStr == 'wordpress') {
            detectedPlatform = SearchPlatform.wordpress;
          } else if (platformStr == 'blogger') {
            detectedPlatform = SearchPlatform.blogger;
          }
        }
      } else {
        // Second attempt: More general extraction
        extractedQuery = _extractGeneralQuery(cleanedInput);

        // Determine platform from keywords
        detectedPlatform = _determinePlatform(cleanedInput);
      }

      // Process the extracted query to make it cleaner
      extractedQuery = _processExtractedQuery(extractedQuery);

      // Calculate confidence based on various factors
      double confidence = _calculateConfidence(
        originalQuery: originalInput,
        extractedQuery: extractedQuery,
        hasPatternMatch: searchPattern != null,
      );

      return SearchExtraction(
        originalInput: originalInput,
        extractedQuery: extractedQuery,
        platform: detectedPlatform,
        confidence: confidence,
        language: language,
      );
    } catch (e) {
      // Fallback to basic extraction in case of any errors
      debugPrint('Advanced extraction failed, falling back to basic: $e');
      return _basicExtraction(input);
    }
  }

  // Basic fallback extraction method
  SearchExtraction _basicExtraction(String input) {
    final String originalInput = input.trim();

    // Simple cleaning and extraction
    String extractedQuery = input.toLowerCase();

    // Remove common phrases
    for (final phrase in _commonPhrases) {
      extractedQuery = extractedQuery.replaceAll(
        RegExp('\\b$phrase\\b', caseSensitive: false),
        ' ',
      );
    }

    // Clean up
    extractedQuery =
        extractedQuery
            .replaceAll(RegExp(r'[^\w\s]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    // Determine platform from keywords
    final platform = _determinePlatform(input);

    return SearchExtraction(
      originalInput: originalInput,
      extractedQuery: extractedQuery,
      platform: platform,
      confidence: 0.5, // Medium confidence for basic extraction
      language: 'en', // Default to English
    );
  }

  // Clean text by removing punctuation and normalizing spaces
  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase()
        .trim();
  }

  // Extract query using a more general approach
  String _extractGeneralQuery(String input) {
    String result = input;

    // Remove common phrases
    for (final phrase in _commonPhrases) {
      result = result.replaceAll(
        RegExp('\\b$phrase\\b', caseSensitive: false),
        ' ',
      );
    }

    // Remove platform-specific keywords
    for (final entry in _platformKeywords.entries) {
      for (final keyword in entry.value) {
        result = result.replaceAll(
          RegExp('\\b$keyword\\b', caseSensitive: false),
          ' ',
        );
      }
    }

    // Remove action verbs
    for (final verb in _actionVerbs) {
      result = result.replaceAll(
        RegExp('\\b$verb\\b', caseSensitive: false),
        ' ',
      );
    }

    return result.trim();
  }

  // Process the extracted query to make it cleaner
  String _processExtractedQuery(String query) {
    // Remove extra spaces and trailing punctuation
    String processed =
        query
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'[^\w\s]$'), '')
            .trim();

    // If query became empty after processing, return the original
    return processed.isEmpty ? query : processed;
  }

  // Identify the intended platform from keywords
  SearchPlatform _determinePlatform(String input) {
    final String lowercaseInput = input.toLowerCase();

    // Check for explicit platform mentions
    Map<SearchPlatform, int> platformScores = {};

    // Initialize scores
    for (final platform in SearchPlatform.values) {
      platformScores[platform] = 0;
    }

    // Calculate scores based on keyword matches
    for (final entry in _platformKeywords.entries) {
      final platform = entry.key;
      final keywords = entry.value;

      for (final keyword in keywords) {
        if (lowercaseInput.contains(keyword)) {
          platformScores[platform] = (platformScores[platform] ?? 0) + 1;
        }
      }
    }

    // Find platform with highest score
    SearchPlatform bestMatch = SearchPlatform.all;
    int highestScore = 0;

    platformScores.forEach((platform, score) {
      if (platform != SearchPlatform.all && score > highestScore) {
        highestScore = score;
        bestMatch = platform;
      }
    });

    return bestMatch;
  }

  // Calculate confidence score for the extraction
  double _calculateConfidence({
    required String originalQuery,
    required String extractedQuery,
    required bool hasPatternMatch,
  }) {
    // Base confidence
    double confidence = 0.5;

    // Adjust based on factors
    if (hasPatternMatch) {
      confidence += 0.3; // Clear pattern match is good
    }

    // Check if the extracted query is too short
    if (extractedQuery.split(' ').length < 2) {
      confidence -= 0.2;
    }

    // Check if too much was removed
    final double retentionRatio = extractedQuery.length / originalQuery.length;
    if (retentionRatio < 0.3) {
      confidence -= 0.1;
    } else if (retentionRatio > 0.8) {
      confidence -= 0.1; // Might not have removed enough
    }

    // Ensure confidence is within bounds
    return confidence.clamp(0.0, 1.0);
  }
}

// Model for search extraction results
class SearchExtraction {
  final String originalInput;
  final String extractedQuery;
  final SearchPlatform platform;
  final double confidence;
  final String language;

  SearchExtraction({
    required this.originalInput,
    required this.extractedQuery,
    required this.platform,
    required this.confidence,
    required this.language,
  });

  @override
  String toString() {
    return 'SearchExtraction(query: "$extractedQuery", platform: $platform, confidence: ${(confidence * 100).toStringAsFixed(1)}%, language: $language)';
  }
}

// Enum for search platforms (duplicated here for clarity)
enum SearchPlatform { youtube, wordpress, blogger, all }
