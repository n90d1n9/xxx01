import 'package:flutter/material.dart';

import '../utils/inventory_form_utils.dart';
import 'inventory_form_fields.dart';

class InventoryProductIdentityFields extends StatelessWidget {
  const InventoryProductIdentityFields({
    super.key,
    required this.nameController,
    required this.skuController,
    required this.categoryController,
    required this.nameFocusNode,
    required this.skuFocusNode,
    required this.categoryFocusNode,
    required this.onChanged,
  });

  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController categoryController;
  final FocusNode nameFocusNode;
  final FocusNode skuFocusNode;
  final FocusNode categoryFocusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InventoryFormTextField(
          key: const ValueKey('inventory-product-dialog-name-field'),
          controller: nameController,
          focusNode: nameFocusNode,
          label: 'Name',
          icon: Icons.inventory_2_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: inventoryProductNameRequiredError,
              ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          key: const ValueKey('inventory-product-dialog-sku-field'),
          controller: skuController,
          focusNode: skuFocusNode,
          label: 'SKU',
          icon: Icons.qr_code_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: inventoryProductSkuRequiredError,
              ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          key: const ValueKey('inventory-product-dialog-category-field'),
          controller: categoryController,
          focusNode: categoryFocusNode,
          label: 'Category',
          icon: Icons.category_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: inventoryProductCategoryRequiredError,
              ),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
