import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_preferences.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_sort.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_view_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_view_mode.dart';
import 'package:kaysir/features/inventory/states/product_catalog_panel_state.dart';

void main() {
  test('panel initial state normalizes table settings', () {
    final state = initialInventoryProductCatalogPanelState(
      initialViewMode: InventoryProductCatalogViewMode.table,
      initialTablePreferences:
          InventoryProductCatalogTablePreset.pricing.preferences,
      initialTableSortState: const InventoryProductCatalogTableSortState(
        column: InventoryProductCatalogTableColumn.stock,
      ),
    );

    expect(state.viewMode, InventoryProductCatalogViewMode.table);
    expect(
      state.tableViewState.preferences.matches(
        InventoryProductCatalogTablePreset.pricing.preferences,
      ),
      isTrue,
    );
    expect(
      state.tableViewState.sortState.column,
      InventoryProductCatalogTableColumn.product,
    );
  });

  test('panel state change reports presentation control notifications', () {
    final change = InventoryProductCatalogPanelStateChange.fromControls(
      currentState: InventoryProductCatalogPresentationState.defaults,
      nextState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );

    expect(change, isNotNull);
    expect(change!.notifyViewMode, isTrue);
    expect(change.notifyTableView, isTrue);
    expect(change.notifyPreferences, isTrue);
    expect(change.notifySort, isTrue);

    expect(
      InventoryProductCatalogPanelStateChange.fromControls(
        currentState: change.state,
        nextState: change.state,
      ),
      isNull,
    );
  });

  test('panel state change reports table preset notifications', () {
    final change = InventoryProductCatalogPanelStateChange.fromTablePreset(
      currentState: InventoryProductCatalogPresentationState.defaults,
      preset: InventoryProductCatalogTablePreset.pricing,
    );

    expect(change.notifyViewMode, isFalse);
    expect(change.notifyTableView, isTrue);
    expect(change.notifyPreferences, isTrue);
    expect(change.notifySort, isTrue);
    expect(
      change.state.tableViewState.matches(
        InventoryProductCatalogTablePreset.pricing.viewState,
      ),
      isTrue,
    );
  });
}
