import 'management_pack_field_group.dart';

/// Field visibility modes used by product management pack editors.
enum ProductManagementPackFieldVisibilityMode { all, requiredOnly }

/// Human-facing copy for product management pack field visibility modes.
extension ProductManagementPackFieldVisibilityModeLabels
    on ProductManagementPackFieldVisibilityMode {
  String get label {
    return switch (this) {
      ProductManagementPackFieldVisibilityMode.all => 'All fields',
      ProductManagementPackFieldVisibilityMode.requiredOnly => 'Required only',
    };
  }

  String get tooltip {
    return switch (this) {
      ProductManagementPackFieldVisibilityMode.all =>
        'Show every pack field group',
      ProductManagementPackFieldVisibilityMode.requiredOnly =>
        'Show required pack fields only',
    };
  }
}

/// Resolved field groups and counts for a product management visibility mode.
class ProductManagementPackFieldVisibilitySnapshot {
  ProductManagementPackFieldVisibilitySnapshot({
    required this.mode,
    required List<ProductManagementPackFieldGroup> groups,
    required this.totalFieldCount,
  }) : groups = List.unmodifiable(groups);

  factory ProductManagementPackFieldVisibilitySnapshot.fromGroups({
    required ProductManagementPackFieldVisibilityMode mode,
    required List<ProductManagementPackFieldGroup> groups,
    int? totalFieldCount,
  }) {
    final visibleGroups = resolveProductManagementPackFieldVisibilityGroups(
      mode: mode,
      groups: groups,
    );

    return ProductManagementPackFieldVisibilitySnapshot(
      mode: mode,
      groups: visibleGroups,
      totalFieldCount: totalFieldCount ?? _fieldCount(groups),
    );
  }

  final ProductManagementPackFieldVisibilityMode mode;
  final List<ProductManagementPackFieldGroup> groups;
  final int totalFieldCount;

  int get visibleGroupCount => groups.length;

  int get visibleFieldCount => _fieldCount(groups);

  bool get hasVisibleGroups => groups.isNotEmpty;
}

/// Applies a visibility mode to capability-grouped management pack fields.
List<ProductManagementPackFieldGroup>
resolveProductManagementPackFieldVisibilityGroups({
  required ProductManagementPackFieldVisibilityMode mode,
  required List<ProductManagementPackFieldGroup> groups,
}) {
  return switch (mode) {
    ProductManagementPackFieldVisibilityMode.all => List.unmodifiable(groups),
    ProductManagementPackFieldVisibilityMode.requiredOnly => List.unmodifiable([
      for (final group in groups)
        if (group.requiredFieldCount > 0)
          ProductManagementPackFieldGroup(
            capability: group.capability,
            title: group.title,
            description: group.description,
            fields: group.fields.where((field) => field.required).toList(),
          ),
    ]),
  };
}

int _fieldCount(List<ProductManagementPackFieldGroup> groups) {
  return groups.fold(0, (count, group) => count + group.fieldCount);
}
