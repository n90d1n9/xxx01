import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/controllers/product_core_information_form_controller.dart';
import 'package:kaysir/features/product/controllers/product_management_pack_form_controller.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/widgets/product_editor_field_stack.dart';

void main() {
  testWidgets('product editor field stack composes core and pack fields', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final harness = _ProductEditorFieldStackHarness();
    addTearDown(harness.dispose);
    String? selectedCoreFieldId;
    ProductManagementPackField? selectedPackField;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductEditorFieldStack(
              pack: harness.pack,
              coreFields: harness.coreFields,
              packFields: harness.packFields,
              groupProgress: harness.groupProgress,
              isEditing: false,
              onSelectCoreField: (fieldId) {
                selectedCoreFieldId = fieldId;
              },
              onSelectPackField: (field) {
                selectedPackField = field;
              },
              onPackToggleChanged: harness.packFields.setToggleValue,
              fieldFocusNodes: harness.focusNodes,
              fieldKeys: harness.keys,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product Information'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('product-core-field-name')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('product-core-field-price')),
      findsOneWidget,
    );
    expect(find.text('Grocery Fresh Goods data'), findsOneWidget);
    expect(find.text('Price is required'), findsOneWidget);
    expect(find.text('Review Price'), findsOneWidget);
    expect(find.text('Review Batch number'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Review Price'));
    await tester.pump();

    expect(selectedCoreFieldId, ProductCoreInformationFieldIds.price);

    final reviewButton = find.widgetWithText(
      OutlinedButton,
      'Review Batch number',
    );
    await tester.ensureVisible(reviewButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewButton);
    await tester.pump();

    expect(selectedPackField?.id, ProductManagementFieldId.batchNumber);
  });
}

/// Test harness for the editable product field stack.
class _ProductEditorFieldStackHarness {
  _ProductEditorFieldStackHarness()
    : pack = groceryFreshGoodsProductManagementPack,
      coreFields = ProductCoreInformationFormController.fromProduct(null),
      packFields = ProductManagementPackFormController() {
    coreFields.nameController.text = 'Spinach';
    coreFields.skuController.text = 'SP-001';
    coreFields.categoryController.text = 'Fresh';
    coreFields.descriptionController.text = 'Leafy greens';
    packFields.ensurePackFields(pack);
    packFields.textControllers[ProductManagementFieldId.barcode]?.text =
        '8990001';
    packFields.textControllers[ProductManagementFieldId.expiryDate]?.text =
        '2026-07-01';
    packFields.textControllers[ProductManagementFieldId.shelfLifeDays]?.text =
        '5';

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

  Map<String, String> get progressValues {
    return {...coreFields.progressValues(), ...packFields.progressValues(pack)};
  }

  ProductManagementPackFieldGroupProgressOverview get groupProgress {
    return buildProductManagementPackFieldGroupProgressOverview(
      groups: buildProductManagementPackFieldGroups(pack),
      values: progressValues,
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
