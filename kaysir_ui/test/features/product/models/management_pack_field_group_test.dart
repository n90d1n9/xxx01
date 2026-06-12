import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';

void main() {
  test(
    'management pack field groups summarize editable fields by capability',
    () {
      final groups = buildProductManagementPackFieldGroups(
        groceryFreshGoodsProductManagementPack,
      );

      expect(groups.map((group) => group.title), [
        'Scan readiness',
        'Stock tracking',
        'Expiry tracking',
        'Batch tracking',
        'Weighted inventory',
        'Freshness queue',
      ]);
      expect(groups.fold(0, (total, group) => total + group.fieldCount), 7);

      final expiryGroup = groups.firstWhere(
        (group) =>
            group.capability == ProductManagementCapability.expiryTracking,
      );
      expect(expiryGroup.fieldCountLabel, '1 field');
      expect(expiryGroup.requiredFieldCountLabel, '1 required field');
      expect(expiryGroup.fields.single.id, ProductManagementFieldId.expiryDate);

      final freshnessGroup = groups.firstWhere(
        (group) =>
            group.capability == ProductManagementCapability.freshnessQueue,
      );
      expect(freshnessGroup.fieldCountLabel, '2 fields');
      expect(freshnessGroup.requiredFieldCount, 0);
      expect(freshnessGroup.fields.map((field) => field.id), [
        ProductManagementFieldId.shelfLifeDays,
        ProductManagementFieldId.freshnessStatus,
      ]);
    },
  );
}
