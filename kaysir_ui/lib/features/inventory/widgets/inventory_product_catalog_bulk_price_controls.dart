import 'package:flutter/material.dart';

import '../models/inventory_product_bulk_price_update.dart';
import 'inventory_form_fields.dart';

class InventoryProductBulkPriceModeSelector extends StatelessWidget {
  const InventoryProductBulkPriceModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final InventoryProductBulkPriceUpdateMode mode;
  final ValueChanged<InventoryProductBulkPriceUpdateMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<InventoryProductBulkPriceUpdateMode>(
      showSelectedIcon: false,
      segments: [
        for (final mode in InventoryProductBulkPriceUpdateMode.values)
          ButtonSegment(
            value: mode,
            label: Text(inventoryProductBulkPriceUpdateModeLabel(mode)),
          ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}

class InventoryProductBulkPriceValueField extends StatelessWidget {
  const InventoryProductBulkPriceValueField({
    super.key,
    required this.controller,
    required this.mode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final InventoryProductBulkPriceUpdateMode mode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: controller,
      label: inventoryProductBulkPriceUpdateInputLabel(mode),
      helperText: inventoryProductBulkPriceUpdateHelperText(mode),
      icon:
          mode == InventoryProductBulkPriceUpdateMode.setFixed
              ? Icons.sell_rounded
              : Icons.percent_rounded,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onChanged: (_) => onChanged(),
      validator: (value) => validateInventoryProductBulkPriceValue(value, mode),
    );
  }
}
