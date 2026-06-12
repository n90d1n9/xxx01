import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_table_preferences.dart';
import '../models/inventory_product_catalog_table_sort.dart';
import '../models/inventory_product_catalog_table_view_state.dart';
import '../models/inventory_product_catalog_view_mode.dart';

/// Describes a committed product catalog presentation state change.
class InventoryProductCatalogPanelStateChange {
  const InventoryProductCatalogPanelStateChange({
    required this.state,
    this.notifyViewMode = false,
    this.notifyTableView = false,
    this.notifyPreferences = false,
    this.notifySort = false,
  });

  final InventoryProductCatalogPresentationState state;
  final bool notifyViewMode;
  final bool notifyTableView;
  final bool notifyPreferences;
  final bool notifySort;

  /// Resolves a state change from full presentation controls.
  static InventoryProductCatalogPanelStateChange? fromControls({
    required InventoryProductCatalogPresentationState currentState,
    required InventoryProductCatalogPresentationState nextState,
  }) {
    final normalizedCurrentState = currentState.normalized;
    final normalizedNextState = nextState.normalized;
    if (normalizedCurrentState.matches(normalizedNextState)) return null;

    return InventoryProductCatalogPanelStateChange(
      state: normalizedNextState,
      notifyViewMode:
          normalizedCurrentState.viewMode != normalizedNextState.viewMode,
      notifyTableView: !normalizedCurrentState.tableViewState.matches(
        normalizedNextState.tableViewState,
      ),
      notifyPreferences: !normalizedCurrentState.tableViewState.preferences
          .matches(normalizedNextState.tableViewState.preferences),
      notifySort: !normalizedCurrentState.tableViewState.sortState.matches(
        normalizedNextState.tableViewState.sortState,
      ),
    );
  }

  /// Resolves a state change from table preference controls.
  static InventoryProductCatalogPanelStateChange fromTablePreferences({
    required InventoryProductCatalogPresentationState currentState,
    required InventoryProductCatalogTablePreferences preferences,
  }) {
    final nextTableViewState = currentState.tableViewState.copyWith(
      preferences: preferences,
    );

    return fromTableViewState(
      currentState: currentState,
      tableViewState: nextTableViewState,
      notifyPreferences: true,
      notifySort: !nextTableViewState.sortState.matches(
        currentState.tableViewState.sortState,
      ),
    );
  }

  /// Resolves a state change from table sort controls.
  static InventoryProductCatalogPanelStateChange fromTableSortState({
    required InventoryProductCatalogPresentationState currentState,
    required InventoryProductCatalogTableSortState sortState,
  }) {
    return fromTableViewState(
      currentState: currentState,
      tableViewState: currentState.tableViewState.copyWith(
        sortState: sortState,
      ),
      notifySort: true,
    );
  }

  /// Resolves a state change from a table preset selection.
  static InventoryProductCatalogPanelStateChange fromTablePreset({
    required InventoryProductCatalogPresentationState currentState,
    required InventoryProductCatalogTablePreset preset,
  }) {
    return fromTableViewState(
      currentState: currentState,
      tableViewState: preset.viewState,
      notifyPreferences: true,
      notifySort: !preset.viewState.sortState.matches(
        currentState.tableViewState.sortState,
      ),
    );
  }

  /// Resolves a state change from the complete table view state.
  static InventoryProductCatalogPanelStateChange fromTableViewState({
    required InventoryProductCatalogPresentationState currentState,
    required InventoryProductCatalogTableViewState tableViewState,
    bool notifyPreferences = false,
    bool notifySort = false,
  }) {
    return InventoryProductCatalogPanelStateChange(
      state: currentState.copyWith(tableViewState: tableViewState),
      notifyTableView: true,
      notifyPreferences: notifyPreferences,
      notifySort: notifySort,
    );
  }
}

/// Builds the initial product catalog presentation state for the panel.
InventoryProductCatalogPresentationState
initialInventoryProductCatalogPanelState({
  InventoryProductCatalogPresentationState? initialPresentationState,
  required InventoryProductCatalogViewMode initialViewMode,
  InventoryProductCatalogTableViewState? initialTableViewState,
  required InventoryProductCatalogTablePreferences initialTablePreferences,
  required InventoryProductCatalogTableSortState initialTableSortState,
}) {
  return (initialPresentationState ??
          InventoryProductCatalogPresentationState(
            viewMode: initialViewMode,
            tableViewState: initialInventoryProductCatalogPanelTableViewState(
              initialTableViewState: initialTableViewState,
              initialTablePreferences: initialTablePreferences,
              initialTableSortState: initialTableSortState,
            ),
          ))
      .normalized;
}

/// Builds the initial normalized table view state for the catalog panel.
InventoryProductCatalogTableViewState
initialInventoryProductCatalogPanelTableViewState({
  InventoryProductCatalogTableViewState? initialTableViewState,
  required InventoryProductCatalogTablePreferences initialTablePreferences,
  required InventoryProductCatalogTableSortState initialTableSortState,
}) {
  return (initialTableViewState ??
          InventoryProductCatalogTableViewState(
            preferences: initialTablePreferences,
            sortState: initialTableSortState,
          ))
      .normalized;
}
