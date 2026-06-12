import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../controllers/product_core_information_form_controller.dart';
import '../controllers/product_management_pack_form_controller.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import 'management_pack_field_section.dart';
import 'product_core_information_fields.dart';

/// Reusable editable field stack for product core and management pack data.
class ProductEditorFieldStack extends StatelessWidget {
  const ProductEditorFieldStack({
    super.key,
    required this.pack,
    required this.coreFields,
    required this.packFields,
    required this.isEditing,
    required this.onPackToggleChanged,
    this.groupProgress,
    this.spacing = 16,
    this.focusedPackFieldId,
    this.focusedPackFieldRequestVersion = 0,
    this.onSelectCoreField,
    this.onSelectPackField,
    this.fieldFocusNodes = const {},
    this.fieldKeys = const {},
  });

  final ProductManagementPack pack;
  final ProductCoreInformationFormController coreFields;
  final ProductManagementPackFormController packFields;
  final bool isEditing;
  final void Function(ProductManagementPackField field, bool value)
  onPackToggleChanged;
  final ProductManagementPackFieldGroupProgressOverview? groupProgress;
  final double spacing;
  final ProductManagementFieldId? focusedPackFieldId;
  final int focusedPackFieldRequestVersion;
  final ValueChanged<String>? onSelectCoreField;
  final ValueChanged<ProductManagementPackField>? onSelectPackField;
  final Map<String, FocusNode> fieldFocusNodes;
  final Map<String, GlobalKey> fieldKeys;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductCoreInformationFields(
          nameController: coreFields.nameController,
          skuController: coreFields.skuController,
          categoryController: coreFields.categoryController,
          priceController: coreFields.priceController,
          stockController: coreFields.stockController,
          descriptionController: coreFields.descriptionController,
          isEditing: isEditing,
          onReviewField: onSelectCoreField,
          fieldFocusNodes: fieldFocusNodes,
          fieldKeys: fieldKeys,
        ),
        SizedBox(height: spacing),
        ProductManagementPackFieldSection(
          pack: pack,
          textControllers: packFields.textControllers,
          toggleValues: packFields.toggleValues,
          focusedFieldId: focusedPackFieldId,
          focusedFieldRequestVersion: focusedPackFieldRequestVersion,
          groupProgress: groupProgress,
          onSelectField: onSelectPackField,
          fieldFocusNodes: fieldFocusNodes,
          fieldKeys: fieldKeys,
          onToggleChanged: onPackToggleChanged,
        ),
      ],
    );
  }
}

@Preview(name: 'Product editor field stack')
Widget productEditorFieldStackPreview() {
  final fixture = _ProductEditorFieldStackPreviewFixture();

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductEditorFieldStack(
          pack: fixture.pack,
          coreFields: fixture.coreFields,
          packFields: fixture.packFields,
          groupProgress: fixture.groupProgress,
          isEditing: false,
          onSelectPackField: (_) {},
          onPackToggleChanged: fixture.packFields.setToggleValue,
        ),
      ),
    ),
  );
}

/// Preview fixture for the product editor editable field stack.
class _ProductEditorFieldStackPreviewFixture {
  _ProductEditorFieldStackPreviewFixture()
    : pack = groceryFreshGoodsProductManagementPack,
      coreFields = ProductCoreInformationFormController.fromProduct(null),
      packFields = ProductManagementPackFormController() {
    coreFields.nameController.text = 'Spinach';
    coreFields.skuController.text = 'SP-001';
    coreFields.categoryController.text = 'Fresh produce';
    coreFields.priceController.text = '12';
    coreFields.stockController.text = '8';
    coreFields.descriptionController.text = 'Leafy greens';
    packFields.ensurePackFields(pack);
    packFields.textControllers[ProductManagementFieldId.barcode]?.text =
        '8990001';
    packFields.textControllers[ProductManagementFieldId.expiryDate]?.text =
        '2026-07-01';
  }

  final ProductManagementPack pack;
  final ProductCoreInformationFormController coreFields;
  final ProductManagementPackFormController packFields;

  Map<String, String> get progressValues {
    return {...coreFields.progressValues(), ...packFields.progressValues(pack)};
  }

  ProductManagementPackFieldGroupProgressOverview get groupProgress {
    return buildProductManagementPackFieldGroupProgressOverview(
      groups: buildProductManagementPackFieldGroups(pack),
      values: progressValues,
    );
  }
}
