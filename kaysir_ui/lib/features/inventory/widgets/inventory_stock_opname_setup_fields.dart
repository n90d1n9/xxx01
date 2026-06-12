import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/warehouse.dart';
import 'inventory_form_fields.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Responsive setup fields for selecting stock opname context.
///
/// Encapsulates warehouse selection and counter entry so the parent setup
/// panel can stay focused on section framing and validation wiring.
class InventoryStockOpnameSetupFields extends StatelessWidget {
  const InventoryStockOpnameSetupFields({
    super.key,
    required this.warehouses,
    required this.conductedByController,
    this.selectedWarehouseId,
    this.warehouseValidator,
    this.conductedByValidator,
    this.onWarehouseChanged,
    this.onConductedByChanged,
    this.compactBreakpoint = 720,
  });

  final List<Warehouse> warehouses;
  final String? selectedWarehouseId;
  final TextEditingController conductedByController;
  final FormFieldValidator<String>? warehouseValidator;
  final FormFieldValidator<String>? conductedByValidator;
  final ValueChanged<String?>? onWarehouseChanged;
  final ValueChanged<String>? onConductedByChanged;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        warehouses.any((warehouse) => warehouse.id == selectedWarehouseId)
            ? selectedWarehouseId
            : null;
    final warehouseField = AppSelectField<String?>(
      key: ValueKey('stock-opname-warehouse-$selectedValue'),
      label: 'Warehouse',
      icon: Icons.warehouse_rounded,
      value: selectedValue,
      validator: warehouseValidator,
      enabled: warehouses.isNotEmpty,
      options: [
        for (final warehouse in warehouses)
          AppSelectOption<String?>(value: warehouse.id, label: warehouse.name),
      ],
      onChanged: (value) => onWarehouseChanged?.call(value),
    );
    final counterField = InventoryFormTextField(
      key: const ValueKey('stock-opname-conducted-by'),
      controller: conductedByController,
      label: 'Conducted by',
      icon: Icons.person_outline_rounded,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      validator: conductedByValidator,
      onChanged: onConductedByChanged,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < compactBreakpoint) {
          return Column(
            key: const ValueKey('stock-opname-setup-fields-compact'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              warehouseField,
              const SizedBox(height: 12),
              counterField,
            ],
          );
        }

        return Row(
          key: const ValueKey('stock-opname-setup-fields-wide'),
          children: [
            Expanded(child: warehouseField),
            const SizedBox(width: 12),
            Expanded(child: counterField),
          ],
        );
      },
    );
  }
}

@Preview(name: 'Inventory stock opname setup fields')
Widget inventoryStockOpnameSetupFieldsPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameSetupFields(
      warehouses: [
        Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
      ],
      selectedWarehouseId: 'w1',
      conductedByController: TextEditingController(text: 'Nina'),
      onWarehouseChanged: (_) {},
      onConductedByChanged: (_) {},
    ),
  );
}
