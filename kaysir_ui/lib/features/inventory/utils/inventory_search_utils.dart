String normalizeInventorySearchQuery(String? query) {
  return (query ?? '').trim().toLowerCase();
}

bool inventorySearchMatchesAny(String? query, Iterable<String?> candidates) {
  return inventorySearchMatchesAnyNormalized(
    normalizeInventorySearchQuery(query),
    candidates,
  );
}

bool inventorySearchMatchesAnyNormalized(
  String normalizedQuery,
  Iterable<String?> candidates,
) {
  if (normalizedQuery.isEmpty) return true;

  for (final candidate in candidates) {
    if (normalizeInventorySearchQuery(candidate).contains(normalizedQuery)) {
      return true;
    }
  }

  return false;
}
