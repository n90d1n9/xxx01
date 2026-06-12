import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_saved_view_menu_action.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_saved_view_menu_action_handler.dart';

void main() {
  test('saved view menu action handler routes view actions', () {
    final view = _savedView();
    InventoryProductCatalogSavedView? selected;
    InventoryProductCatalogSavedView? copied;
    InventoryProductCatalogSavedView? renamed;
    InventoryProductCatalogSavedView? updated;
    InventoryProductCatalogSavedView? deleted;
    InventoryProductCatalogPresentationState? updatedState;
    InventoryProductCatalogPresentationState? savedState;

    final handler = InventoryProductCatalogSavedViewMenuActionHandler(
      currentPresentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
      onSelected: (view) => selected = view,
      onSaveCurrent: (state) => savedState = state,
      onCopySavedView: (view) => copied = view,
      onRenameSavedView: (view) => renamed = view,
      onUpdateSavedView: (view, state) {
        updated = view;
        updatedState = state;
      },
      onDeleteSavedView: (view) => deleted = view,
    );

    handler(InventoryProductCatalogSavedViewMenuAction.select(view));
    handler(const InventoryProductCatalogSavedViewMenuAction.saveCurrent());
    handler(InventoryProductCatalogSavedViewMenuAction.copy(view));
    handler(InventoryProductCatalogSavedViewMenuAction.rename(view));
    handler(InventoryProductCatalogSavedViewMenuAction.update(view));
    handler(InventoryProductCatalogSavedViewMenuAction.delete(view));

    expect(selected, view);
    expect(copied, view);
    expect(renamed, view);
    expect(updated, view);
    expect(deleted, view);
    expect(
      updatedState?.matches(
        InventoryProductCatalogPresentationPreset.pricing.presentationState,
      ),
      isTrue,
    );
    expect(
      savedState?.matchingPreset,
      InventoryProductCatalogPresentationPreset.pricing,
    );
  });

  test('saved view menu action handler toggles default view', () {
    final view = _savedView();
    InventoryProductCatalogSavedView? defaultView;
    var clearDefaultCalled = false;

    InventoryProductCatalogSavedViewMenuActionHandler(
      currentPresentationState:
          InventoryProductCatalogPresentationState.defaults,
      onDefaultSavedViewChanged: (view) => defaultView = view,
    )(InventoryProductCatalogSavedViewMenuAction.toggleDefault(view));
    InventoryProductCatalogSavedViewMenuActionHandler(
      currentPresentationState:
          InventoryProductCatalogPresentationState.defaults,
      defaultSavedViewId: view.id,
      onDefaultSavedViewChanged: (view) => clearDefaultCalled = view == null,
    )(InventoryProductCatalogSavedViewMenuAction.toggleDefault(view));

    expect(defaultView, view);
    expect(clearDefaultCalled, isTrue);
  });
}

InventoryProductCatalogSavedView _savedView() {
  return InventoryProductCatalogSavedView(
    id: 'pricing-review',
    label: 'Pricing review',
    description: 'Margin review',
    presentationState:
        InventoryProductCatalogPresentationPreset.pricing.presentationState,
  );
}
