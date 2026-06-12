import 'package:ky_fnb_core/ky_fnb_core.dart';

/// Restaurant-facing wrapper for shared focused capped lists.
List<T> restaurantFocusedVisibleItems<T>({
  required Iterable<T> items,
  required int limit,
  required String? focusedId,
  required String Function(T item) idOf,
}) {
  return fnbFocusedVisibleItems(
    items: items,
    limit: limit,
    focusedId: focusedId,
    idOf: idOf,
  );
}

/// Restaurant-facing wrapper for focused items hidden by filters.
List<T> restaurantVisibleItemsWithFocus<T>({
  required Iterable<T> visibleItems,
  required Iterable<T> sourceItems,
  required String? focusedId,
  required String Function(T item) idOf,
}) {
  return fnbVisibleItemsWithFocus(
    visibleItems: visibleItems,
    sourceItems: sourceItems,
    focusedId: focusedId,
    idOf: idOf,
  );
}
