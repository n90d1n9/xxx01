import 'inventory_product_catalog.dart';

enum InventoryProductCatalogTableColumn {
  product,
  status,
  category,
  stock,
  shortage,
  value,
  price,
}

extension InventoryProductCatalogTableColumnDetails
    on InventoryProductCatalogTableColumn {
  String get key {
    switch (this) {
      case InventoryProductCatalogTableColumn.product:
        return 'product';
      case InventoryProductCatalogTableColumn.status:
        return 'status';
      case InventoryProductCatalogTableColumn.category:
        return 'category';
      case InventoryProductCatalogTableColumn.stock:
        return 'stock';
      case InventoryProductCatalogTableColumn.shortage:
        return 'shortage';
      case InventoryProductCatalogTableColumn.value:
        return 'value';
      case InventoryProductCatalogTableColumn.price:
        return 'price';
    }
  }

  String get label {
    switch (this) {
      case InventoryProductCatalogTableColumn.product:
        return 'Product';
      case InventoryProductCatalogTableColumn.status:
        return 'Status';
      case InventoryProductCatalogTableColumn.category:
        return 'Category';
      case InventoryProductCatalogTableColumn.stock:
        return 'Stock';
      case InventoryProductCatalogTableColumn.shortage:
        return 'Shortage';
      case InventoryProductCatalogTableColumn.value:
        return 'Value';
      case InventoryProductCatalogTableColumn.price:
        return 'Price';
    }
  }

  bool get numeric {
    switch (this) {
      case InventoryProductCatalogTableColumn.stock:
      case InventoryProductCatalogTableColumn.shortage:
      case InventoryProductCatalogTableColumn.value:
      case InventoryProductCatalogTableColumn.price:
        return true;
      case InventoryProductCatalogTableColumn.product:
      case InventoryProductCatalogTableColumn.status:
      case InventoryProductCatalogTableColumn.category:
        return false;
    }
  }
}

class InventoryProductCatalogTableSortState {
  const InventoryProductCatalogTableSortState({
    this.column = InventoryProductCatalogTableColumn.product,
    this.ascending = true,
  });

  factory InventoryProductCatalogTableSortState.fromJson(
    Map<String, Object?> json,
  ) {
    return InventoryProductCatalogTableSortState(
      column:
          _decodeColumn(json[_columnJsonKey]) ??
          InventoryProductCatalogTableColumn.product,
      ascending:
          json[_ascendingJsonKey] is bool
              ? json[_ascendingJsonKey] as bool
              : true,
    );
  }

  static const _columnJsonKey = 'column';
  static const _ascendingJsonKey = 'ascending';

  final InventoryProductCatalogTableColumn column;
  final bool ascending;

  Map<String, Object> toJson() {
    return {_columnJsonKey: column.key, _ascendingJsonKey: ascending};
  }

  InventoryProductCatalogTableSortState copyWith({
    InventoryProductCatalogTableColumn? column,
    bool? ascending,
  }) {
    return InventoryProductCatalogTableSortState(
      column: column ?? this.column,
      ascending: ascending ?? this.ascending,
    );
  }

  bool matches(InventoryProductCatalogTableSortState other) {
    return column == other.column && ascending == other.ascending;
  }
}

List<InventoryProductCatalogRecord> sortInventoryProductCatalogTableRecords({
  required List<InventoryProductCatalogRecord> records,
  required InventoryProductCatalogTableColumn column,
  required bool ascending,
}) {
  final sorted = records.toList(growable: false)..sort((left, right) {
    final result = _compareRecords(left, right, column);
    if (result != 0) return ascending ? result : -result;

    return left.productName.toLowerCase().compareTo(
      right.productName.toLowerCase(),
    );
  });

  return List.unmodifiable(sorted);
}

InventoryProductCatalogTableColumn? _decodeColumn(Object? value) {
  if (value is! String) return null;

  for (final column in InventoryProductCatalogTableColumn.values) {
    if (column.key == value) return column;
  }

  return null;
}

int _compareRecords(
  InventoryProductCatalogRecord left,
  InventoryProductCatalogRecord right,
  InventoryProductCatalogTableColumn column,
) {
  switch (column) {
    case InventoryProductCatalogTableColumn.product:
      return _compareText(left.productName, right.productName);
    case InventoryProductCatalogTableColumn.status:
      return _statusRank(left.status).compareTo(_statusRank(right.status));
    case InventoryProductCatalogTableColumn.category:
      return _compareText(left.categoryLabel, right.categoryLabel);
    case InventoryProductCatalogTableColumn.stock:
      return left.totalQuantity.compareTo(right.totalQuantity);
    case InventoryProductCatalogTableColumn.shortage:
      return left.totalShortage.compareTo(right.totalShortage);
    case InventoryProductCatalogTableColumn.value:
      return left.inventoryValue.compareTo(right.inventoryValue);
    case InventoryProductCatalogTableColumn.price:
      return left.unitPrice.compareTo(right.unitPrice);
  }
}

int _compareText(String left, String right) {
  return left.toLowerCase().compareTo(right.toLowerCase());
}

int _statusRank(InventoryProductCatalogStatus status) {
  switch (status) {
    case InventoryProductCatalogStatus.outOfStock:
      return 0;
    case InventoryProductCatalogStatus.lowStock:
      return 1;
    case InventoryProductCatalogStatus.untracked:
      return 2;
    case InventoryProductCatalogStatus.inStock:
      return 3;
  }
}
