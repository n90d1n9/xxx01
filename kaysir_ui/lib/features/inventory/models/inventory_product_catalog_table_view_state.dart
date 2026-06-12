import 'inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_table_sort.dart';

class InventoryProductCatalogTableViewState {
  const InventoryProductCatalogTableViewState({
    this.preferences = const InventoryProductCatalogTablePreferences(),
    this.sortState = const InventoryProductCatalogTableSortState(),
  });

  factory InventoryProductCatalogTableViewState.fromJson(
    Map<String, Object?> json,
  ) {
    return InventoryProductCatalogTableViewState(
      preferences: InventoryProductCatalogTablePreferences.fromJson(
        _objectMap(json[_preferencesJsonKey]),
      ),
      sortState: InventoryProductCatalogTableSortState.fromJson(
        _objectMap(json[_sortJsonKey]),
      ),
    ).normalized;
  }

  static const _preferencesJsonKey = 'preferences';
  static const _sortJsonKey = 'sort';

  final InventoryProductCatalogTablePreferences preferences;
  final InventoryProductCatalogTableSortState sortState;

  InventoryProductCatalogTableViewState get normalized {
    if (preferences.supportsSortColumn(sortState.column)) return this;

    return copyWith(sortState: const InventoryProductCatalogTableSortState());
  }

  Map<String, Object> toJson() {
    return {
      _preferencesJsonKey: preferences.toJson(),
      _sortJsonKey: sortState.toJson(),
    };
  }

  InventoryProductCatalogTableViewState copyWith({
    InventoryProductCatalogTablePreferences? preferences,
    InventoryProductCatalogTableSortState? sortState,
  }) {
    final nextPreferences = preferences ?? this.preferences;
    final nextSortState = sortState ?? this.sortState;

    return InventoryProductCatalogTableViewState(
      preferences: nextPreferences,
      sortState:
          nextPreferences.supportsSortColumn(nextSortState.column)
              ? nextSortState
              : const InventoryProductCatalogTableSortState(),
    );
  }

  bool matches(InventoryProductCatalogTableViewState other) {
    return preferences.matches(other.preferences) &&
        sortState.matches(other.sortState);
  }

  InventoryProductCatalogTableViewState showContributionColumn(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    return setContributionColumnVisibility(
      contributionId,
      visible: true,
      defaultVisible: defaultVisible,
    );
  }

  InventoryProductCatalogTableViewState hideContributionColumn(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    return setContributionColumnVisibility(
      contributionId,
      visible: false,
      defaultVisible: defaultVisible,
    );
  }

  InventoryProductCatalogTableViewState setContributionColumnVisibility(
    String contributionId, {
    required bool visible,
    bool defaultVisible = true,
  }) {
    return copyWith(
      preferences: preferences.setContributionColumnVisibility(
        contributionId,
        visible: visible,
        defaultVisible: defaultVisible,
      ),
    );
  }
}

extension InventoryProductCatalogTablePresetViewStateDetails
    on InventoryProductCatalogTablePreset {
  InventoryProductCatalogTableSortState get sortState {
    switch (this) {
      case InventoryProductCatalogTablePreset.operations:
        return const InventoryProductCatalogTableSortState();
      case InventoryProductCatalogTablePreset.stockControl:
        return const InventoryProductCatalogTableSortState(
          column: InventoryProductCatalogTableColumn.shortage,
          ascending: false,
        );
      case InventoryProductCatalogTablePreset.pricing:
        return const InventoryProductCatalogTableSortState(
          column: InventoryProductCatalogTableColumn.price,
          ascending: false,
        );
      case InventoryProductCatalogTablePreset.channelSignals:
        return const InventoryProductCatalogTableSortState(
          column: InventoryProductCatalogTableColumn.status,
        );
    }
  }

  InventoryProductCatalogTableViewState get viewState {
    return InventoryProductCatalogTableViewState(
      preferences: preferences,
      sortState: sortState,
    );
  }
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is! Map) return const {};

  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}
