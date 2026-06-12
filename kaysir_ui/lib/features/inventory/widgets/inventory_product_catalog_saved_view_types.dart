import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';

typedef InventoryProductCatalogSavedViewStateChanged =
    void Function(
      InventoryProductCatalogSavedView view,
      InventoryProductCatalogPresentationState presentationState,
    );

typedef InventoryProductCatalogSavedViewDefaultChanged =
    void Function(InventoryProductCatalogSavedView? view);

typedef InventoryProductCatalogSavedViewActionPredicate =
    bool Function(InventoryProductCatalogSavedView view);

typedef InventoryProductCatalogSavedViewSectionLabel =
    String? Function(InventoryProductCatalogSavedView view);
