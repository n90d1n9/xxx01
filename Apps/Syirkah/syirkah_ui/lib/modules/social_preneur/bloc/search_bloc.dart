import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kayys_components/search/search_bar.dart';

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState(query: '', results: []));

  void updateQuery(String newQuery) {
    state = SearchState(query: newQuery, results: _search(newQuery));
  }

  List<SearchResultModel> _search(String query) {
    // Mock search function. Replace with your actual search logic.
    return getData()
        .results
        .where((item) => item.title.contains(query))
        .toList();
  }

  SearchState getData() => SearchState(query: 'query', results: [
        SearchResultModel(title: 'apple', category: 'fruit'),
        SearchResultModel(title: 'banana', category: ''),
        SearchResultModel(title: 'cherry', category: ''),
        SearchResultModel(title: 'date', category: ''),
        SearchResultModel(title: 'fig', category: ''),
        SearchResultModel(title: 'grape', category: '')
      ]);
}

/* class SearchState {
  final String query;
  final List<String> results;

  SearchState({required this.query, required this.results});
} */
