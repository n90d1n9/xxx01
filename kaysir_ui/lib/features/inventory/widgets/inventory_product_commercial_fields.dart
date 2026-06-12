import 'package:flutter/material.dart';

import '../utils/inventory_form_utils.dart';
import 'inventory_form_fields.dart';

class InventoryProductCommercialFields extends StatelessWidget {
  const InventoryProductCommercialFields({
    super.key,
    required this.priceController,
    required this.descriptionController,
    required this.priceFocusNode,
    required this.descriptionFocusNode,
    required this.onChanged,
  });

  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final FocusNode priceFocusNode;
  final FocusNode descriptionFocusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InventoryFormTextField(
          key: const ValueKey('inventory-product-dialog-price-field'),
          controller: priceController,
          focusNode: priceFocusNode,
          label: 'Unit price',
          icon: Icons.payments_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator:
              (value) => validateInventoryPositiveDecimal(
                value,
                errorMessage: inventoryProductUnitPriceError,
              ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          key: const ValueKey('inventory-product-dialog-description-field'),
          controller: descriptionController,
          focusNode: descriptionFocusNode,
          label: 'Description',
          icon: Icons.notes_rounded,
          maxLines: 3,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
