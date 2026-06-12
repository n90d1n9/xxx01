import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_form_required_action_panel.dart';

void main() {
  testWidgets('product form required action panel renders missing guide', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(760, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );
    final progress = buildProductFormSectionProgressOverview(
      overview: overview,
      values: const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'description': 'Leafy greens',
      },
    );
    ProductFormMissingRequiredAttribute? selectedAttribute;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductFormRequiredActionPanel(
              progress: progress,
              onSelectAttribute: (attribute) {
                selectedAttribute = attribute;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Required field guide'), findsOneWidget);
    expect(find.text('4/8 ready'), findsOneWidget);
    expect(find.text('4 required missing'), findsOneWidget);
    expect(find.text('Next required field'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Commercial | Money'), findsOneWidget);
    expect(find.text('Initial Stock'), findsOneWidget);
    expect(find.text('Expiry date'), findsOneWidget);
    expect(find.text('Batch number'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Focus field'));
    await tester.pump();

    expect(selectedAttribute?.fieldId, 'price');

    await tester.tap(find.widgetWithText(InkWell, 'Expiry date'));
    await tester.pump();

    expect(selectedAttribute?.fieldId, 'expiry_date');
  });

  testWidgets('product form required action panel hides when ready', (
    tester,
  ) async {
    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );
    final progress = buildProductFormSectionProgressOverview(
      overview: overview,
      values: const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'price': '12',
        'initial_stock': '8',
        'description': 'Leafy greens',
        'expiry_date': '2026-07-01',
        'batch_number': 'B-01',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormRequiredActionPanel(progress: progress),
        ),
      ),
    );

    expect(find.text('Required field guide'), findsNothing);
  });

  testWidgets(
    'product form required action panel expands hidden missing fields',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(760, 520));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final overview = buildProductFormSectionOverview(
        pack: groceryFreshGoodsProductManagementPack,
        isEditing: false,
      );
      final progress = buildProductFormSectionProgressOverview(
        overview: overview,
        values: const {
          'name': 'Spinach',
          'sku': 'SP-001',
          'category': 'Fresh',
          'description': 'Leafy greens',
        },
      );
      ProductFormMissingRequiredAttribute? selectedAttribute;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductFormRequiredActionPanel(
                progress: progress,
                maxVisibleAttributes: 3,
                onSelectAttribute: (attribute) {
                  selectedAttribute = attribute;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Batch number'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Show 1 more'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Show 1 more'));
      await tester.pumpAndSettle();

      expect(find.text('Batch number'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Show less'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Batch number'));
      await tester.pump();

      expect(selectedAttribute?.fieldId, 'batch_number');

      await tester.tap(find.widgetWithText(TextButton, 'Show less'));
      await tester.pumpAndSettle();

      expect(find.text('Batch number'), findsNothing);
    },
  );
}
