import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_form_section_overview_panel.dart';

void main() {
  testWidgets('product form section overview panel renders setup map', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(980, 720));
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
        'price': '12',
        'description': 'Leafy greens',
        'expiry_date': '2026-07-01',
      },
    );
    ProductFormAttributeDefinition? selectedAttribute;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductFormSectionOverviewPanel(
              overview: overview,
              progress: progress,
              onSelectAttribute: (attribute) {
                selectedAttribute = attribute;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product setup sections'), findsOneWidget);
    expect(find.text('13 fields'), findsOneWidget);
    expect(find.text('8 required fields'), findsOneWidget);
    expect(find.text('2 required missing'), findsOneWidget);
    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Commercial'), findsOneWidget);
    expect(find.text('Pack extensions'), findsOneWidget);
    expect(find.text('4 fields'), findsOneWidget);
    expect(find.text('2 fields'), findsOneWidget);
    expect(find.text('7 fields'), findsOneWidget);
    expect(find.text('Product Name *'), findsOneWidget);
    expect(find.text('Price *'), findsOneWidget);
    expect(find.text('Expiry date *'), findsOneWidget);
    expect(find.text('+3 more'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('1 missing required'), findsNWidgets(2));
    expect(find.text('4/4 required'), findsOneWidget);
    expect(find.text('1/2 required'), findsNWidgets(2));

    await tester.tap(find.widgetWithText(InkWell, 'Price *'));
    await tester.pump();

    expect(selectedAttribute?.id, 'price');
  });
}
