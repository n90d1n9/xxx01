import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/management_pack_field_view_state.dart';
import 'package:kaysir/features/product/models/management_pack_field_visibility_mode.dart';

void main() {
  test('pack field view state composes all-fields editor state', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = _progressFor(groups);
    final viewState = ProductManagementPackFieldViewState.fromPack(
      pack: groceryFreshGoodsProductManagementPack,
      visibilityMode: ProductManagementPackFieldVisibilityMode.all,
      expandedCapabilities: const {},
      groupProgress: progress,
    );

    expect(viewState.hasEditableFields, isTrue);
    expect(viewState.hasVisibleGroups, isTrue);
    expect(viewState.totalFieldCount, 7);
    expect(viewState.totalGroupCount, 6);
    expect(viewState.visibleFieldCount, 7);
    expect(viewState.visibleGroupCount, 6);
    expect(viewState.expandedGroupCount, 1);
    expect(viewState.lockedOpenGroupCount, 1);
    expect(viewState.canExpandAll, isTrue);
    expect(viewState.canCollapseReady, isFalse);
    expect(
      viewState.isExpanded(
        _group(viewState.groups, ProductManagementCapability.batchTracking),
      ),
      isTrue,
    );
    expect(
      viewState
          .progressFor(ProductManagementCapability.batchTracking)
          ?.nextMissingRequiredField
          ?.field
          .id,
      ProductManagementFieldId.batchNumber,
    );
  });

  test('pack field view state opens the focused field capability', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = _progressFor(groups);
    final viewState = ProductManagementPackFieldViewState.fromPack(
      pack: groceryFreshGoodsProductManagementPack,
      visibilityMode: ProductManagementPackFieldVisibilityMode.all,
      expandedCapabilities: const {},
      groupProgress: progress,
      focusedFieldId: ProductManagementFieldId.shelfLifeDays,
    );

    expect(viewState.expandedGroupCount, 2);
    expect(
      viewState.isExpanded(
        _group(viewState.groups, ProductManagementCapability.batchTracking),
      ),
      isTrue,
    );
    expect(
      viewState.isExpanded(
        _group(viewState.groups, ProductManagementCapability.freshnessQueue),
      ),
      isTrue,
    );
    expect(viewState.canCollapseReady, isTrue);
  });

  test('pack field view state composes required-only editor state', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = _progressFor(groups);
    final viewState = ProductManagementPackFieldViewState.fromPack(
      pack: groceryFreshGoodsProductManagementPack,
      visibilityMode: ProductManagementPackFieldVisibilityMode.requiredOnly,
      expandedCapabilities: const {},
      groupProgress: progress,
    );

    expect(viewState.hasEditableFields, isTrue);
    expect(viewState.hasVisibleGroups, isTrue);
    expect(viewState.totalFieldCount, 7);
    expect(viewState.totalGroupCount, 6);
    expect(viewState.visibleFieldCount, 2);
    expect(viewState.visibleGroupCount, 2);
    expect(viewState.expandedGroupCount, 2);
    expect(viewState.lockedOpenGroupCount, 2);
    expect(viewState.canExpandAll, isFalse);
    expect(viewState.canCollapseReady, isFalse);
    expect(viewState.visibleGroups.map((group) => group.capability), [
      ProductManagementCapability.expiryTracking,
      ProductManagementCapability.batchTracking,
    ]);
  });

  test('pack field view state represents empty visible results', () {
    const field = ProductManagementPackField(
      id: ProductManagementFieldId.barcode,
      label: 'Barcode',
      type: ProductManagementFieldType.text,
      description: 'Optional scan code.',
      capability: ProductManagementCapability.scanReadiness,
    );
    final groups = [
      ProductManagementPackFieldGroup(
        capability: ProductManagementCapability.scanReadiness,
        title: 'Scan readiness',
        description: 'Optional identifiers.',
        fields: const [field],
      ),
    ];
    final viewState = ProductManagementPackFieldViewState.fromGroups(
      fields: const [field],
      groups: groups,
      visibilityMode: ProductManagementPackFieldVisibilityMode.requiredOnly,
      expandedCapabilities: const {},
    );

    expect(viewState.hasEditableFields, isTrue);
    expect(viewState.hasVisibleGroups, isFalse);
    expect(viewState.totalFieldCount, 1);
    expect(viewState.totalGroupCount, 1);
    expect(viewState.visibleFieldCount, 0);
    expect(viewState.visibleGroupCount, 0);
    expect(viewState.expandedGroupCount, 0);
    expect(viewState.lockedOpenGroupCount, 0);
    expect(viewState.canExpandAll, isFalse);
    expect(viewState.canCollapseReady, isFalse);
  });
}

ProductManagementPackFieldGroupProgressOverview _progressFor(
  List<ProductManagementPackFieldGroup> groups,
) {
  return buildProductManagementPackFieldGroupProgressOverview(
    groups: groups,
    values: const {
      'barcode': '8990001',
      'expiry_date': '2026-07-01',
      'shelf_life_days': '5',
    },
  );
}

ProductManagementPackFieldGroup _group(
  List<ProductManagementPackFieldGroup> groups,
  ProductManagementCapability capability,
) {
  return groups.firstWhere((group) => group.capability == capability);
}
