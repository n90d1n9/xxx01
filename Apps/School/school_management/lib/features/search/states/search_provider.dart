import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_result.dart';
import 'search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  void updateQuery(String query) async {
    // Simulate fetching suggestions
    final suggestions = await _fetchSuggestions(query);
    state = state.copyWith(query: query, suggestions: suggestions);
  }

  void toggleAdvancedSearch() {
    state = state.copyWith(isAdvancedSearch: !state.isAdvancedSearch);
  }

  void updateAdvancedFilters(Map<String, dynamic> filters) {
    state = state.copyWith(advancedFilters: filters);
  }

  void performSearch() async {
    // Simulate search with advanced filters
    final results =
        await _fetchSearchResults(state.query, state.advancedFilters);
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
      String query, Map<String, dynamic> filters) async {
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
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
