import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/models/product_core_information_field_summary.dart';

void main() {
  test('core information summary describes empty add product mode', () {
    final summary = ProductCoreInformationFieldSummary.forEditor(
      isEditing: false,
    );

    expect(summary.fieldCount, 6);
    expect(summary.requiredFieldCount, 6);
    expect(summary.readyFieldCount, 0);
    expect(summary.missingRequiredFieldCount, 6);
    expect(summary.invalidFieldCount, 0);
    expect(summary.lockedFieldCount, 0);
    expect(summary.isReady, isFalse);
    expect(summary.hasLockedFields, isFalse);
    expect(summary.fieldCountLabel, '6 fields');
    expect(summary.readyProgressLabel, '0/6 ready');
    expect(summary.requiredFieldCountLabel, '6 required fields');
    expect(summary.readinessLabel, '6 missing');
  });

  test('core information summary describes invalid add product fields', () {
    final summary = ProductCoreInformationFieldSummary.forEditor(
      isEditing: false,
      values: const {
        ProductCoreInformationFieldIds.name: 'Spinach',
        ProductCoreInformationFieldIds.sku: 'SP-001',
        ProductCoreInformationFieldIds.category: 'Fresh',
        ProductCoreInformationFieldIds.price: 'abc',
        ProductCoreInformationFieldIds.initialStock: '1.5',
        ProductCoreInformationFieldIds.description: 'Leafy greens',
      },
    );

    expect(summary.readyFieldCount, 4);
    expect(summary.missingRequiredFieldCount, 0);
    expect(summary.invalidFieldCount, 2);
    expect(summary.isReady, isFalse);
    expect(summary.readyProgressLabel, '4/6 ready');
    expect(summary.readinessLabel, '2 invalid');
    expect(
      summary.nextReviewField?.fieldId,
      ProductCoreInformationFieldIds.price,
    );
    expect(summary.nextReviewTitle, 'Price needs correction');
    expect(
      summary.nextReviewDescription,
      'Price needs a valid money value before saving.',
    );
    expect(summary.nextReviewActionLabel, 'Review Price');
  });

  test('core information summary describes ready edit product mode', () {
    final summary = ProductCoreInformationFieldSummary.forEditor(
      isEditing: true,
      values: const {
        ProductCoreInformationFieldIds.name: 'Spinach',
        ProductCoreInformationFieldIds.sku: 'SP-001',
        ProductCoreInformationFieldIds.category: 'Fresh',
        ProductCoreInformationFieldIds.price: '12',
        ProductCoreInformationFieldIds.initialStock: '8',
        ProductCoreInformationFieldIds.description: 'Leafy greens',
      },
    );

    expect(summary.fieldCount, 6);
    expect(summary.requiredFieldCount, 5);
    expect(summary.readyFieldCount, 6);
    expect(summary.missingRequiredFieldCount, 0);
    expect(summary.invalidFieldCount, 0);
    expect(summary.lockedFieldCount, 1);
    expect(summary.isReady, isTrue);
    expect(summary.hasLockedFields, isTrue);
    expect(summary.readyProgressLabel, '6/6 ready');
    expect(summary.readinessLabel, 'Ready');
    expect(summary.lockedFieldCountLabel, '1 locked');
    expect(summary.nextReviewField, isNull);
  });
}
