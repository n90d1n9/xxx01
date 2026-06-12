import 'management_pack.dart';
import 'management_pack_field_expansion_state.dart';
import 'management_pack_field_group.dart';
import 'management_pack_field_group_progress.dart';
import 'management_pack_field_visibility_mode.dart';
import 'product_form_section.dart';

/// Complete render state for a product management pack field editor.
class ProductManagementPackFieldViewState {
  ProductManagementPackFieldViewState._({
    required List<ProductManagementPackField> fields,
    required List<ProductManagementPackFieldGroup> groups,
    required this.visibility,
    required this.expansion,
    required Map<ProductManagementCapability, bool> expandedCapabilities,
  }) : fields = List.unmodifiable(fields),
       groups = List.unmodifiable(groups),
       expandedCapabilities = Map.unmodifiable(expandedCapabilities);

  factory ProductManagementPackFieldViewState.fromPack({
    required ProductManagementPack pack,
    required ProductManagementPackFieldVisibilityMode visibilityMode,
    required Map<ProductManagementCapability, bool> expandedCapabilities,
    ProductManagementPackFieldGroupProgressOverview? groupProgress,
    ProductManagementFieldId? focusedFieldId,
  }) {
    final fields = productManagementPackEditableFields(pack);
    final groups = buildProductManagementPackFieldGroups(pack);

    return ProductManagementPackFieldViewState.fromGroups(
      fields: fields,
      groups: groups,
      visibilityMode: visibilityMode,
      expandedCapabilities: expandedCapabilities,
      groupProgress: groupProgress,
      focusedFieldId: focusedFieldId,
    );
  }

  factory ProductManagementPackFieldViewState.fromGroups({
    required List<ProductManagementPackField> fields,
    required List<ProductManagementPackFieldGroup> groups,
    required ProductManagementPackFieldVisibilityMode visibilityMode,
    required Map<ProductManagementCapability, bool> expandedCapabilities,
    ProductManagementPackFieldGroupProgressOverview? groupProgress,
    ProductManagementFieldId? focusedFieldId,
  }) {
    final visibility = ProductManagementPackFieldVisibilitySnapshot.fromGroups(
      mode: visibilityMode,
      groups: groups,
      totalFieldCount: fields.length,
    );
    final normalizedExpandedCapabilities =
        resolveProductManagementPackFieldExpansionState(
          groups: groups,
          expandedCapabilities: expandedCapabilities,
          groupProgress: groupProgress,
          focusedFieldId: focusedFieldId,
        );
    final expansion = ProductManagementPackFieldExpansionSnapshot(
      groups: visibility.groups,
      visibilityMode: visibilityMode,
      expandedCapabilities: normalizedExpandedCapabilities,
      groupProgress: groupProgress,
    );

    return ProductManagementPackFieldViewState._(
      fields: fields,
      groups: groups,
      visibility: visibility,
      expansion: expansion,
      expandedCapabilities: normalizedExpandedCapabilities,
    );
  }

  final List<ProductManagementPackField> fields;
  final List<ProductManagementPackFieldGroup> groups;
  final ProductManagementPackFieldVisibilitySnapshot visibility;
  final ProductManagementPackFieldExpansionSnapshot expansion;
  final Map<ProductManagementCapability, bool> expandedCapabilities;

  bool get hasEditableFields => fields.isNotEmpty;
  bool get hasVisibleGroups => visibility.hasVisibleGroups;
  int get totalFieldCount => visibility.totalFieldCount;
  int get totalGroupCount => groups.length;
  int get visibleFieldCount => visibility.visibleFieldCount;
  int get visibleGroupCount => visibility.visibleGroupCount;
  int get expandedGroupCount => expansion.expandedGroupCount;
  int get lockedOpenGroupCount => expansion.lockedOpenGroupCount;
  bool get canExpandAll => expansion.canExpandAll;
  bool get canCollapseReady => expansion.canCollapseReady;

  List<ProductManagementPackFieldGroup> get visibleGroups => visibility.groups;

  bool isExpanded(ProductManagementPackFieldGroup group) {
    return expansion.isExpanded(group);
  }

  bool canCollapse(ProductManagementPackFieldGroup group) {
    return expansion.canCollapse(group);
  }

  Map<ProductManagementCapability, bool> withGroupExpanded(
    ProductManagementPackFieldGroup group,
    bool isExpanded,
  ) {
    return expansion.withGroupExpanded(group, isExpanded);
  }

  Map<ProductManagementCapability, bool> expandAll() {
    return expansion.expandAll();
  }

  Map<ProductManagementCapability, bool> collapseReady() {
    return expansion.collapseReady();
  }

  ProductManagementPackFieldGroupProgress? progressFor(
    ProductManagementCapability capability,
  ) {
    final progress = expansion.groupProgress;
    if (progress == null) return null;

    for (final groupProgress in progress.groups) {
      if (groupProgress.group.capability == capability) return groupProgress;
    }

    return null;
  }
}
