import 'package:flutter/material.dart';

import '../models/inventory_stock_record.dart';
import '../models/inventory_stock_transfer_draft.dart';
import '../models/warehouse.dart';
import 'inventory_mutation_form_layout.dart';
import 'inventory_stock_transfer_fields.dart';
import 'inventory_stock_transfer_preview.dart';

/// Form body for transferring quantity from one warehouse stock line to
/// another warehouse destination.
class InventoryStockTransferForm extends StatelessWidget {
  const InventoryStockTransferForm({
    super.key,
    required this.formKey,
    required this.selectedWarehouseId,
    required this.destinationWarehouses,
    required this.record,
    required this.destinationRecord,
    required this.draft,
    required this.quantityController,
    required this.notesController,
    required this.onDestinationChanged,
    required this.onQuantityChanged,
    required this.onSubmit,
    this.formError,
    this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final String selectedWarehouseId;
  final List<Warehouse> destinationWarehouses;
  final InventoryStockRecord record;
  final InventoryStockRecord? destinationRecord;
  final InventoryStockTransferDraft? draft;
  final TextEditingController quantityController;
  final TextEditingController notesController;
  final String? formError;
  final ValueChanged<String> onDestinationChanged;
  final ValueChanged<String> onQuantityChanged;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return InventoryMutationFormLayout(
      formKey: formKey,
      formError: formError,
      actionSpacing: 16,
      onCancel: onCancel,
      confirmLabel: 'Transfer stock',
      confirmIcon: Icons.swap_horiz_rounded,
      onSubmit: onSubmit,
      children: [
        InventoryStockTransferDestinationField(
          value: selectedWarehouseId,
          warehouses: destinationWarehouses,
          onChanged: onDestinationChanged,
        ),
        const SizedBox(height: 14),
        InventoryStockTransferPreview(
          record: record,
          destinationRecord: destinationRecord,
          draft: draft,
        ),
        const SizedBox(height: 14),
        InventoryStockTransferQuantityField(
          controller: quantityController,
          onChanged: onQuantityChanged,
        ),
        const SizedBox(height: 10),
        InventoryStockTransferNotesField(controller: notesController),
      ],
    );
  }
}
