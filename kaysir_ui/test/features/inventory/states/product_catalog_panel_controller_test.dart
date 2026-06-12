import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_preferences.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_sort.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_view_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_view_mode.dart';
import 'package:kaysir/features/inventory/states/product_catalog_panel_controller.dart';

void main() {
  test('catalog panel controller applies saved view changes', () {
    final controller = InventoryProductCatalogPanelController(
      initialViewMode: InventoryProductCatalogViewMode.cards,
      initialTablePreferences: const InventoryProductCatalogTablePreferences(),
      initialTableSortState: const InventoryProductCatalogTableSortState(),
    );
    final savedView = InventoryProductCatalogSavedView(
      id: 'pricing',
      label: 'Pricing',
      description: 'Pricing review',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );

    final change = controller.applySavedView(savedView);

    expect(change, isNotNull);
    expect(change!.notifyViewMode, isTrue);
    expect(change.notifyTableView, isTrue);
    expect(
      controller.presentationState.matches(savedView.presentationState),
      isTrue,
    );
  });

  test(
    'catalog panel controller preserves local state for same initial view',
    () {
      final controller = InventoryProductCatalogPanelController(
        initialViewMode: InventoryProductCatalogViewMode.cards,
        initialTablePreferences:
            const InventoryProductCatalogTablePreferences(),
        initialTableSortState: const InventoryProductCatalogTableSortState(),
      );
      controller.applyTablePreset(InventoryProductCatalogTablePreset.pricing);

      final didReset = controller.syncInitialState(
        initialViewMode: InventoryProductCatalogViewMode.cards,
        initialTablePreferences:
            const InventoryProductCatalogTablePreferences(),
        initialTableSortState: const InventoryProductCatalogTableSortState(),
      );

      expect(didReset, isFalse);
      expect(
        controller.presentationState.tableViewState.matches(
          InventoryProductCatalogTablePreset.pricing.viewState,
        ),
        isTrue,
      );
    },
  );

  test('catalog panel controller resets when initial view changes', () {
    final controller = InventoryProductCatalogPanelController(
      initialViewMode: InventoryProductCatalogViewMode.cards,
      initialTablePreferences: const InventoryProductCatalogTablePreferences(),
      initialTableSortState: const InventoryProductCatalogTableSortState(),
    );
    controller.applyTablePreset(InventoryProductCatalogTablePreset.pricing);

    final didReset = controller.syncInitialState(
      initialViewMode: InventoryProductCatalogViewMode.table,
      initialTablePreferences:
          InventoryProductCatalogTablePreset.stockControl.preferences,
      initialTableSortState:
          InventoryProductCatalogTablePreset.stockControl.sortState,
    );

    expect(didReset, isTrue);
    expect(
      controller.presentationState.tableViewState.matches(
        InventoryProductCatalogTablePreset.stockControl.viewState,
      ),
      isTrue,
    );
  });
}
