import 'package:flutter/foundation.dart';

import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import 'inventory_product_catalog_saved_view_menu_action.dart';
import 'inventory_product_catalog_saved_view_types.dart';

/// Dispatches saved catalog view menu actions to the configured callbacks.
class InventoryProductCatalogSavedViewMenuActionHandler {
  const InventoryProductCatalogSavedViewMenuActionHandler({
    required this.currentPresentationState,
    this.defaultSavedViewId,
    this.onSelected,
    this.onSaveCurrent,
    this.onCopySavedView,
    this.onRenameSavedView,
    this.onUpdateSavedView,
    this.onDeleteSavedView,
    this.onDefaultSavedViewChanged,
  });

  final InventoryProductCatalogPresentationState currentPresentationState;
  final String? defaultSavedViewId;
  final ValueChanged<InventoryProductCatalogSavedView>? onSelected;
  final ValueChanged<InventoryProductCatalogPresentationState>? onSaveCurrent;
  final ValueChanged<InventoryProductCatalogSavedView>? onCopySavedView;
  final ValueChanged<InventoryProductCatalogSavedView>? onRenameSavedView;
  final InventoryProductCatalogSavedViewStateChanged? onUpdateSavedView;
  final ValueChanged<InventoryProductCatalogSavedView>? onDeleteSavedView;
  final InventoryProductCatalogSavedViewDefaultChanged?
  onDefaultSavedViewChanged;

  /// Routes the selected menu action to the matching callback.
  void call(InventoryProductCatalogSavedViewMenuAction action) {
    switch (action.type) {
      case InventoryProductCatalogSavedViewMenuActionType.select:
        final view = action.view;
        if (view != null) onSelected?.call(view);
        return;
      case InventoryProductCatalogSavedViewMenuActionType.saveCurrent:
        onSaveCurrent?.call(currentPresentationState);
        return;
      case InventoryProductCatalogSavedViewMenuActionType.copy:
        final view = action.view;
        if (view != null) onCopySavedView?.call(view);
        return;
      case InventoryProductCatalogSavedViewMenuActionType.rename:
        final view = action.view;
        if (view != null) onRenameSavedView?.call(view);
        return;
      case InventoryProductCatalogSavedViewMenuActionType.update:
        final view = action.view;
        if (view != null) {
          onUpdateSavedView?.call(view, currentPresentationState);
        }
        return;
      case InventoryProductCatalogSavedViewMenuActionType.delete:
        final view = action.view;
        if (view != null) onDeleteSavedView?.call(view);
        return;
      case InventoryProductCatalogSavedViewMenuActionType.toggleDefault:
        final view = action.view;
        if (view == null) return;

        onDefaultSavedViewChanged?.call(
          view.id == defaultSavedViewId ? null : view,
        );
        return;
    }
  }
}
