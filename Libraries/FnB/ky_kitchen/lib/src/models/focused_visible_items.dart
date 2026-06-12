import 'package:ky_fnb_core/ky_fnb_core.dart';

/// Kitchen-facing wrapper for shared focused capped lists.
List<T> kitchenFocusedVisibleItems<T>({
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
