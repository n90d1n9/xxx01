import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import '../models/inventory_product_catalog_table_preferences.dart';
import '../models/inventory_product_catalog_table_sort.dart';
import '../models/inventory_product_catalog_table_view_state.dart';
import '../models/inventory_product_catalog_view_mode.dart';
import 'product_catalog_panel_state.dart';

/// Coordinates product catalog panel presentation state mutations.
class InventoryProductCatalogPanelController {
  InventoryProductCatalogPanelController({
    InventoryProductCatalogPresentationState? initialPresentationState,
    required InventoryProductCatalogViewMode initialViewMode,
    InventoryProductCatalogTableViewState? initialTableViewState,
    required InventoryProductCatalogTablePreferences initialTablePreferences,
    required InventoryProductCatalogTableSortState initialTableSortState,
  }) : this._(
         initialInventoryProductCatalogPanelState(
           initialPresentationState: initialPresentationState,
           initialViewMode: initialViewMode,
           initialTableViewState: initialTableViewState,
           initialTablePreferences: initialTablePreferences,
           initialTableSortState: initialTableSortState,
         ),
       );

  InventoryProductCatalogPanelController._(
    InventoryProductCatalogPresentationState initialState,
  ) : _initialState = initialState,
      _presentationState = initialState;

  InventoryProductCatalogPresentationState _initialState;
  InventoryProductCatalogPresentationState _presentationState;

  InventoryProductCatalogPresentationState get presentationState {
    return _presentationState;
  }

  /// Resets panel state only when the caller supplies a different initial view.
  bool syncInitialState({
    InventoryProductCatalogPresentationState? initialPresentationState,
    required InventoryProductCatalogViewMode initialViewMode,
    InventoryProductCatalogTableViewState? initialTableViewState,
    required InventoryProductCatalogTablePreferences initialTablePreferences,
    required InventoryProductCatalogTableSortState initialTableSortState,
  }) {
    final nextInitialState = initialInventoryProductCatalogPanelState(
      initialPresentationState: initialPresentationState,
      initialViewMode: initialViewMode,
      initialTableViewState: initialTableViewState,
      initialTablePreferences: initialTablePreferences,
      initialTableSortState: initialTableSortState,
    );

    if (nextInitialState.matches(_initialState)) return false;
    _initialState = nextInitialState;
    _presentationState = nextInitialState;
    return true;
  }

  /// Applies a saved view and returns the notification contract for callers.
  InventoryProductCatalogPanelStateChange? applySavedView(
    InventoryProductCatalogSavedView view,
  ) {
    return setPresentationStateFromControls(view.presentationState);
  }

  /// Applies a full presentation state from toolbar controls.
  InventoryProductCatalogPanelStateChange? setPresentationStateFromControls(
    InventoryProductCatalogPresentationState state,
  ) {
    return _commit(
      InventoryProductCatalogPanelStateChange.fromControls(
        currentState: _presentationState,
        nextState: state,
      ),
    );
  }

  /// Applies table display preferences from column controls.
  InventoryProductCatalogPanelStateChange? setTablePreferences(
    InventoryProductCatalogTablePreferences preferences,
  ) {
    return _commit(
      InventoryProductCatalogPanelStateChange.fromTablePreferences(
        currentState: _presentationState,
        preferences: preferences,
      ),
    );
  }

  /// Applies table sorting state from row controls.
  InventoryProductCatalogPanelStateChange? setTableSortState(
    InventoryProductCatalogTableSortState sortState,
  ) {
    return _commit(
      InventoryProductCatalogPanelStateChange.fromTableSortState(
        currentState: _presentationState,
        sortState: sortState,
      ),
    );
  }

  /// Applies a table preset from the presentation menu.
  InventoryProductCatalogPanelStateChange? applyTablePreset(
    InventoryProductCatalogTablePreset preset,
  ) {
    return _commit(
      InventoryProductCatalogPanelStateChange.fromTablePreset(
        currentState: _presentationState,
        preset: preset,
      ),
    );
  }

  InventoryProductCatalogPanelStateChange? _commit(
    InventoryProductCatalogPanelStateChange? change,
  ) {
    if (change == null) return null;
    _presentationState = change.state;
    return change;
  }
}
