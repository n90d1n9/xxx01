import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/models/product_core_information_field_summary.dart';
import 'package:kaysir/features/product/widgets/product_core_information_readiness_notice.dart';

void main() {
  testWidgets('core information readiness notice reviews invalid fields', (
    tester,
  ) async {
    String? reviewedFieldId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCoreInformationReadinessNotice(
            summary: ProductCoreInformationFieldSummary.forEditor(
              isEditing: false,
              values: const {
                ProductCoreInformationFieldIds.name: 'Spinach',
                ProductCoreInformationFieldIds.sku: 'SP-001',
                ProductCoreInformationFieldIds.category: 'Fresh',
                ProductCoreInformationFieldIds.price: 'abc',
                ProductCoreInformationFieldIds.initialStock: '8',
                ProductCoreInformationFieldIds.description: 'Leafy greens',
              },
            ),
            onReviewField: (fieldId) {
              reviewedFieldId = fieldId;
            },
          ),
        ),
      ),
    );

    expect(find.text('Price needs correction'), findsOneWidget);
    expect(
      find.text('Price needs a valid money value before saving.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Review Price'));
    await tester.pump();

    expect(reviewedFieldId, ProductCoreInformationFieldIds.price);
  });

  testWidgets('core information readiness notice hides when ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCoreInformationReadinessNotice(
            summary: ProductCoreInformationFieldSummary.forEditor(
              isEditing: false,
              values: const {
                ProductCoreInformationFieldIds.name: 'Spinach',
                ProductCoreInformationFieldIds.sku: 'SP-001',
                ProductCoreInformationFieldIds.category: 'Fresh',
                ProductCoreInformationFieldIds.price: '12',
                ProductCoreInformationFieldIds.initialStock: '8',
                ProductCoreInformationFieldIds.description: 'Leafy greens',
              },
            ),
            onReviewField: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('Core information ready'), findsNothing);
  });
}
