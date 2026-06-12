import 'inventory_product_catalog_table_view_state.dart';
import 'inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_view_mode.dart';

enum InventoryProductCatalogPresentationPreset {
  cards,
  operationsTable,
  stockControl,
  pricing,
  channelSignals,
}

extension InventoryProductCatalogPresentationPresetDetails
    on InventoryProductCatalogPresentationPreset {
  String get key {
    switch (this) {
      case InventoryProductCatalogPresentationPreset.cards:
        return 'cards';
      case InventoryProductCatalogPresentationPreset.operationsTable:
        return 'operations-table';
      case InventoryProductCatalogPresentationPreset.stockControl:
        return 'stock-control';
      case InventoryProductCatalogPresentationPreset.pricing:
        return 'pricing';
      case InventoryProductCatalogPresentationPreset.channelSignals:
        return 'channel-signals';
    }
  }

  String get label {
    switch (this) {
      case InventoryProductCatalogPresentationPreset.cards:
        return 'Cards';
      case InventoryProductCatalogPresentationPreset.operationsTable:
        return 'Operations table';
      case InventoryProductCatalogPresentationPreset.stockControl:
        return 'Stock control';
      case InventoryProductCatalogPresentationPreset.pricing:
        return 'Pricing review';
      case InventoryProductCatalogPresentationPreset.channelSignals:
        return 'Channel signals';
    }
  }

  String get description {
    switch (this) {
      case InventoryProductCatalogPresentationPreset.cards:
        return 'Default product cards and action tiles';
      case InventoryProductCatalogPresentationPreset.operationsTable:
        return 'Full table view for catalog operations';
      case InventoryProductCatalogPresentationPreset.stockControl:
        return 'Inventory quantities and replenishment risk';
      case InventoryProductCatalogPresentationPreset.pricing:
        return 'Price, value, and margin review';
      case InventoryProductCatalogPresentationPreset.channelSignals:
        return 'Channel readiness and selling signals';
    }
  }

  InventoryProductCatalogPresentationState get presentationState {
    switch (this) {
      case InventoryProductCatalogPresentationPreset.cards:
        return InventoryProductCatalogPresentationState.defaults;
      case InventoryProductCatalogPresentationPreset.operationsTable:
        return InventoryProductCatalogPresentationState(
          viewMode: InventoryProductCatalogViewMode.table,
          tableViewState:
              InventoryProductCatalogTablePreset.operations.viewState,
        );
      case InventoryProductCatalogPresentationPreset.stockControl:
        return InventoryProductCatalogPresentationState(
          viewMode: InventoryProductCatalogViewMode.table,
          tableViewState:
              InventoryProductCatalogTablePreset.stockControl.viewState,
        );
      case InventoryProductCatalogPresentationPreset.pricing:
        return InventoryProductCatalogPresentationState(
          viewMode: InventoryProductCatalogViewMode.table,
          tableViewState: InventoryProductCatalogTablePreset.pricing.viewState,
        );
      case InventoryProductCatalogPresentationPreset.channelSignals:
        return InventoryProductCatalogPresentationState(
          viewMode: InventoryProductCatalogViewMode.table,
          tableViewState:
              InventoryProductCatalogTablePreset.channelSignals.viewState,
        );
    }
  }
}

class InventoryProductCatalogPresentationState {
  const InventoryProductCatalogPresentationState({
    this.viewMode = InventoryProductCatalogViewMode.cards,
    this.tableViewState = const InventoryProductCatalogTableViewState(),
  });

  factory InventoryProductCatalogPresentationState.fromJson(
    Map<String, Object?> json,
  ) {
    return InventoryProductCatalogPresentationState(
      viewMode: decodeInventoryProductCatalogViewMode(json[_viewModeJsonKey]),
      tableViewState: InventoryProductCatalogTableViewState.fromJson(
        _objectMap(json[_tableViewStateJsonKey]),
      ),
    ).normalized;
  }

  static const _viewModeJsonKey = 'viewMode';
  static const _tableViewStateJsonKey = 'tableViewState';
  static const defaults = InventoryProductCatalogPresentationState();

  final InventoryProductCatalogViewMode viewMode;
  final InventoryProductCatalogTableViewState tableViewState;

  InventoryProductCatalogPresentationState get normalized {
    final normalizedTableViewState = tableViewState.normalized;
    if (normalizedTableViewState.matches(tableViewState)) return this;

    return copyWith(tableViewState: normalizedTableViewState);
  }

  Map<String, Object> toJson() {
    return {
      _viewModeJsonKey: viewMode.key,
      _tableViewStateJsonKey: tableViewState.normalized.toJson(),
    };
  }

  InventoryProductCatalogPresentationState copyWith({
    InventoryProductCatalogViewMode? viewMode,
    InventoryProductCatalogTableViewState? tableViewState,
  }) {
    return InventoryProductCatalogPresentationState(
      viewMode: viewMode ?? this.viewMode,
      tableViewState: tableViewState ?? this.tableViewState,
    ).normalized;
  }

  bool matches(InventoryProductCatalogPresentationState other) {
    return viewMode == other.viewMode &&
        tableViewState.matches(other.tableViewState);
  }

  bool get isDefault {
    return matches(defaults);
  }

  InventoryProductCatalogPresentationState showContributionColumn(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    return setContributionColumnVisibility(
      contributionId,
      visible: true,
      defaultVisible: defaultVisible,
    );
  }

  InventoryProductCatalogPresentationState hideContributionColumn(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    return setContributionColumnVisibility(
      contributionId,
      visible: false,
      defaultVisible: defaultVisible,
    );
  }

  InventoryProductCatalogPresentationState setContributionColumnVisibility(
    String contributionId, {
    required bool visible,
    bool defaultVisible = true,
  }) {
    return copyWith(
      tableViewState: tableViewState.setContributionColumnVisibility(
        contributionId,
        visible: visible,
        defaultVisible: defaultVisible,
      ),
    );
  }

  InventoryProductCatalogPresentationPreset? get matchingPreset {
    for (final preset in InventoryProductCatalogPresentationPreset.values) {
      if (matches(preset.presentationState)) return preset;
    }

    return null;
  }
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is! Map) return const {};

  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}
