/// Identifies the kind of panel item that should receive workspace focus.
enum RestaurantWorkspacePanelFocusKind {
  floorZone,
  reservation,
  kitchenStation,
  menuSignal,
  menuCatalogItem,
  recipeProduction,
  shiftTask,
  serviceAlert,
  custom,
}

/// Stores the exact panel item targeted by a workspace navigation action.
class RestaurantWorkspacePanelFocus {
  const RestaurantWorkspacePanelFocus({
    required this.kind,
    required this.targetId,
    this.sourceId,
  }) : assert(targetId != '', 'targetId must not be empty.');

  static RestaurantWorkspacePanelFocus? fromJson(Map<String, Object?>? json) {
    if (json == null) return null;

    final kind = _enumValue(
      RestaurantWorkspacePanelFocusKind.values,
      json['kind'],
    );
    final targetId = _stringValue(json['targetId']);
    if (kind == null || targetId == null || targetId.isEmpty) return null;

    return RestaurantWorkspacePanelFocus(
      kind: kind,
      targetId: targetId,
      sourceId: _stringValue(json['sourceId']),
    );
  }

  final RestaurantWorkspacePanelFocusKind kind;
  final String targetId;
  final String? sourceId;

  bool matches({
    required RestaurantWorkspacePanelFocusKind kind,
    required String targetId,
  }) {
    return this.kind == kind && this.targetId == targetId;
  }

  Map<String, Object?> toJson() {
    return {'kind': kind.name, 'targetId': targetId, 'sourceId': ?sourceId};
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RestaurantWorkspacePanelFocus &&
            other.kind == kind &&
            other.targetId == targetId &&
            other.sourceId == sourceId;
  }

  @override
  int get hashCode => Object.hash(kind, targetId, sourceId);
}

T? _enumValue<T extends Enum>(List<T> values, Object? value) {
  if (value is! String) return null;
  for (final item in values) {
    if (item.name == value) return item;
  }
  return null;
}

String? _stringValue(Object? value) {
  return value is String ? value : null;
}
