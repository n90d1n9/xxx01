import 'package:flutter/foundation.dart';

import '../models/inventory_product_catalog_saved_view.dart';
import 'inventory_product_catalog_saved_view_menu_sections.dart';
import 'inventory_product_catalog_saved_view_types.dart';

/// Describes which maintenance actions are available for one saved view row.
class InventoryProductCatalogSavedViewMenuActionAvailability {
  const InventoryProductCatalogSavedViewMenuActionAvailability({
    required this.canCopy,
    required this.canRename,
    required this.canUpdate,
    required this.canDelete,
    required this.canSetDefault,
  });

  final bool canCopy;
  final bool canRename;
  final bool canUpdate;
  final bool canDelete;
  final bool canSetDefault;

  bool get hasActions {
    return canCopy || canRename || canUpdate || canDelete || canSetDefault;
  }
}

/// Resolves saved view row action availability from callbacks and predicates.
class InventoryProductCatalogSavedViewMenuActionAvailabilityResolver {
  const InventoryProductCatalogSavedViewMenuActionAvailabilityResolver({
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
  });

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

  /// Returns action availability for a saved view row.
  InventoryProductCatalogSavedViewMenuActionAvailability resolve(
    InventoryProductCatalogSavedView view,
  ) {
    return InventoryProductCatalogSavedViewMenuActionAvailability(
      canCopy: _canRunAction(onCopySavedView, canCopySavedView, view),
      canRename: _canRunAction(onRenameSavedView, canRenameSavedView, view),
      canUpdate: _canRunAction(onUpdateSavedView, canUpdateSavedView, view),
      canDelete: _canRunAction(onDeleteSavedView, canDeleteSavedView, view),
      canSetDefault: _canRunAction(
        onDefaultSavedViewChanged,
        canSetDefaultSavedView,
        view,
      ),
    );
  }

  bool _canRunAction(
    Object? callback,
    InventoryProductCatalogSavedViewActionPredicate? predicate,
    InventoryProductCatalogSavedView view,
  ) {
    return callback != null &&
        inventoryProductCatalogSavedViewCanRunAction(predicate, view);
  }
}
