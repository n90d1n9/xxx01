import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_expansion_state.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/management_pack_field_visibility_mode.dart';

void main() {
  test('field expansion state pins missing required groups open', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = _progressFor(groups);
    final expandedCapabilities =
        resolveProductManagementPackFieldExpansionState(
          groups: groups,
          expandedCapabilities: const {},
          groupProgress: progress,
        );
    final snapshot = ProductManagementPackFieldExpansionSnapshot(
      groups: groups,
      visibilityMode: ProductManagementPackFieldVisibilityMode.all,
      expandedCapabilities: expandedCapabilities,
      groupProgress: progress,
    );

    expect(snapshot.expandedGroupCount, 1);
    expect(snapshot.lockedOpenGroupCount, 1);
    expect(snapshot.canExpandAll, isTrue);
    expect(snapshot.canCollapseReady, isFalse);
    expect(
      snapshot.isExpanded(
        _group(groups, ProductManagementCapability.batchTracking),
      ),
      isTrue,
    );
    expect(
      snapshot.canCollapse(
        _group(groups, ProductManagementCapability.batchTracking),
      ),
      isFalse,
    );
    expect(
      snapshot.isExpanded(
        _group(groups, ProductManagementCapability.scanReadiness),
      ),
      isFalse,
    );
  });

  test('field expansion snapshot expands all and collapses ready groups', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = _progressFor(groups);
    final normalizedState = resolveProductManagementPackFieldExpansionState(
      groups: groups,
      expandedCapabilities: const {},
      groupProgress: progress,
    );
    final collapsedSnapshot = ProductManagementPackFieldExpansionSnapshot(
      groups: groups,
      visibilityMode: ProductManagementPackFieldVisibilityMode.all,
      expandedCapabilities: normalizedState,
      groupProgress: progress,
    );
    final expandedSnapshot = ProductManagementPackFieldExpansionSnapshot(
      groups: groups,
      visibilityMode: ProductManagementPackFieldVisibilityMode.all,
      expandedCapabilities: collapsedSnapshot.expandAll(),
      groupProgress: progress,
    );

    expect(expandedSnapshot.expandedGroupCount, 6);
    expect(expandedSnapshot.canCollapseReady, isTrue);

    final readyCollapsedSnapshot = ProductManagementPackFieldExpansionSnapshot(
      groups: groups,
      visibilityMode: ProductManagementPackFieldVisibilityMode.all,
      expandedCapabilities: expandedSnapshot.collapseReady(),
      groupProgress: progress,
    );

    expect(readyCollapsedSnapshot.expandedGroupCount, 1);
    expect(
      readyCollapsedSnapshot.isExpanded(
        _group(groups, ProductManagementCapability.batchTracking),
      ),
      isTrue,
    );
    expect(
      readyCollapsedSnapshot.isExpanded(
        _group(groups, ProductManagementCapability.expiryTracking),
      ),
      isFalse,
    );
  });

  test('field expansion state pins invalid groups open', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = _progressFor(
      groups,
      values: const {'expiry_date': 'soon', 'batch_number': 'B-01'},
    );
    final expandedCapabilities =
        resolveProductManagementPackFieldExpansionState(
          groups: groups,
          expandedCapabilities: const {},
          groupProgress: progress,
        );
    final snapshot = ProductManagementPackFieldExpansionSnapshot(
      groups: groups,
      visibilityMode: ProductManagementPackFieldVisibilityMode.all,
      expandedCapabilities: expandedCapabilities,
      groupProgress: progress,
    );

    expect(snapshot.expandedGroupCount, 1);
    expect(snapshot.lockedOpenGroupCount, 1);
    expect(
      snapshot.isExpanded(
        _group(groups, ProductManagementCapability.expiryTracking),
      ),
      isTrue,
    );
    expect(
      snapshot.canCollapse(
        _group(groups, ProductManagementCapability.expiryTracking),
      ),
      isFalse,
    );
  });

  test('field expansion snapshot locks required-only groups open', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = _progressFor(groups);
    final requiredGroups = groups.where(
      (group) => group.requiredFieldCount > 0,
    );
    final snapshot = ProductManagementPackFieldExpansionSnapshot(
      groups: requiredGroups.toList(),
      visibilityMode: ProductManagementPackFieldVisibilityMode.requiredOnly,
      expandedCapabilities: const {},
      groupProgress: progress,
    );

    expect(snapshot.expandedGroupCount, 2);
    expect(snapshot.lockedOpenGroupCount, 2);
    expect(snapshot.canExpandAll, isFalse);
    expect(snapshot.canCollapseReady, isFalse);
    expect(snapshot.groups.every(snapshot.isExpanded), isTrue);
    expect(snapshot.groups.any(snapshot.canCollapse), isFalse);
  });
}

ProductManagementPackFieldGroupProgressOverview _progressFor(
  List<ProductManagementPackFieldGroup> groups, {
  Map<String, String> values = const {
    'barcode': '8990001',
    'expiry_date': '2026-07-01',
    'shelf_life_days': '5',
  },
}) {
  return buildProductManagementPackFieldGroupProgressOverview(
    groups: groups,
    values: values,
  );
}

ProductManagementPackFieldGroup _group(
  List<ProductManagementPackFieldGroup> groups,
  ProductManagementCapability capability,
) {
  return groups.firstWhere((group) => group.capability == capability);
}
