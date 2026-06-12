import 'product_catalog_preview_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import 'inventory_product_catalog_saved_view_menu_action.dart';
import 'inventory_product_catalog_saved_view_menu_action_handler.dart';
import 'inventory_product_catalog_saved_view_menu_entries.dart';
import 'inventory_product_catalog_saved_view_types.dart';
import 'product_catalog_preview_data.dart';

/// Popup trigger for applying, saving, and maintaining catalog saved views.
class InventoryProductCatalogSavedViewButton extends StatelessWidget {
  const InventoryProductCatalogSavedViewButton({
    super.key,
    required this.savedViews,
    required this.currentPresentationState,
    this.activeSavedViewId,
    this.defaultSavedViewId,
    this.onSelected,
    this.onSaveCurrent,
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
    this.tooltip = 'Saved catalog views',
    this.size = 34,
    this.iconSize = 18,
  });

  final List<InventoryProductCatalogSavedView> savedViews;
  final InventoryProductCatalogPresentationState currentPresentationState;
  final String? activeSavedViewId;
  final String? defaultSavedViewId;
  final ValueChanged<InventoryProductCatalogSavedView>? onSelected;
  final ValueChanged<InventoryProductCatalogPresentationState>? onSaveCurrent;
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
  final String tooltip;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final entries = InventoryProductCatalogSavedViewMenuEntries(
      savedViews: savedViews,
      activeSavedViewId: activeSavedViewId,
      defaultSavedViewId: defaultSavedViewId,
      canSaveCurrent: onSaveCurrent != null,
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
      savedViewSectionLabel: savedViewSectionLabel,
    );
    final actionHandler = InventoryProductCatalogSavedViewMenuActionHandler(
      currentPresentationState: currentPresentationState,
      defaultSavedViewId: defaultSavedViewId,
      onSelected: onSelected,
      onSaveCurrent: onSaveCurrent,
      onCopySavedView: onCopySavedView,
      onRenameSavedView: onRenameSavedView,
      onUpdateSavedView: onUpdateSavedView,
      onDeleteSavedView: onDeleteSavedView,
      onDefaultSavedViewChanged: onDefaultSavedViewChanged,
    );

    return PopupMenuButton<InventoryProductCatalogSavedViewMenuAction>(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      itemBuilder: entries.build,
      onSelected: actionHandler.call,
      child: SizedBox.square(
        dimension: size,
        child: Icon(Icons.bookmarks_rounded, size: iconSize),
      ),
    );
  }
}

@Preview(name: 'Inventory product catalog saved view button')
Widget inventoryProductCatalogSavedViewButtonPreview() {
  final savedViews = inventoryProductCatalogPreviewSavedViews();

  return inventoryProductCatalogPreviewScaffold(
    Center(
      child: InventoryProductCatalogSavedViewButton(
        savedViews: savedViews,
        activeSavedViewId: savedViews.first.id,
        defaultSavedViewId: savedViews.first.id,
        currentPresentationState:
            InventoryProductCatalogPresentationState.defaults,
        onSelected: (_) {},
        onSaveCurrent: (_) {},
        onCopySavedView: (_) {},
        onRenameSavedView: (_) {},
        onUpdateSavedView: (_, _) {},
        onDeleteSavedView: (_) {},
        onDefaultSavedViewChanged: (_) {},
      ),
    ),
  );
}
