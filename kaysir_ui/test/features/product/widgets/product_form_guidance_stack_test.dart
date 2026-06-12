import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_form_guidance_stack.dart';

void main() {
  testWidgets(
    'product form guidance stack renders overview and missing guide',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(980, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final overview = _overview();
      final progress = _progressFor(overview, const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'description': 'Leafy greens',
      });
      ProductFormAttributeDefinition? selectedAttribute;
      ProductFormMissingRequiredAttribute? selectedMissingAttribute;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductFormGuidanceStack(
                overview: overview,
                progress: progress,
                onSelectAttribute: (attribute) {
                  selectedAttribute = attribute;
                },
                onSelectMissingAttribute: (attribute) {
                  selectedMissingAttribute = attribute;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Product setup sections'), findsOneWidget);
      expect(find.text('Required field guide'), findsOneWidget);
    expect(find.text('4 required missing'), findsNWidgets(2));
      expect(find.text('Review required fields'), findsNothing);

      await tester.tap(find.widgetWithText(InkWell, 'Price *'));
      await tester.pump();
      expect(selectedAttribute?.id, 'price');

      await tester.tap(find.widgetWithText(TextButton, 'Focus field'));
      await tester.pump();
      expect(selectedMissingAttribute?.fieldId, 'price');
    },
  );

  testWidgets('product form guidance stack hides missing guide when ready', (
    tester,
  ) async {
    final overview = _overview();
    final progress = _progressFor(overview, const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': '2026-07-01',
      'batch_number': 'B-01',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormGuidanceStack(
            overview: overview,
            progress: progress,
          ),
        ),
      ),
    );

    expect(find.text('Product setup sections'), findsOneWidget);
    expect(find.text('Ready to save'), findsOneWidget);
    expect(find.text('Required field guide'), findsNothing);
  });
}

ProductFormSectionOverview _overview() {
  return buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
}

ProductFormSectionProgressOverview _progressFor(
  ProductFormSectionOverview overview,
  Map<String, String> values,
) {
  return buildProductFormSectionProgressOverview(
    overview: overview,
    values: values,
  );
}
