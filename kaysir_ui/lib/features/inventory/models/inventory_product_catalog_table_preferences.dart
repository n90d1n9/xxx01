import 'inventory_product_catalog_table_sort.dart';

enum InventoryProductCatalogTableDensity { comfortable, compact }

extension InventoryProductCatalogTableDensityDetails
    on InventoryProductCatalogTableDensity {
  String get key {
    switch (this) {
      case InventoryProductCatalogTableDensity.comfortable:
        return 'comfortable';
      case InventoryProductCatalogTableDensity.compact:
        return 'compact';
    }
  }

  String get label {
    switch (this) {
      case InventoryProductCatalogTableDensity.comfortable:
        return 'Comfort';
      case InventoryProductCatalogTableDensity.compact:
        return 'Compact';
    }
  }

  double get dataRowMinHeight {
    switch (this) {
      case InventoryProductCatalogTableDensity.comfortable:
        return 72;
      case InventoryProductCatalogTableDensity.compact:
        return 56;
    }
  }

  double get dataRowMaxHeight {
    switch (this) {
      case InventoryProductCatalogTableDensity.comfortable:
        return 120;
      case InventoryProductCatalogTableDensity.compact:
        return 88;
    }
  }

  double get rowExtent {
    switch (this) {
      case InventoryProductCatalogTableDensity.comfortable:
        return 116;
      case InventoryProductCatalogTableDensity.compact:
        return 86;
    }
  }
}

enum InventoryProductCatalogTableOptionalColumn {
  status,
  category,
  stock,
  shortage,
  value,
  price,
  signals,
}

extension InventoryProductCatalogTableOptionalColumnDetails
    on InventoryProductCatalogTableOptionalColumn {
  String get key {
    switch (this) {
      case InventoryProductCatalogTableOptionalColumn.status:
        return 'status';
      case InventoryProductCatalogTableOptionalColumn.category:
        return 'category';
      case InventoryProductCatalogTableOptionalColumn.stock:
        return 'stock';
      case InventoryProductCatalogTableOptionalColumn.shortage:
        return 'shortage';
      case InventoryProductCatalogTableOptionalColumn.value:
        return 'value';
      case InventoryProductCatalogTableOptionalColumn.price:
        return 'price';
      case InventoryProductCatalogTableOptionalColumn.signals:
        return 'signals';
    }
  }

  String get label {
    switch (this) {
      case InventoryProductCatalogTableOptionalColumn.status:
        return 'Status';
      case InventoryProductCatalogTableOptionalColumn.category:
        return 'Category';
      case InventoryProductCatalogTableOptionalColumn.stock:
        return 'Stock';
      case InventoryProductCatalogTableOptionalColumn.shortage:
        return 'Shortage';
      case InventoryProductCatalogTableOptionalColumn.value:
        return 'Value';
      case InventoryProductCatalogTableOptionalColumn.price:
        return 'Price';
      case InventoryProductCatalogTableOptionalColumn.signals:
        return 'Signals';
    }
  }

  InventoryProductCatalogTableColumn? get sortableColumn {
    switch (this) {
      case InventoryProductCatalogTableOptionalColumn.status:
        return InventoryProductCatalogTableColumn.status;
      case InventoryProductCatalogTableOptionalColumn.category:
        return InventoryProductCatalogTableColumn.category;
      case InventoryProductCatalogTableOptionalColumn.stock:
        return InventoryProductCatalogTableColumn.stock;
      case InventoryProductCatalogTableOptionalColumn.shortage:
        return InventoryProductCatalogTableColumn.shortage;
      case InventoryProductCatalogTableOptionalColumn.value:
        return InventoryProductCatalogTableColumn.value;
      case InventoryProductCatalogTableOptionalColumn.price:
        return InventoryProductCatalogTableColumn.price;
      case InventoryProductCatalogTableOptionalColumn.signals:
        return null;
    }
  }
}

enum InventoryProductCatalogTablePreset {
  operations,
  stockControl,
  pricing,
  channelSignals,
}

extension InventoryProductCatalogTablePresetDetails
    on InventoryProductCatalogTablePreset {
  String get key {
    switch (this) {
      case InventoryProductCatalogTablePreset.operations:
        return 'operations';
      case InventoryProductCatalogTablePreset.stockControl:
        return 'stock-control';
      case InventoryProductCatalogTablePreset.pricing:
        return 'pricing';
      case InventoryProductCatalogTablePreset.channelSignals:
        return 'channel-signals';
    }
  }

  String get label {
    switch (this) {
      case InventoryProductCatalogTablePreset.operations:
        return 'Operations';
      case InventoryProductCatalogTablePreset.stockControl:
        return 'Stock control';
      case InventoryProductCatalogTablePreset.pricing:
        return 'Pricing';
      case InventoryProductCatalogTablePreset.channelSignals:
        return 'Channel signals';
    }
  }

  String get description {
    switch (this) {
      case InventoryProductCatalogTablePreset.operations:
        return 'Full catalog health and action view';
      case InventoryProductCatalogTablePreset.stockControl:
        return 'Inventory levels and replenishment risk';
      case InventoryProductCatalogTablePreset.pricing:
        return 'Price, value, and category review';
      case InventoryProductCatalogTablePreset.channelSignals:
        return 'Omnichannel readiness and sales signals';
    }
  }

  InventoryProductCatalogTablePreferences get preferences {
    switch (this) {
      case InventoryProductCatalogTablePreset.operations:
        return const InventoryProductCatalogTablePreferences();
      case InventoryProductCatalogTablePreset.stockControl:
        return const InventoryProductCatalogTablePreferences(
          density: InventoryProductCatalogTableDensity.compact,
          visibleColumns: {
            InventoryProductCatalogTableOptionalColumn.status,
            InventoryProductCatalogTableOptionalColumn.category,
            InventoryProductCatalogTableOptionalColumn.stock,
            InventoryProductCatalogTableOptionalColumn.shortage,
            InventoryProductCatalogTableOptionalColumn.signals,
          },
        );
      case InventoryProductCatalogTablePreset.pricing:
        return const InventoryProductCatalogTablePreferences(
          density: InventoryProductCatalogTableDensity.compact,
          visibleColumns: {
            InventoryProductCatalogTableOptionalColumn.status,
            InventoryProductCatalogTableOptionalColumn.category,
            InventoryProductCatalogTableOptionalColumn.value,
            InventoryProductCatalogTableOptionalColumn.price,
          },
        );
      case InventoryProductCatalogTablePreset.channelSignals:
        return const InventoryProductCatalogTablePreferences(
          visibleColumns: {
            InventoryProductCatalogTableOptionalColumn.status,
            InventoryProductCatalogTableOptionalColumn.stock,
            InventoryProductCatalogTableOptionalColumn.shortage,
            InventoryProductCatalogTableOptionalColumn.signals,
          },
        );
    }
  }
}

class InventoryProductCatalogTablePreferences {
  const InventoryProductCatalogTablePreferences({
    this.density = InventoryProductCatalogTableDensity.comfortable,
    this.visibleColumns = defaultVisibleColumns,
    this.hiddenContributionIds = const <String>{},
    this.visibleContributionIds = const <String>{},
  });

  factory InventoryProductCatalogTablePreferences.fromJson(
    Map<String, Object?> json,
  ) {
    final density =
        _decodeDensity(json[_densityJsonKey]) ??
        InventoryProductCatalogTableDensity.comfortable;
    final visibleColumns =
        _decodeColumns(json[_visibleColumnsJsonKey]) ?? defaultVisibleColumns;
    final hiddenContributionIds =
        _decodeStringSet(json[_hiddenContributionIdsJsonKey]) ??
        const <String>{};
    final visibleContributionIds =
        _decodeStringSet(json[_visibleContributionIdsJsonKey]) ??
        const <String>{};

    return InventoryProductCatalogTablePreferences(
      density: density,
      visibleColumns: Set.unmodifiable(visibleColumns),
      hiddenContributionIds: Set.unmodifiable(hiddenContributionIds),
      visibleContributionIds: Set.unmodifiable(visibleContributionIds),
    );
  }

  static const defaultVisibleColumns = {
    InventoryProductCatalogTableOptionalColumn.status,
    InventoryProductCatalogTableOptionalColumn.category,
    InventoryProductCatalogTableOptionalColumn.stock,
    InventoryProductCatalogTableOptionalColumn.shortage,
    InventoryProductCatalogTableOptionalColumn.value,
    InventoryProductCatalogTableOptionalColumn.price,
    InventoryProductCatalogTableOptionalColumn.signals,
  };
  static const _densityJsonKey = 'density';
  static const _visibleColumnsJsonKey = 'visibleColumns';
  static const _hiddenContributionIdsJsonKey = 'hiddenContributionIds';
  static const _visibleContributionIdsJsonKey = 'visibleContributionIds';

  final InventoryProductCatalogTableDensity density;
  final Set<InventoryProductCatalogTableOptionalColumn> visibleColumns;
  final Set<String> hiddenContributionIds;
  final Set<String> visibleContributionIds;

  Map<String, Object> toJson() {
    return {
      _densityJsonKey: density.key,
      _visibleColumnsJsonKey: visibleColumns
          .map((column) => column.key)
          .toList(growable: false),
      _hiddenContributionIdsJsonKey: hiddenContributionIds.toList(
        growable: false,
      ),
      _visibleContributionIdsJsonKey: visibleContributionIds.toList(
        growable: false,
      ),
    };
  }

  InventoryProductCatalogTablePreset? get matchingPreset {
    for (final preset in InventoryProductCatalogTablePreset.values) {
      if (matches(preset.preferences)) return preset;
    }

    return null;
  }

  String get activePresetLabel {
    return matchingPreset?.label ?? 'Custom';
  }

  bool get isCustom {
    return matchingPreset == null;
  }

  bool isVisible(InventoryProductCatalogTableOptionalColumn column) {
    return visibleColumns.contains(column);
  }

  bool isContributionVisible(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    final id = contributionId.trim();
    if (id.isEmpty) return false;

    return defaultVisible
        ? !hiddenContributionIds.contains(id)
        : visibleContributionIds.contains(id);
  }

  bool supportsSortColumn(InventoryProductCatalogTableColumn column) {
    return column == InventoryProductCatalogTableColumn.product ||
        InventoryProductCatalogTableOptionalColumn.values.any(
          (optionalColumn) =>
              isVisible(optionalColumn) &&
              optionalColumn.sortableColumn == column,
        );
  }

  bool matches(InventoryProductCatalogTablePreferences other) {
    return density == other.density &&
        visibleColumns.length == other.visibleColumns.length &&
        visibleColumns.containsAll(other.visibleColumns) &&
        hiddenContributionIds.length == other.hiddenContributionIds.length &&
        hiddenContributionIds.containsAll(other.hiddenContributionIds) &&
        visibleContributionIds.length == other.visibleContributionIds.length &&
        visibleContributionIds.containsAll(other.visibleContributionIds);
  }

  InventoryProductCatalogTablePreferences copyWith({
    InventoryProductCatalogTableDensity? density,
    Set<InventoryProductCatalogTableOptionalColumn>? visibleColumns,
    Set<String>? hiddenContributionIds,
    Set<String>? visibleContributionIds,
  }) {
    return InventoryProductCatalogTablePreferences(
      density: density ?? this.density,
      visibleColumns: Set.unmodifiable(visibleColumns ?? this.visibleColumns),
      hiddenContributionIds: Set.unmodifiable(
        hiddenContributionIds ?? this.hiddenContributionIds,
      ),
      visibleContributionIds: Set.unmodifiable(
        visibleContributionIds ?? this.visibleContributionIds,
      ),
    );
  }

  InventoryProductCatalogTablePreferences toggleColumn(
    InventoryProductCatalogTableOptionalColumn column,
  ) {
    final nextColumns = {...visibleColumns};
    if (!nextColumns.remove(column)) {
      nextColumns.add(column);
    }

    return copyWith(visibleColumns: Set.unmodifiable(nextColumns));
  }

  InventoryProductCatalogTablePreferences toggleContributionColumn(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    return setContributionColumnVisibility(
      contributionId,
      visible:
          !isContributionVisible(
            contributionId,
            defaultVisible: defaultVisible,
          ),
      defaultVisible: defaultVisible,
    );
  }

  InventoryProductCatalogTablePreferences showContributionColumn(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    return setContributionColumnVisibility(
      contributionId,
      visible: true,
      defaultVisible: defaultVisible,
    );
  }

  InventoryProductCatalogTablePreferences hideContributionColumn(
    String contributionId, {
    bool defaultVisible = true,
  }) {
    return setContributionColumnVisibility(
      contributionId,
      visible: false,
      defaultVisible: defaultVisible,
    );
  }

  InventoryProductCatalogTablePreferences setContributionColumnVisibility(
    String contributionId, {
    required bool visible,
    bool defaultVisible = true,
  }) {
    final id = contributionId.trim();
    if (id.isEmpty) return this;
    final nextHiddenContributionIds = {...hiddenContributionIds};
    final nextVisibleContributionIds = {...visibleContributionIds};

    if (defaultVisible) {
      if (visible) {
        nextHiddenContributionIds.remove(id);
      } else {
        nextHiddenContributionIds.add(id);
      }
      nextVisibleContributionIds.remove(id);
    } else {
      if (visible) {
        nextVisibleContributionIds.add(id);
      } else {
        nextVisibleContributionIds.remove(id);
      }
      nextHiddenContributionIds.remove(id);
    }

    return copyWith(
      hiddenContributionIds: Set.unmodifiable(nextHiddenContributionIds),
      visibleContributionIds: Set.unmodifiable(nextVisibleContributionIds),
    );
  }
}

InventoryProductCatalogTableDensity? _decodeDensity(Object? value) {
  if (value is! String) return null;

  for (final density in InventoryProductCatalogTableDensity.values) {
    if (density.key == value) return density;
  }

  return null;
}

Set<InventoryProductCatalogTableOptionalColumn>? _decodeColumns(Object? value) {
  if (value is! Iterable) return null;

  final columns = <InventoryProductCatalogTableOptionalColumn>{};
  for (final rawColumn in value) {
    if (rawColumn is! String) continue;

    final column = _decodeColumn(rawColumn);
    if (column != null) columns.add(column);
  }

  return columns;
}

InventoryProductCatalogTableOptionalColumn? _decodeColumn(String value) {
  for (final column in InventoryProductCatalogTableOptionalColumn.values) {
    if (column.key == value) return column;
  }

  return null;
}

Set<String>? _decodeStringSet(Object? value) {
  if (value is! Iterable) return null;

  return {
    for (final rawValue in value)
      if (rawValue is String && rawValue.trim().isNotEmpty) rawValue.trim(),
  };
}
