import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_shortcut_generation.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('bulk shortcut generation creates normalized unique shortcut keys', () {
    const draft = InventoryProductBulkShortcutGenerationDraft(prefix: ' k ');
    final products = [
      Product(id: 'p1', name: 'Cable USB-C'),
      Product(id: 'p2', name: 'Adapter'),
    ];
    final existingProducts = [
      Product(id: 'p3', name: 'Old Cable', shortcutKey: 'K1'),
    ];

    final updatedProducts = draft.applyAll(
      products,
      existingProducts: existingProducts,
    );

    expect(updatedProducts.map((product) => product.shortcutKey), ['K2', 'K3']);
  });

  test('bulk shortcut generation detects missing scan codes and previews', () {
    final product = Product(id: 'p1', name: 'Cable');

    expect(inventoryProductNeedsScanCode(product), isTrue);
    expect(
      inventoryProductNeedsScanCode(product.copyWith(barcode: '8990001')),
      isFalse,
    );
    expect(
      inventoryProductNeedsScanCode(product.copyWith(shortcutKey: 'K1')),
      isFalse,
    );
    expect(
      inventoryProductBulkShortcutPreviewLabel(
        product: product,
        shortcutKey: 'K1',
      ),
      'No scan code -> K1',
    );
  });
}
