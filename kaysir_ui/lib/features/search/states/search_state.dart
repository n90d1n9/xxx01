import '../models/search_result.dart';

// Search State Management
class SearchState {
  final String query;
  final List<String> suggestions;
  final bool isAdvancedSearch;
  final Map<String, dynamic> advancedFilters;
  final List<SearchResult> results;

  SearchState({
    this.query = '',
    this.suggestions = const [],
    this.isAdvancedSearch = false,
    this.advancedFilters = const {},
    this.results = const [],
  });

  SearchState copyWith({
    String? query,
    List<String>? suggestions,
    bool? isAdvancedSearch,
    Map<String, dynamic>? advancedFilters,
    List<SearchResult>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isAdvancedSearch: isAdvancedSearch ?? this.isAdvancedSearch,
      advancedFilters: advancedFilters ?? this.advancedFilters,
      results: results ?? this.results,
    );
  }
}
