import 'inventory_product_catalog_presentation_state.dart';

class InventoryProductCatalogSavedView {
  const InventoryProductCatalogSavedView({
    required this.id,
    required this.label,
    required this.presentationState,
    this.description = '',
  });

  factory InventoryProductCatalogSavedView.fromJson(Map<String, Object?> json) {
    final id = json[_idJsonKey]?.toString().trim();
    final label = json[_labelJsonKey]?.toString().trim();

    return InventoryProductCatalogSavedView(
      id: id == null || id.isEmpty ? fallbackId : id,
      label: label == null || label.isEmpty ? fallbackLabel : label,
      description: json[_descriptionJsonKey]?.toString().trim() ?? '',
      presentationState: InventoryProductCatalogPresentationState.fromJson(
        _objectMap(json[_presentationStateJsonKey]),
      ),
    );
  }

  static const fallbackId = 'saved-view';
  static const fallbackLabel = 'Saved view';
  static const _idJsonKey = 'id';
  static const _labelJsonKey = 'label';
  static const _descriptionJsonKey = 'description';
  static const _presentationStateJsonKey = 'presentationState';

  final String id;
  final String label;
  final String description;
  final InventoryProductCatalogPresentationState presentationState;

  InventoryProductCatalogSavedView copyWith({
    String? id,
    String? label,
    String? description,
    InventoryProductCatalogPresentationState? presentationState,
  }) {
    return InventoryProductCatalogSavedView(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      presentationState: presentationState ?? this.presentationState,
    );
  }

  Map<String, Object?> toJson() {
    return {
      _idJsonKey: id,
      _labelJsonKey: label,
      if (description.trim().isNotEmpty) _descriptionJsonKey: description,
      _presentationStateJsonKey: presentationState.normalized.toJson(),
    };
  }

  bool matches(InventoryProductCatalogSavedView other) {
    return id == other.id &&
        label == other.label &&
        description == other.description &&
        presentationState.matches(other.presentationState);
  }
}

List<InventoryProductCatalogSavedView>
normalizeInventoryProductCatalogSavedViews(
  Iterable<InventoryProductCatalogSavedView> views,
) {
  final byId = <String, InventoryProductCatalogSavedView>{};
  for (final view in views) {
    final id = view.id.trim();
    final label = view.label.trim();
    if (id.isEmpty || label.isEmpty) continue;

    byId[id] = InventoryProductCatalogSavedView(
      id: id,
      label: label,
      description: view.description.trim(),
      presentationState: view.presentationState.normalized,
    );
  }

  return List.unmodifiable(byId.values);
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is! Map) return const {};

  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}
