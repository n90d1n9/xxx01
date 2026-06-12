import 'product_catalog_preview_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_product_catalog_saved_view.dart';
import 'inventory_product_catalog_presentation_badge.dart';
import 'product_catalog_preview_data.dart';
import 'product_catalog_saved_view_menu_action_row.dart';

export 'product_catalog_saved_view_menu_section_header.dart';

/// Menu row for applying and managing one saved product catalog view.
class InventoryProductCatalogSavedViewMenuItem extends StatelessWidget {
  const InventoryProductCatalogSavedViewMenuItem({
    super.key,
    required this.view,
    required this.selected,
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
  final bool selected;
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final preset = view.presentationState.matchingPreset;
    final icon =
        preset == null
            ? inventoryProductCatalogPresentationModeIcon(
              view.presentationState.viewMode,
            )
            : inventoryProductCatalogPresentationPresetIcon(preset);
    final actionRow = InventoryProductCatalogSavedViewMenuActionRow(
      view: view,
      defaulted: defaulted,
      canCopy: canCopy,
      canRename: canRename,
      canUpdate: canUpdate,
      canDelete: canDelete,
      canSetDefault: canSetDefault,
      onCopy: onCopy,
      onRename: onRename,
      onUpdate: onUpdate,
      onDelete: onDelete,
      onToggleDefault: onToggleDefault,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.check_circle_rounded : icon,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(view.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle:
          inventoryProductCatalogSavedViewSubtitle(view, defaulted).isEmpty
              ? null
              : Text(
                inventoryProductCatalogSavedViewSubtitle(view, defaulted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      trailing: actionRow.hasActions ? actionRow : null,
    );
  }
}

@Preview(name: 'Inventory product catalog saved view menu item')
Widget inventoryProductCatalogSavedViewMenuItemPreview() {
  final view = inventoryProductCatalogPreviewSavedViews().first;

  return inventoryProductCatalogPreviewScaffold(
    InventoryProductCatalogSavedViewMenuItem(
      view: view,
      selected: true,
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

String inventoryProductCatalogSavedViewSubtitle(
  InventoryProductCatalogSavedView view,
  bool defaulted,
) {
  final description = view.description.trim();
  if (!defaulted) return description;
  if (description.isEmpty) return 'Default startup view';

  return 'Default startup view - $description';
}
