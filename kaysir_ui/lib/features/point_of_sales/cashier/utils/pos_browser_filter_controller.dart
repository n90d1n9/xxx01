import 'package:flutter/widgets.dart';

class POSBrowserFilterController<T extends Object> {
  final TextEditingController searchController;
  T _initialFilter;
  T _filter;

  POSBrowserFilterController({
    required T initialFilter,
    String initialQuery = '',
  }) : _initialFilter = initialFilter,
       _filter = initialFilter,
       searchController = TextEditingController(text: initialQuery.trim());

  T get initialFilter => _initialFilter;

  T get filter => _filter;

  String get query => searchController.text;

  String get normalizedQuery => query.trim();

  bool get hasQuery => normalizedQuery.isNotEmpty;

  bool get isAtInitialState => _filter == _initialFilter && !hasQuery;

  bool setFilter(T filter) {
    if (_filter == filter) return false;

    _filter = filter;
    return true;
  }

  bool setQuery(String query) {
    if (searchController.text == query) return false;

    _setSearchText(query);
    return true;
  }

  bool clearSearch() {
    return setQuery('');
  }

  bool reset({T? filter, String query = ''}) {
    var changed = false;
    final nextFilter = filter ?? _initialFilter;
    final nextQuery = query.trim();

    if (_filter != nextFilter) {
      _filter = nextFilter;
      changed = true;
    }

    if (searchController.text != nextQuery) {
      _setSearchText(nextQuery);
      changed = true;
    }

    return changed;
  }

  bool replaceInitial({
    required T initialFilter,
    String initialQuery = '',
    bool apply = true,
  }) {
    _initialFilter = initialFilter;
    if (!apply) return false;

    return reset(filter: initialFilter, query: initialQuery);
  }

  void dispose() {
    searchController.dispose();
  }

  void _setSearchText(String value) {
    searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}
