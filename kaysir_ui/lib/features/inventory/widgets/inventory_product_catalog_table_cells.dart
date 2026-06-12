import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_visuals.dart';
import 'inventory_row_actions.dart';

class InventoryProductCatalogTableProductCell extends StatelessWidget {
  const InventoryProductCatalogTableProductCell({
    super.key,
    required this.record,
  });

  final InventoryProductCatalogRecord record;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${record.skuLabel} | ${record.scanCodeLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryProductCatalogTableStatusCell extends StatelessWidget {
  const InventoryProductCatalogTableStatusCell({
    super.key,
    required this.record,
  });

  final InventoryProductCatalogRecord record;

  @override
  Widget build(BuildContext context) {
    final visuals = inventoryProductCatalogStatusVisuals(record.status);

    return AppStatusPill(
      label: inventoryProductCatalogStatusLabel(record.status),
      icon: visuals.icon,
      color: visuals.color,
      maxWidth: 132,
    );
  }
}

class InventoryProductCatalogTableTextCell extends StatelessWidget {
  const InventoryProductCatalogTableTextCell(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class InventoryProductCatalogTableNumberCell extends StatelessWidget {
  const InventoryProductCatalogTableNumberCell(
    this.value, {
    super.key,
    this.emphasized = false,
  });

  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      value,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: emphasized ? colorScheme.error : null,
        fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
      ),
    );
  }
}

class InventoryProductCatalogTableSignalsCell extends StatelessWidget {
  const InventoryProductCatalogTableSignalsCell({
    super.key,
    required this.footer,
    this.compact = false,
  });

  final Widget? footer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (footer == null) {
      return const SizedBox(
        width: 180,
        height: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('No signals'),
        ),
      );
    }

    return SizedBox(
      width: 360,
      height: compact ? 52 : 72,
      child: SingleChildScrollView(child: footer!),
    );
  }
}

class InventoryProductCatalogTableActionsCell extends StatelessWidget {
  const InventoryProductCatalogTableActionsCell({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final InventoryProductCatalogRecord record;
  final ValueChanged<InventoryProductCatalogRecord>? onEdit;
  final ValueChanged<InventoryProductCatalogRecord>? onDuplicate;
  final ValueChanged<InventoryProductCatalogRecord>? onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 42,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InventoryRowActions(
          actions: [
            InventoryRowAction(
              tooltip: 'Edit ${record.productName}',
              icon: Icons.edit_rounded,
              onPressed: onEdit == null ? null : () => onEdit!(record),
            ),
            if (onDuplicate != null)
              InventoryRowAction(
                tooltip: 'Duplicate ${record.productName}',
                icon: Icons.copy_rounded,
                onPressed: () => onDuplicate!(record),
              ),
            InventoryRowAction(
              tooltip: 'Delete ${record.productName}',
              icon: Icons.delete_outline_rounded,
              onPressed: onDelete == null ? null : () => onDelete!(record),
            ),
          ],
        ),
      ),
    );
  }
}
