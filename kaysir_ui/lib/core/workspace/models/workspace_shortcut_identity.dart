String workspaceShortcutNormalizedId(String value) {
  return _workspaceShortcutIdentityToken(value);
}

String workspaceShortcutUniqueDuplicateId({
  required String shortcutId,
  required Iterable<String> existingIds,
}) {
  final existing = existingIds.toSet();
  final normalizedShortcutId = _workspaceShortcutIdentityToken(shortcutId);
  final baseId =
      normalizedShortcutId.isEmpty ? 'copy' : '${normalizedShortcutId}_copy';
  return _workspaceShortcutUniqueText(
    base: baseId,
    existing: existing,
    separator: '_',
  );
}

String workspaceShortcutUniqueDuplicateLabel({
  required String label,
  required Iterable<String> existingLabels,
}) {
  final trimmedLabel = label.trim();
  final baseLabel =
      trimmedLabel.isEmpty ? 'Saved workspace copy' : '$trimmedLabel copy';
  return _workspaceShortcutUniqueText(
    base: baseLabel,
    existing: existingLabels.toSet(),
  );
}

String _workspaceShortcutUniqueText({
  required String base,
  required Set<String> existing,
  String separator = ' ',
}) {
  var candidate = base;
  var suffix = 2;
  while (existing.contains(candidate)) {
    candidate = '$base$separator$suffix';
    suffix += 1;
  }

  return candidate;
}

String _workspaceShortcutIdentityToken(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return normalized.replaceAll(RegExp(r'_+'), '_');
}
