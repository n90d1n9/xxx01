import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/models/product_core_information_field_summary.dart';
import 'package:kaysir/features/product/widgets/product_core_information_summary_pills.dart';

void main() {
  testWidgets('core information summary pills render add mode metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCoreInformationSummaryPills(
            summary: ProductCoreInformationFieldSummary.forEditor(
              isEditing: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('6 fields'), findsOneWidget);
    expect(find.text('0/6 ready'), findsOneWidget);
    expect(find.text('6 missing'), findsOneWidget);
    expect(find.text('1 locked'), findsNothing);
  });

  testWidgets('core information summary pills render edit mode lock metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCoreInformationSummaryPills(
            summary: ProductCoreInformationFieldSummary.forEditor(
              isEditing: true,
              values: const {
                ProductCoreInformationFieldIds.name: 'Spinach',
                ProductCoreInformationFieldIds.sku: 'SP-001',
                ProductCoreInformationFieldIds.category: 'Fresh',
                ProductCoreInformationFieldIds.price: '12',
                ProductCoreInformationFieldIds.initialStock: '8',
                ProductCoreInformationFieldIds.description: 'Leafy greens',
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('6 fields'), findsOneWidget);
    expect(find.text('6/6 ready'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('1 locked'), findsOneWidget);
  });
}
