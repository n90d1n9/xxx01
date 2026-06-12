import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/warehouse.dart';
import 'inventory_stock_opname_setup_fields.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Setup panel for choosing the stock opname warehouse and counter.
class InventoryStockOpnameControls extends StatelessWidget {
  const InventoryStockOpnameControls({
    super.key,
    required this.warehouses,
    required this.conductedByController,
    this.selectedWarehouseId,
    this.warehouseValidator,
    this.conductedByValidator,
    this.onWarehouseChanged,
    this.onConductedByChanged,
  });

  final List<Warehouse> warehouses;
  final String? selectedWarehouseId;
  final TextEditingController conductedByController;
  final FormFieldValidator<String>? warehouseValidator;
  final FormFieldValidator<String>? conductedByValidator;
  final ValueChanged<String?>? onWarehouseChanged;
  final ValueChanged<String>? onConductedByChanged;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Count Setup',
      subtitle: 'Choose the storage location and counter before saving results',
      leadingIcon: Icons.tune_rounded,
      elevated: false,
      child: InventoryStockOpnameSetupFields(
        warehouses: warehouses,
        selectedWarehouseId: selectedWarehouseId,
        conductedByController: conductedByController,
        warehouseValidator: warehouseValidator,
        conductedByValidator: conductedByValidator,
        onWarehouseChanged: onWarehouseChanged,
        onConductedByChanged: onConductedByChanged,
      ),
    );
  }
}

@Preview(name: 'Inventory stock opname controls')
Widget inventoryStockOpnameControlsPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameControls(
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
