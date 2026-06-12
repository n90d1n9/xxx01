import 'package:flutter/material.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/warehouse.dart';
import '../utils/inventory_form_utils.dart';
import 'inventory_form_fields.dart';

class InventoryStockTransferDestinationField extends StatelessWidget {
  const InventoryStockTransferDestinationField({
    super.key,
    required this.value,
    required this.warehouses,
    required this.onChanged,
  });

  final String value;
  final List<Warehouse> warehouses;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<String>(
      label: 'Destination warehouse',
      icon: Icons.warehouse_rounded,
      value: value,
      options: [
        for (final warehouse in warehouses)
          AppSelectOption(
            value: warehouse.id,
            label: '${warehouse.name} - ${warehouse.location}',
          ),
      ],
      onChanged: onChanged,
      menuMaxHeight: 260,
    );
  }
}

class InventoryStockTransferQuantityField extends StatelessWidget {
  const InventoryStockTransferQuantityField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryIntegerFormField(
      controller: controller,
      label: 'Quantity to transfer',
      icon: Icons.inventory_2_rounded,
      onChanged: onChanged,
      validator: validateInventoryPositiveQuantity,
    );
  }
}

class InventoryStockTransferNotesField extends StatelessWidget {
  const InventoryStockTransferNotesField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: controller,
      label: 'Notes',
      icon: Icons.notes_rounded,
      maxLines: 3,
    );
  }
}
