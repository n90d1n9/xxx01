enum InventoryProductCatalogViewMode { cards, table }

extension InventoryProductCatalogViewModeDetails
    on InventoryProductCatalogViewMode {
  String get key {
    switch (this) {
      case InventoryProductCatalogViewMode.cards:
        return 'cards';
      case InventoryProductCatalogViewMode.table:
        return 'table';
    }
  }

  String get label {
    switch (this) {
      case InventoryProductCatalogViewMode.cards:
        return 'Cards';
      case InventoryProductCatalogViewMode.table:
        return 'Table';
    }
  }
}

InventoryProductCatalogViewMode decodeInventoryProductCatalogViewMode(
  Object? value,
) {
  if (value is! String) return InventoryProductCatalogViewMode.cards;

  final key = value.trim();
  for (final mode in InventoryProductCatalogViewMode.values) {
    if (mode.key == key) return mode;
  }

  return InventoryProductCatalogViewMode.cards;
}
