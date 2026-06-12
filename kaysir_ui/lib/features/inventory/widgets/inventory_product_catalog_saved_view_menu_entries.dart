import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_saved_view.dart';
import 'inventory_product_catalog_saved_view_menu_action.dart';
import 'inventory_product_catalog_saved_view_menu_item.dart';
import 'inventory_product_catalog_saved_view_menu_sections.dart';
import 'inventory_product_catalog_saved_view_types.dart';
import 'product_catalog_saved_view_menu_action_availability.dart';

/// Builds popup menu entries for saved product catalog views.
class InventoryProductCatalogSavedViewMenuEntries {
  const InventoryProductCatalogSavedViewMenuEntries({
    required this.savedViews,
    this.activeSavedViewId,
    this.defaultSavedViewId,
    this.canSaveCurrent = false,
    this.onCopySavedView,
    this.onRenameSavedView,
    this.onUpdateSavedView,
    this.onDeleteSavedView,
    this.onDefaultSavedViewChanged,
    this.canCopySavedView,
    this.canRenameSavedView,
    this.canUpdateSavedView,
    this.canDeleteSavedView,
    this.canSetDefaultSavedView,
    this.savedViewSectionLabel,
  });

  final List<InventoryProductCatalogSavedView> savedViews;
  final String? activeSavedViewId;
  final String? defaultSavedViewId;
  final bool canSaveCurrent;
  final ValueChanged<InventoryProductCatalogSavedView>? onCopySavedView;
  final ValueChanged<InventoryProductCatalogSavedView>? onRenameSavedView;
  final InventoryProductCatalogSavedViewStateChanged? onUpdateSavedView;
  final ValueChanged<InventoryProductCatalogSavedView>? onDeleteSavedView;
  final InventoryProductCatalogSavedViewDefaultChanged?
  onDefaultSavedViewChanged;
  final InventoryProductCatalogSavedViewActionPredicate? canCopySavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canRenameSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canUpdateSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canDeleteSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canSetDefaultSavedView;
  final InventoryProductCatalogSavedViewSectionLabel? savedViewSectionLabel;

  /// Builds popup entries for sections, saved views, empty state, and save.
  List<PopupMenuEntry<InventoryProductCatalogSavedViewMenuAction>> build(
    BuildContext context,
  ) {
    final availabilityResolver =
        InventoryProductCatalogSavedViewMenuActionAvailabilityResolver(
          onCopySavedView: onCopySavedView,
          onRenameSavedView: onRenameSavedView,
          onUpdateSavedView: onUpdateSavedView,
          onDeleteSavedView: onDeleteSavedView,
          onDefaultSavedViewChanged: onDefaultSavedViewChanged,
          canCopySavedView: canCopySavedView,
          canRenameSavedView: canRenameSavedView,
          canUpdateSavedView: canUpdateSavedView,
          canDeleteSavedView: canDeleteSavedView,
          canSetDefaultSavedView: canSetDefaultSavedView,
        );

    return [
      for (final section in inventoryProductCatalogSavedViewMenuSections(
        savedViews,
        savedViewSectionLabel,
      )) ...[
        if (section.label != null)
          PopupMenuItem(
            key: ValueKey(
              'inventory-product-catalog-saved-view-section-${inventoryProductCatalogSavedViewMenuKeyPart(section.label!)}',
            ),
            enabled: false,
            height: 34,
            child: InventoryProductCatalogSavedViewMenuSectionHeader(
              label: section.label!,
            ),
          ),
        for (final view in section.views)
          PopupMenuItem(
            key: ValueKey('inventory-product-catalog-saved-view-${view.id}'),
            value: InventoryProductCatalogSavedViewMenuAction.select(view),
            child: _savedViewMenuItem(
              context,
              view,
              availabilityResolver.resolve(view),
            ),
          ),
      ],
      if (savedViews.isNotEmpty) const PopupMenuDivider(),
      if (savedViews.isEmpty)
        const PopupMenuItem(enabled: false, child: Text('No saved views yet')),
      if (canSaveCurrent)
        const PopupMenuItem(
          key: ValueKey('inventory-product-catalog-save-current-view'),
          value: InventoryProductCatalogSavedViewMenuAction.saveCurrent(),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.bookmark_add_rounded),
            title: Text('Save current view'),
            subtitle: Text('Store this catalog layout for later'),
          ),
        ),
    ];
  }

  InventoryProductCatalogSavedViewMenuItem _savedViewMenuItem(
    BuildContext context,
    InventoryProductCatalogSavedView view,
    InventoryProductCatalogSavedViewMenuActionAvailability availability,
  ) {
    return InventoryProductCatalogSavedViewMenuItem(
      view: view,
      selected: view.id == activeSavedViewId,
      defaulted: view.id == defaultSavedViewId,
      canCopy: availability.canCopy,
      canRename: availability.canRename,
      canUpdate: availability.canUpdate,
      canDelete: availability.canDelete,
      canSetDefault: availability.canSetDefault,
      onCopy:
          () => Navigator.of(
            context,
          ).pop(InventoryProductCatalogSavedViewMenuAction.copy(view)),
      onRename:
          () => Navigator.of(
            context,
          ).pop(InventoryProductCatalogSavedViewMenuAction.rename(view)),
      onUpdate:
          () => Navigator.of(
            context,
          ).pop(InventoryProductCatalogSavedViewMenuAction.update(view)),
      onDelete:
          () => Navigator.of(
            context,
          ).pop(InventoryProductCatalogSavedViewMenuAction.delete(view)),
      onToggleDefault:
          () => Navigator.of(
            context,
          ).pop(InventoryProductCatalogSavedViewMenuAction.toggleDefault(view)),
    );
  }
}
