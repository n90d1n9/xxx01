import 'package:flutter/widgets.dart';

class POSSwitchFilterState<T> extends ChangeNotifier {
  final T initialStatus;
  final TextEditingController searchController;
  T _status;

  POSSwitchFilterState({required this.initialStatus, String initialQuery = ''})
    : _status = initialStatus,
      searchController = TextEditingController(text: initialQuery);

  String get query => searchController.text;

  T get status => _status;

  bool get isAtDefault {
    return query.trim().isEmpty && _status == initialStatus;
  }

  void setQuery(String query) {
    if (searchController.text != query) {
      searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
    notifyListeners();
  }

  void setStatus(T status) {
    if (_status == status) return;

    _status = status;
    notifyListeners();
  }

  void reset() {
    if (isAtDefault) return;

    searchController.clear();
    _status = initialStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
