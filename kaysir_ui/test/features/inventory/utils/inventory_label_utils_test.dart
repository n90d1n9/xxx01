import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/utils/inventory_label_utils.dart';

void main() {
  test('inventoryLabel trims values and falls back for blank text', () {
    expect(
      inventoryLabel('  Main Warehouse  ', fallback: 'Unknown'),
      'Main Warehouse',
    );
    expect(inventoryLabel('', fallback: 'Unknown'), 'Unknown');
    expect(inventoryLabel('   ', fallback: 'Unknown'), 'Unknown');
    expect(inventoryLabel(null, fallback: 'Unknown'), 'Unknown');
  });

  test('firstInventoryLabel returns the first non-blank candidate', () {
    expect(
      firstInventoryLabel([null, ' ', ' Supplier A '], fallback: 'Unknown'),
      'Supplier A',
    );
    expect(
      firstInventoryLabel([null, '', '  '], fallback: 'Unknown'),
      'Unknown',
    );
  });

  test('domain label helpers keep inventory fallback copy consistent', () {
    expect(inventoryProductNameLabel('  Adapter  '), 'Adapter');
    expect(inventoryProductNameLabel(''), inventoryUnknownProductLabel);
    expect(inventorySkuLabel(null), inventoryNoSkuLabel);
    expect(inventoryCategoryLabel('  '), inventoryUncategorizedLabel);
    expect(inventoryDescriptionLabel(null), inventoryNoDescriptionLabel);
    expect(inventoryWarehouseNameLabel(''), inventoryUnknownWarehouseLabel);
    expect(
      inventoryFirstWarehouseNameLabel([null, '  Warehouse A  ']),
      'Warehouse A',
    );
    expect(inventoryLocationLabel('  '), inventoryNoLocationLabel);
    expect(inventoryReferenceLabel(null), inventoryNoReferenceLabel);
    expect(inventoryNotesLabel(''), inventoryNoNotesLabel);
    expect(
      inventoryWarehouseNameLabel(null, fallback: inventoryNoDestinationLabel),
      inventoryNoDestinationLabel,
    );
    expect(
      inventorySupplierLabel([null, '  Jakarta Supply  ']),
      'Jakarta Supply',
    );
    expect(inventoryItemNameLabel('  '), inventoryUnnamedItemLabel);
  });
}
