import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_duplicate.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('duplicateInventoryProduct copies merchandising fields safely', () {
    final source = Product(
      id: 'p1',
      name: 'Latte',
      sku: 'LATTE',
      category: 'Coffee',
      description: 'Hot drink',
      barcode: '8990001',
      shortcutKey: 'L',
      price: 25000,
      currentStock: 12,
      systemStock: 12,
    );

    final duplicate = duplicateInventoryProduct(
      source: source,
      existingProducts: [source],
      id: 'p2',
    );

    expect(duplicate.id, 'p2');
    expect(duplicate.name, 'Copy of Latte');
    expect(duplicate.sku, 'LATTE-COPY');
    expect(duplicate.category, 'Coffee');
    expect(duplicate.description, 'Hot drink');
    expect(duplicate.price, 25000);
    expect(duplicate.barcode, isNull);
    expect(duplicate.shortcutKey, isEmpty);
    expect(duplicate.currentStock, 0);
    expect(duplicate.systemStock, 0);
  });

  test('duplicateInventoryProduct increments existing copy names and skus', () {
    final source = Product(id: 'p1', name: 'Latte', sku: 'LATTE');
    final firstCopy = Product(
      id: 'p2',
      name: 'Copy of Latte',
      sku: 'LATTE-COPY',
    );

    final duplicate = duplicateInventoryProduct(
      source: source,
      existingProducts: [source, firstCopy],
      id: 'p3',
    );

    expect(duplicate.name, 'Copy of Latte (2)');
    expect(duplicate.sku, 'LATTE-COPY-2');
  });
}
