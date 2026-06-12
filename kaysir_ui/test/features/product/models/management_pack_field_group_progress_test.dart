import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';

void main() {
  test('management pack field group progress reports group readiness', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = buildProductManagementPackFieldGroupProgressOverview(
      groups: groups,
      values: const {
        'barcode': '8990001',
        'expiry_date': '2026-07-01',
        'shelf_life_days': '5',
      },
    );

    final scan = progress.progressFor(
      ProductManagementCapability.scanReadiness,
    );
    expect(scan.readinessLabel, 'Optional');
    expect(scan.filledProgressLabel, '1/1 filled');

    final expiry = progress.progressFor(
      ProductManagementCapability.expiryTracking,
    );
    expect(expiry.readinessLabel, 'Ready');
    expect(expiry.requiredProgressLabel, '1/1 required');

    final batch = progress.progressFor(
      ProductManagementCapability.batchTracking,
    );
    expect(batch.readinessLabel, '1 missing required');
    expect(batch.requiredProgressLabel, '0/1 required');
    expect(
      batch.missingRequiredFields.single.field.id,
      ProductManagementFieldId.batchNumber,
    );
    expect(
      batch.nextMissingRequiredField?.field.id,
      ProductManagementFieldId.batchNumber,
    );
    expect(
      batch.nextReviewField?.field.id,
      ProductManagementFieldId.batchNumber,
    );
    expect(batch.reviewNextLabel, 'Review Batch number');

    final freshness = progress.progressFor(
      ProductManagementCapability.freshnessQueue,
    );
    expect(freshness.readinessLabel, 'Optional');
    expect(freshness.filledProgressLabel, '1/2 filled');
  });

  test('management pack field group progress reports invalid values', () {
    final groups = buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    );
    final progress = buildProductManagementPackFieldGroupProgressOverview(
      groups: groups,
      values: const {
        'barcode': '8990001',
        'expiry_date': 'not-a-date',
        'batch_number': 'B-01',
      },
    );

    final expiry = progress.progressFor(
      ProductManagementCapability.expiryTracking,
    );
    expect(expiry.readiness, ProductManagementPackFieldGroupReadiness.invalid);
    expect(expiry.readinessLabel, '1 invalid');
    expect(expiry.invalidFieldCount, 1);
    expect(
      expiry.invalidFields.single.field.id,
      ProductManagementFieldId.expiryDate,
    );
    expect(
      expiry.nextInvalidField?.field.id,
      ProductManagementFieldId.expiryDate,
    );
    expect(
      expiry.nextReviewField?.field.id,
      ProductManagementFieldId.expiryDate,
    );
    expect(expiry.reviewNextLabel, 'Review Expiry date');
  });
}
