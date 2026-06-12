import 'product_catalog_preview_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_product_catalog_saved_view.dart';
import 'product_catalog_preview_data.dart';

/// Compact action row for maintaining one saved product catalog view.
class InventoryProductCatalogSavedViewMenuActionRow extends StatelessWidget {
  const InventoryProductCatalogSavedViewMenuActionRow({
    super.key,
    required this.view,
    required this.defaulted,
    required this.canCopy,
    required this.canRename,
    required this.canUpdate,
    required this.canDelete,
    required this.canSetDefault,
    required this.onCopy,
    required this.onRename,
    required this.onUpdate,
    required this.onDelete,
    required this.onToggleDefault,
  });

  final InventoryProductCatalogSavedView view;
  final bool defaulted;
  final bool canCopy;
  final bool canRename;
  final bool canUpdate;
  final bool canDelete;
  final bool canSetDefault;
  final VoidCallback onCopy;
  final VoidCallback onRename;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onToggleDefault;

  bool get hasActions {
    return canCopy || canRename || canUpdate || canDelete || canSetDefault;
  }

  @override
  Widget build(BuildContext context) {
    if (!hasActions) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canSetDefault)
          IconButton(
            key: ValueKey(
              'inventory-product-catalog-default-saved-view-${view.id}',
            ),
            tooltip:
                defaulted
                    ? 'Clear default ${view.label}'
                    : 'Set ${view.label} as default',
            icon: Icon(
              defaulted ? Icons.star_rounded : Icons.star_outline_rounded,
            ),
            color:
                defaulted ? colorScheme.primary : colorScheme.onSurfaceVariant,
            visualDensity: VisualDensity.compact,
            onPressed: onToggleDefault,
          ),
        if (canCopy)
          IconButton(
            key: ValueKey(
              'inventory-product-catalog-copy-saved-view-${view.id}',
            ),
            tooltip: 'Save editable copy of ${view.label}',
            icon: const Icon(Icons.bookmark_add_outlined),
            visualDensity: VisualDensity.compact,
            onPressed: onCopy,
          ),
        if (canRename)
          IconButton(
            key: ValueKey(
              'inventory-product-catalog-rename-saved-view-${view.id}',
            ),
            tooltip: 'Rename ${view.label}',
            icon: const Icon(Icons.edit_outlined),
            visualDensity: VisualDensity.compact,
            onPressed: onRename,
          ),
        if (canUpdate)
          IconButton(
            key: ValueKey(
              'inventory-product-catalog-update-saved-view-${view.id}',
            ),
            tooltip: 'Update ${view.label}',
            icon: const Icon(Icons.update_rounded),
            visualDensity: VisualDensity.compact,
            onPressed: onUpdate,
          ),
        if (canDelete)
          IconButton(
            key: ValueKey(
              'inventory-product-catalog-delete-saved-view-${view.id}',
            ),
            tooltip: 'Delete ${view.label}',
            icon: const Icon(Icons.delete_outline_rounded),
            color: colorScheme.error,
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
      ],
    );
  }
}

@Preview(name: 'Inventory product catalog saved view menu action row')
Widget inventoryProductCatalogSavedViewMenuActionRowPreview() {
  return inventoryProductCatalogPreviewScaffold(
    InventoryProductCatalogSavedViewMenuActionRow(
      view: inventoryProductCatalogPreviewSavedViews().first,
      defaulted: true,
      canCopy: true,
      canRename: true,
      canUpdate: true,
      canDelete: true,
      canSetDefault: true,
      onCopy: () {},
      onRename: () {},
      onUpdate: () {},
      onDelete: () {},
      onToggleDefault: () {},
    ),
  );
}
