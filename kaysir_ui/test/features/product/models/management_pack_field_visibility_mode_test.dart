import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_visibility_mode.dart';

void main() {
  test(
    'field visibility snapshot preserves every group in all-fields mode',
    () {
      final groups = buildProductManagementPackFieldGroups(
        groceryFreshGoodsProductManagementPack,
      );
      final snapshot = ProductManagementPackFieldVisibilitySnapshot.fromGroups(
        mode: ProductManagementPackFieldVisibilityMode.all,
        groups: groups,
      );

      expect(snapshot.mode, ProductManagementPackFieldVisibilityMode.all);
      expect(snapshot.visibleGroupCount, 6);
      expect(snapshot.visibleFieldCount, 7);
      expect(snapshot.totalFieldCount, 7);
      expect(snapshot.hasVisibleGroups, isTrue);
      expect(snapshot.groups.map((group) => group.capability), [
        ProductManagementCapability.scanReadiness,
        ProductManagementCapability.stockTracking,
        ProductManagementCapability.expiryTracking,
        ProductManagementCapability.batchTracking,
        ProductManagementCapability.weightedInventory,
        ProductManagementCapability.freshnessQueue,
      ]);
    },
  );

  test(
    'field visibility snapshot keeps only required fields in focus mode',
    () {
      final groups = buildProductManagementPackFieldGroups(
        groceryFreshGoodsProductManagementPack,
      );
      final snapshot = ProductManagementPackFieldVisibilitySnapshot.fromGroups(
        mode: ProductManagementPackFieldVisibilityMode.requiredOnly,
        groups: groups,
      );

      expect(
        snapshot.mode,
        ProductManagementPackFieldVisibilityMode.requiredOnly,
      );
      expect(snapshot.visibleGroupCount, 2);
      expect(snapshot.visibleFieldCount, 2);
      expect(snapshot.totalFieldCount, 7);
      expect(snapshot.hasVisibleGroups, isTrue);
      expect(snapshot.groups.map((group) => group.capability), [
        ProductManagementCapability.expiryTracking,
        ProductManagementCapability.batchTracking,
      ]);
      expect(
        snapshot.groups
            .expand((group) => group.fields)
            .map((field) => field.id),
        [
          ProductManagementFieldId.expiryDate,
          ProductManagementFieldId.batchNumber,
        ],
      );
      expect(
        snapshot.groups.every(
          (group) => group.fields.every((field) => field.required),
        ),
        isTrue,
      );
    },
  );

  test('field visibility snapshot can represent an empty required focus', () {
    final groups = [
      ProductManagementPackFieldGroup(
        capability: ProductManagementCapability.scanReadiness,
        title: 'Scan readiness',
        description: 'Optional identifiers.',
        fields: const [
          ProductManagementPackField(
            id: ProductManagementFieldId.barcode,
            label: 'Barcode',
            type: ProductManagementFieldType.text,
            description: 'Optional scan code.',
            capability: ProductManagementCapability.scanReadiness,
          ),
        ],
      ),
    ];
    final snapshot = ProductManagementPackFieldVisibilitySnapshot.fromGroups(
      mode: ProductManagementPackFieldVisibilityMode.requiredOnly,
      groups: groups,
    );

    expect(snapshot.visibleGroupCount, 0);
    expect(snapshot.visibleFieldCount, 0);
    expect(snapshot.totalFieldCount, 1);
    expect(snapshot.hasVisibleGroups, isFalse);
  });
}
