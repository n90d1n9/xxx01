import '../models/inventory_product_catalog_saved_view.dart';

/// Typed action emitted by the saved product catalog view popup menu.
class InventoryProductCatalogSavedViewMenuAction {
  const InventoryProductCatalogSavedViewMenuAction.select(
    InventoryProductCatalogSavedView view,
  ) : this._(InventoryProductCatalogSavedViewMenuActionType.select, view);

  const InventoryProductCatalogSavedViewMenuAction.saveCurrent()
    : this._(InventoryProductCatalogSavedViewMenuActionType.saveCurrent);

  const InventoryProductCatalogSavedViewMenuAction.copy(
    InventoryProductCatalogSavedView view,
  ) : this._(InventoryProductCatalogSavedViewMenuActionType.copy, view);

  const InventoryProductCatalogSavedViewMenuAction.rename(
    InventoryProductCatalogSavedView view,
  ) : this._(InventoryProductCatalogSavedViewMenuActionType.rename, view);

  const InventoryProductCatalogSavedViewMenuAction.update(
    InventoryProductCatalogSavedView view,
  ) : this._(InventoryProductCatalogSavedViewMenuActionType.update, view);

  const InventoryProductCatalogSavedViewMenuAction.delete(
    InventoryProductCatalogSavedView view,
  ) : this._(InventoryProductCatalogSavedViewMenuActionType.delete, view);

  const InventoryProductCatalogSavedViewMenuAction.toggleDefault(
    InventoryProductCatalogSavedView view,
  ) : this._(
        InventoryProductCatalogSavedViewMenuActionType.toggleDefault,
        view,
      );

  const InventoryProductCatalogSavedViewMenuAction._(this.type, [this.view]);

  final InventoryProductCatalogSavedViewMenuActionType type;
  final InventoryProductCatalogSavedView? view;
}

/// Supported saved product catalog view popup menu action types.
enum InventoryProductCatalogSavedViewMenuActionType {
  select,
  saveCurrent,
  copy,
  rename,
  update,
  delete,
  toggleDefault,
}
