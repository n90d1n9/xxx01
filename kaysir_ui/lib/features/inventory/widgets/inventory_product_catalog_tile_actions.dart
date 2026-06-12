import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import 'inventory_row_actions.dart';

class InventoryProductCatalogTileActions extends StatelessWidget {
  const InventoryProductCatalogTileActions({
    super.key,
    required this.record,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  final InventoryProductCatalogRecord record;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InventoryRowActions(
      actions: [
        InventoryRowAction(
          tooltip: 'Edit ${record.productName}',
          icon: Icons.edit_rounded,
          onPressed: onEdit,
        ),
        if (onDuplicate != null)
          InventoryRowAction(
            tooltip: 'Duplicate ${record.productName}',
            icon: Icons.copy_rounded,
            onPressed: onDuplicate,
          ),
        InventoryRowAction(
          tooltip: 'Delete ${record.productName}',
          icon: Icons.delete_outline_rounded,
          onPressed: onDelete,
        ),
      ],
    );
  }
}
