import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_view_mode.dart';

/// Presentation decisions for the product catalog panel trailing controls.
class InventoryProductCatalogPanelTrailingControlsState {
  const InventoryProductCatalogPanelTrailingControlsState({
    required this.showSavedViews,
    required this.showPresentationBadge,
    required this.showTableControls,
  });

  final bool showSavedViews;
  final bool showPresentationBadge;
  final bool showTableControls;

  /// Resolves visibility for saved views, presentation badge, and table tools.
  factory InventoryProductCatalogPanelTrailingControlsState.resolve({
    required InventoryProductCatalogPresentationState presentationState,
    required bool hasSavedViews,
    required bool hasSaveCurrentHandler,
  }) {
    final isTableMode =
        presentationState.viewMode == InventoryProductCatalogViewMode.table;

    return InventoryProductCatalogPanelTrailingControlsState(
      showSavedViews: hasSavedViews || hasSaveCurrentHandler,
      showPresentationBadge: !isTableMode,
      showTableControls: isTableMode,
    );
  }
}
