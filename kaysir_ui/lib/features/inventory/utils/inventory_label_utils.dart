const inventoryUnknownProductLabel = 'Unknown product';
const inventoryNoSkuLabel = 'No SKU';
const inventoryUncategorizedLabel = 'Uncategorized';
const inventoryNoDescriptionLabel = 'No description';
const inventoryMissingPriceLabel = 'Missing price';
const inventoryMissingScanCodeLabel = 'Missing scan code';
const inventoryUnknownWarehouseLabel = 'Unknown warehouse';
const inventoryNoLocationLabel = 'No location';
const inventoryNoDestinationLabel = 'No destination';
const inventoryNoReferenceLabel = 'No reference';
const inventoryNoNotesLabel = 'No notes';
const inventoryUnknownSupplierLabel = 'Unknown supplier';
const inventoryUnnamedItemLabel = 'Unnamed item';

String inventoryLabel(String? value, {required String fallback}) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? fallback : normalized;
}

String firstInventoryLabel(
  Iterable<String?> values, {
  required String fallback,
}) {
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
  }

  return fallback;
}

String inventoryProductNameLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryUnknownProductLabel);
}

String inventorySkuLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryNoSkuLabel);
}

String inventoryCategoryLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryUncategorizedLabel);
}

String inventoryDescriptionLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryNoDescriptionLabel);
}

String inventoryScanCodeLabel({String? barcode, String? shortcutKey}) {
  return firstInventoryLabel([
    barcode,
    shortcutKey,
  ], fallback: inventoryMissingScanCodeLabel);
}

String inventoryPriceReadinessLabel(double price) {
  return price <= 0 ? inventoryMissingPriceLabel : price.toString();
}

String inventoryWarehouseNameLabel(
  String? value, {
  String fallback = inventoryUnknownWarehouseLabel,
}) {
  return inventoryLabel(value, fallback: fallback);
}

String inventoryFirstWarehouseNameLabel(Iterable<String?> values) {
  return firstInventoryLabel(values, fallback: inventoryUnknownWarehouseLabel);
}

String inventoryLocationLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryNoLocationLabel);
}

String inventoryReferenceLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryNoReferenceLabel);
}

String inventoryNotesLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryNoNotesLabel);
}

String inventorySupplierLabel(Iterable<String?> values) {
  return firstInventoryLabel(values, fallback: inventoryUnknownSupplierLabel);
}

String inventoryItemNameLabel(String? value) {
  return inventoryLabel(value, fallback: inventoryUnnamedItemLabel);
}
