import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import 'inventory_delete_confirmation_dialog.dart';

/// Confirmation dialog for deleting a product from the inventory catalog.
class InventoryProductDeleteDialog extends StatelessWidget {
  const InventoryProductDeleteDialog({
    super.key,
    required this.product,
    required this.onConfirm,
    this.onCancel,
  });

  final Product product;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return InventoryDeleteConfirmationDialog(
      title: 'Delete ${product.name}?',
      subtitle: 'This removes the product from the local inventory catalog.',
      confirmLabel: 'Delete',
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
