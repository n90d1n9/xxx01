import '../schema/integration/integration_pattern_template.dart';

class PatternLibraryState {
  final List<IntegrationPatternTemplate> patterns;
  final List<IntegrationPatternTemplate> filteredPatterns;
  final String searchQuery;
  final String? selectedCategory;
  final IntegrationPatternTemplate? selectedPattern;

  PatternLibraryState({
    this.patterns = const [],
    this.filteredPatterns = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedPattern,
  });

  PatternLibraryState copyWith({
    List<IntegrationPatternTemplate>? patterns,
    List<IntegrationPatternTemplate>? filteredPatterns,
    String? searchQuery,
    String? selectedCategory,
    IntegrationPatternTemplate? selectedPattern,
  }) {
    return PatternLibraryState(
      patterns: patterns ?? this.patterns,
      filteredPatterns: filteredPatterns ?? this.filteredPatterns,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPattern: selectedPattern ?? this.selectedPattern,
    );
  }
}
