import 'package:flutter/material.dart';

import '../models/warehouse.dart';
import 'inventory_delete_confirmation_dialog.dart';

/// Confirmation dialog for deleting a warehouse from the inventory directory.
class InventoryWarehouseDeleteDialog extends StatelessWidget {
  const InventoryWarehouseDeleteDialog({
    super.key,
    required this.warehouse,
    required this.onConfirm,
    this.onCancel,
  });

  final Warehouse warehouse;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return InventoryDeleteConfirmationDialog(
      title: 'Delete ${warehouse.name}?',
      subtitle:
          'This removes the warehouse from the local inventory directory.',
      confirmLabel: 'Delete',
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
