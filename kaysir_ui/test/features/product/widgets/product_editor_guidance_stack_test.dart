import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_editor_guidance_stack.dart';

void main() {
  testWidgets('product editor guidance stack composes navigator and guidance', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(520, 920));
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
            child: ProductEditorGuidanceStack(
              overview: overview,
              progress: progress,
              groupProgress: _groupProgressFor(const {
                'name': 'Spinach',
                'sku': 'SP-001',
                'category': 'Fresh',
                'description': 'Leafy greens',
              }),
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

    expect(find.text('Editor sections'), findsOneWidget);
    expect(find.text('Product setup sections'), findsOneWidget);
    expect(find.text('Required field guide'), findsOneWidget);
    expect(find.text('Open'), findsWidgets);
    expect(find.text('Review Price'), findsOneWidget);

    final openButton = find.widgetWithText(TextButton, 'Open').first;
    await tester.ensureVisible(openButton);
    await tester.pumpAndSettle();
    await tester.tap(openButton);
    await tester.pump();
    expect(selectedAttribute?.id, ProductCoreInformationFieldIds.name);

    final priceChip = find.widgetWithText(InkWell, 'Price *');
    await tester.ensureVisible(priceChip);
    await tester.pumpAndSettle();
    await tester.tap(priceChip);
    await tester.pump();
    expect(selectedAttribute?.id, ProductCoreInformationFieldIds.price);

    final reviewButton = find.widgetWithText(TextButton, 'Review Price');
    await tester.ensureVisible(reviewButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewButton);
    await tester.pump();
    expect(
      selectedMissingAttribute?.fieldId,
      ProductCoreInformationFieldIds.price,
    );
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

ProductManagementPackFieldGroupProgressOverview _groupProgressFor(
  Map<String, String> values,
) {
  return buildProductManagementPackFieldGroupProgressOverview(
    groups: buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    ),
    values: values,
  );
}
