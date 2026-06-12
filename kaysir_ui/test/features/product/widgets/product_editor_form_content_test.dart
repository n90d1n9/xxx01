import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/controllers/product_core_information_form_controller.dart';
import 'package:kaysir/features/product/controllers/product_management_pack_form_controller.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_editor_form_content.dart';

void main() {
  testWidgets('product editor form content composes editor sections', (
    tester,
  ) async {
    final harness = _ProductEditorFormContentHarness();
    addTearDown(harness.dispose);
    ProductFormAttributeDefinition? selectedAttribute;
    ProductFormMissingRequiredAttribute? selectedMissingAttribute;
    ProductManagementPackField? selectedPackField;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: harness.build(
              onSelectAttribute: (attribute) {
                selectedAttribute = attribute;
              },
              onSelectMissingAttribute: (attribute) {
                selectedMissingAttribute = attribute;
              },
              onSelectPackField: (field) {
                selectedPackField = field;
              },
              onSubmit: () {
                submitCount += 1;
              },
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('product-form-scroll-view')),
      findsOneWidget,
    );
    expect(find.text('Editor sections'), findsOneWidget);
    expect(find.text('Product setup sections'), findsOneWidget);
    expect(find.text('New product'), findsOneWidget);
    expect(find.text('Grocery and fresh goods'), findsOneWidget);
    expect(find.text('Product Information'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods data'), findsOneWidget);
    expect(find.text('Product still needs required data'), findsOneWidget);
    expect(find.text('Review Price'), findsNWidgets(2));

    final priceChip = find.widgetWithText(InkWell, 'Price *');
    await tester.ensureVisible(priceChip);
    await tester.pumpAndSettle();
    await tester.tap(priceChip);
    await tester.pump();
    expect(selectedAttribute?.id, ProductCoreInformationFieldIds.price);

    final focusButton = find.widgetWithText(TextButton, 'Focus field');
    await tester.ensureVisible(focusButton);
    await tester.pumpAndSettle();
    await tester.tap(focusButton);
    await tester.pump();
    expect(
      selectedMissingAttribute?.fieldId,
      ProductCoreInformationFieldIds.price,
    );

    final reviewButton = find.widgetWithText(OutlinedButton, 'Review Price');
    await tester.ensureVisible(reviewButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewButton);
    await tester.pump();
    expect(
      selectedMissingAttribute?.fieldId,
      ProductCoreInformationFieldIds.price,
    );

    selectedMissingAttribute = null;
    final missingPriceChip = find.text('Missing Price');
    await tester.ensureVisible(missingPriceChip);
    await tester.pumpAndSettle();
    await tester.tap(missingPriceChip);
    await tester.pump();
    expect(
      selectedMissingAttribute?.fieldId,
      ProductCoreInformationFieldIds.price,
    );

    final expiryReviewButton = find.widgetWithText(
      OutlinedButton,
      'Review Expiry date',
    );
    await tester.ensureVisible(expiryReviewButton);
    await tester.pumpAndSettle();
    await tester.tap(expiryReviewButton);
    await tester.pump();
    expect(selectedPackField?.id, ProductManagementFieldId.expiryDate);

    final submitButton = find.widgetWithText(FilledButton, 'Add product');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    expect(submitCount, 1);
  });

  testWidgets('product editor form content uses split layout on wide screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final harness = _ProductEditorFormContentHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: harness.build(
              onSelectAttribute: (_) {},
              onSelectMissingAttribute: (_) {},
              onSelectPackField: (_) {},
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );

    final informationTopLeft = tester.getTopLeft(
      find.text('Product Information'),
    );
    final guidanceTopLeft = tester.getTopLeft(find.text('Editor sections'));

    expect(guidanceTopLeft.dx, greaterThan(informationTopLeft.dx));
    expect((guidanceTopLeft.dy - informationTopLeft.dy).abs(), lessThan(80));
    expect(find.text('Product still needs required data'), findsOneWidget);
  });
}

/// Test harness for product editor content with owned form controllers.
class _ProductEditorFormContentHarness {
  _ProductEditorFormContentHarness()
    : pack = groceryFreshGoodsProductManagementPack,
      coreFields = ProductCoreInformationFormController.fromProduct(null),
      packFields = ProductManagementPackFormController() {
    coreFields.nameController.text = 'Spinach';
    coreFields.skuController.text = 'SP-001';
    coreFields.categoryController.text = 'Fresh';
    coreFields.descriptionController.text = 'Leafy greens';
    packFields.ensurePackFields(pack);
    for (final fieldId in ProductCoreInformationFieldIds.all) {
      focusNodes[fieldId] = FocusNode(debugLabel: 'test-$fieldId');
      keys[fieldId] = GlobalKey(debugLabel: 'test-$fieldId');
    }
    for (final field in productManagementPackEditableFields(pack)) {
      focusNodes[field.id.value] = FocusNode(debugLabel: 'test-${field.id}');
      keys[field.id.value] = GlobalKey(debugLabel: 'test-${field.id}');
    }
  }

  final ProductManagementPack pack;
  final ProductCoreInformationFormController coreFields;
  final ProductManagementPackFormController packFields;
  final focusNodes = <String, FocusNode>{};
  final keys = <String, GlobalKey>{};

  Widget build({
    required ValueChanged<ProductFormAttributeDefinition> onSelectAttribute,
    required ValueChanged<ProductFormMissingRequiredAttribute>
    onSelectMissingAttribute,
    required ValueChanged<ProductManagementPackField> onSelectPackField,
    required VoidCallback onSubmit,
  }) {
    return ProductEditorFormContent(
      pack: pack,
      sectionOverview: sectionOverview,
      sectionProgress: sectionProgress,
      groupProgress: groupProgress,
      saveSummary: saveSummary,
      coreFields: coreFields,
      packFields: packFields,
      isEditing: false,
      onSelectAttribute: onSelectAttribute,
      onSelectMissingAttribute: onSelectMissingAttribute,
      onSelectPackField: onSelectPackField,
      onPackToggleChanged: packFields.setToggleValue,
      onSubmit: onSubmit,
      fieldFocusNodes: focusNodes,
      fieldKeys: keys,
    );
  }

  ProductFormSectionOverview get sectionOverview {
    return buildProductFormSectionOverview(pack: pack, isEditing: false);
  }

  Map<String, String> get progressValues {
    return {...coreFields.progressValues(), ...packFields.progressValues(pack)};
  }

  ProductFormSectionProgressOverview get sectionProgress {
    return buildProductFormSectionProgressOverview(
      overview: sectionOverview,
      values: progressValues,
    );
  }

  ProductManagementPackFieldGroupProgressOverview get groupProgress {
    return buildProductManagementPackFieldGroupProgressOverview(
      groups: buildProductManagementPackFieldGroups(pack),
      values: progressValues,
    );
  }

  ProductFormSaveActionSummary get saveSummary {
    return buildProductFormSaveActionSummary(
      progress: sectionProgress,
      submitLabel: 'Add product',
      isEditing: false,
      groupProgress: groupProgress,
    );
  }

  void dispose() {
    coreFields.dispose();
    packFields.dispose();
    for (final focusNode in focusNodes.values) {
      focusNode.dispose();
    }
  }
}
