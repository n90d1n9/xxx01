import 'management_pack.dart';
import 'management_pack_field_group.dart';
import 'management_pack_field_group_progress.dart';
import 'management_pack_field_visibility_mode.dart';

/// Expansion decisions for visible product management pack field groups.
class ProductManagementPackFieldExpansionSnapshot {
  ProductManagementPackFieldExpansionSnapshot({
    required List<ProductManagementPackFieldGroup> groups,
    required this.visibilityMode,
    required Map<ProductManagementCapability, bool> expandedCapabilities,
    this.groupProgress,
  }) : groups = List.unmodifiable(groups),
       expandedCapabilities = Map.unmodifiable(expandedCapabilities);

  final List<ProductManagementPackFieldGroup> groups;
  final ProductManagementPackFieldVisibilityMode visibilityMode;
  final Map<ProductManagementCapability, bool> expandedCapabilities;
  final ProductManagementPackFieldGroupProgressOverview? groupProgress;

  int get expandedGroupCount {
    return groups.where(isExpanded).length;
  }

  int get lockedOpenGroupCount {
    return groups.where((group) => !canCollapse(group)).length;
  }

  bool get canExpandAll => expandedGroupCount < groups.length;

  bool get canCollapseReady {
    return groups.any((group) => canCollapse(group) && isExpanded(group));
  }

  bool isExpanded(ProductManagementPackFieldGroup group) {
    if (visibilityMode ==
        ProductManagementPackFieldVisibilityMode.requiredOnly) {
      return true;
    }

    return expandedCapabilities[group.capability] ?? true;
  }

  bool canCollapse(ProductManagementPackFieldGroup group) {
    if (visibilityMode ==
        ProductManagementPackFieldVisibilityMode.requiredOnly) {
      return false;
    }

    final progress = _progressFor(group.capability, groupProgress);
    return !(progress?.hasMissingRequiredFields ?? false) &&
        !(progress?.hasInvalidFields ?? false);
  }

  Map<ProductManagementCapability, bool> withGroupExpanded(
    ProductManagementPackFieldGroup group,
    bool isExpanded,
  ) {
    return Map.unmodifiable({
      ...expandedCapabilities,
      group.capability: isExpanded,
    });
  }

  Map<ProductManagementCapability, bool> expandAll() {
    return Map.unmodifiable({
      ...expandedCapabilities,
      for (final group in groups) group.capability: true,
    });
  }

  Map<ProductManagementCapability, bool> collapseReady() {
    return Map.unmodifiable({
      ...expandedCapabilities,
      for (final group in groups) group.capability: !canCollapse(group),
    });
  }
}

/// Normalizes persisted expansion state against active product management groups.
Map<ProductManagementCapability, bool>
resolveProductManagementPackFieldExpansionState({
  required List<ProductManagementPackFieldGroup> groups,
  required Map<ProductManagementCapability, bool> expandedCapabilities,
  ProductManagementPackFieldGroupProgressOverview? groupProgress,
  ProductManagementFieldId? focusedFieldId,
}) {
  final capabilities = groups.map((group) => group.capability).toSet();
  final focusedCapability = _focusedCapabilityFor(groups, focusedFieldId);
  final next = <ProductManagementCapability, bool>{
    for (final entry in expandedCapabilities.entries)
      if (capabilities.contains(entry.key)) entry.key: entry.value,
  };

  for (final group in groups) {
    final progress = _progressFor(group.capability, groupProgress);
    final needsReview =
        (progress?.hasMissingRequiredFields ?? false) ||
        (progress?.hasInvalidFields ?? false);
    next.putIfAbsent(group.capability, () => progress == null || needsReview);
    if (needsReview) {
      next[group.capability] = true;
    }
    if (group.capability == focusedCapability) {
      next[group.capability] = true;
    }
  }

  return Map.unmodifiable(next);
}

ProductManagementCapability? _focusedCapabilityFor(
  List<ProductManagementPackFieldGroup> groups,
  ProductManagementFieldId? focusedFieldId,
) {
  if (focusedFieldId == null) return null;

  for (final group in groups) {
    for (final field in group.fields) {
      if (field.id == focusedFieldId) return group.capability;
    }
  }

  return null;
}

ProductManagementPackFieldGroupProgress? _progressFor(
  ProductManagementCapability capability,
  ProductManagementPackFieldGroupProgressOverview? groupProgress,
) {
  if (groupProgress == null) return null;

  for (final progress in groupProgress.groups) {
    if (progress.group.capability == capability) return progress;
  }

  return null;
}
