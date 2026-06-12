import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/states/product_catalog_panel_trailing_controls_state.dart';

void main() {
  test('catalog trailing controls state resolves card mode visibility', () {
    final state = InventoryProductCatalogPanelTrailingControlsState.resolve(
      presentationState: InventoryProductCatalogPresentationState.defaults,
      hasSavedViews: false,
      hasSaveCurrentHandler: true,
    );

    expect(state.showSavedViews, isTrue);
    expect(state.showPresentationBadge, isTrue);
    expect(state.showTableControls, isFalse);
  });

  test('catalog trailing controls state resolves table mode visibility', () {
    final state = InventoryProductCatalogPanelTrailingControlsState.resolve(
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
      hasSavedViews: false,
      hasSaveCurrentHandler: false,
    );

    expect(state.showSavedViews, isFalse);
    expect(state.showPresentationBadge, isFalse);
    expect(state.showTableControls, isTrue);
  });
}
