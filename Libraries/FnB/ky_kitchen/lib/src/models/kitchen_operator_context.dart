/// Identifies the kitchen operator responsible for auditable handoff actions.
class KitchenOperatorContext {
  const KitchenOperatorContext({
    required this.id,
    required this.displayName,
    this.roleLabel,
    this.stationId,
  });

  /// Builds an operator context from a display label when no staff id exists.
  factory KitchenOperatorContext.fromLabel(String label) {
    final displayName = label.trim().isEmpty ? 'Kitchen' : label.trim();

    return KitchenOperatorContext(
      id: _labelId(displayName),
      displayName: displayName,
    );
  }

  /// Default expo operator used when no authenticated staff context is wired.
  static const expo = KitchenOperatorContext(
    id: 'expo',
    displayName: 'Expo',
    roleLabel: 'Expo',
  );

  final String id;
  final String displayName;
  final String? roleLabel;
  final String? stationId;

  String get normalizedId {
    final value = id.trim();
    return value.isEmpty ? _labelId(verifierLabel) : value;
  }

  String get verifierLabel {
    final label = displayName.trim();
    return label.isEmpty ? 'Kitchen' : label;
  }

  String? get roleBadgeLabel {
    final label = roleLabel?.trim();
    return label == null || label.isEmpty ? null : label;
  }

  KitchenOperatorContext copyWith({
    String? id,
    String? displayName,
    String? roleLabel,
    String? stationId,
  }) {
    return KitchenOperatorContext(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      roleLabel: roleLabel ?? this.roleLabel,
      stationId: stationId ?? this.stationId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is KitchenOperatorContext &&
        other.id == id &&
        other.displayName == displayName &&
        other.roleLabel == roleLabel &&
        other.stationId == stationId;
  }

  @override
  int get hashCode => Object.hash(id, displayName, roleLabel, stationId);
}

String _labelId(String label) {
  final id = label
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return id.isEmpty ? 'kitchen' : id;
}
