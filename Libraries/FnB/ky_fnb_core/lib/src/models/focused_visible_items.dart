/// Returns a capped item list that keeps a focused item visible when present.
List<T> fnbFocusedVisibleItems<T>({
  required Iterable<T> items,
  required int limit,
  required String? focusedId,
  required String Function(T item) idOf,
}) {
  assert(limit > 0, 'limit must be greater than zero.');

  final allItems = items.toList(growable: false);
  final visibleItems = allItems.take(limit).toList(growable: true);
  if (focusedId == null || focusedId.isEmpty) {
    return List<T>.unmodifiable(visibleItems);
  }

  for (final item in visibleItems) {
    if (idOf(item) == focusedId) return List<T>.unmodifiable(visibleItems);
  }

  T? focusedItem;
  for (final item in allItems.skip(visibleItems.length)) {
    if (idOf(item) == focusedId) {
      focusedItem = item;
      break;
    }
  }
  if (focusedItem == null) return List<T>.unmodifiable(visibleItems);

  if (visibleItems.length < limit) {
    visibleItems.add(focusedItem);
  } else if (visibleItems.isEmpty) {
    visibleItems.add(focusedItem);
  } else {
    visibleItems[visibleItems.length - 1] = focusedItem;
  }

  return List<T>.unmodifiable(visibleItems);
}

/// Returns visible items, prepending a focused source item when filters hide it.
List<T> fnbVisibleItemsWithFocus<T>({
  required Iterable<T> visibleItems,
  required Iterable<T> sourceItems,
  required String? focusedId,
  required String Function(T item) idOf,
}) {
  final visible = visibleItems.toList(growable: false);
  if (focusedId == null || focusedId.isEmpty) {
    return List<T>.unmodifiable(visible);
  }

  for (final item in visible) {
    if (idOf(item) == focusedId) return List<T>.unmodifiable(visible);
  }

  for (final item in sourceItems) {
    if (idOf(item) == focusedId) {
      return List<T>.unmodifiable([item, ...visible]);
    }
  }

  return List<T>.unmodifiable(visible);
}
