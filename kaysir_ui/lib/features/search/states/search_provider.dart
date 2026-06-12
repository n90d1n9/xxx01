import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/search_result.dart';
import 'search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  Future<void> updateQuery(String query) async {
    final normalizedQuery = query.trim();

    state = state.copyWith(query: normalizedQuery);
    if (normalizedQuery.isEmpty) {
      state = state.copyWith(suggestions: const [], results: const []);
      return;
    }

    final suggestions = await _fetchSuggestions(normalizedQuery);
    if (state.query != normalizedQuery) {
      return;
    }

    state = state.copyWith(suggestions: suggestions);
  }

  void toggleAdvancedSearch() {
    state = state.copyWith(isAdvancedSearch: !state.isAdvancedSearch);
  }

  void updateAdvancedFilters(Map<String, dynamic> filters) {
    state = state.copyWith(advancedFilters: filters);
  }

  Future<void> performSearch() async {
    final query = state.query.trim();
    if (query.isEmpty) {
      state = state.copyWith(results: const []);
      return;
    }

    final results = await _fetchSearchResults(query, state.advancedFilters);
    if (state.query != query) {
      return;
    }

    state = state.copyWith(results: results);
  }

  // Mock methods - replace with actual API calls
  Future<List<String>> _fetchSuggestions(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      '$query Suggestion 1',
      '$query Suggestion 2',
      '$query Suggestion 3',
    ];
  }

  Future<List<SearchResult>> _fetchSearchResults(
    String query,
    Map<String, dynamic> filters,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      SearchResult(
        title: 'Result 1',
        description: 'Description for Result 1',
        category: 'Category A',
        imageUrl: 'https://example.com/image1.jpg',
      ),
      SearchResult(
        title: 'Result 2',
        description: 'Description for Result 2',
        category: 'Category B',
        imageUrl: 'https://example.com/image2.jpg',
      ),
    ];
  }
}

// Providers
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier();
});
