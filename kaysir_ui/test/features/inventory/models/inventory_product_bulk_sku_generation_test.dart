import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_sku_generation.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('bulk SKU generation creates normalized unique SKUs', () {
    const draft = InventoryProductBulkSkuGenerationDraft(prefix: ' retail ');
    final products = [
      Product(id: 'p1', name: 'Cable USB-C'),
      Product(id: 'p2', name: 'Cable USB-C'),
      Product(id: 'p3', name: '!!!'),
    ];
    final existingProducts = [
      Product(id: 'p4', name: 'Old Cable', sku: 'RETAIL-CABLE-USB-C'),
    ];

    final updatedProducts = draft.applyAll(
      products,
      existingProducts: existingProducts,
    );

    expect(updatedProducts.map((product) => product.sku), [
      'RETAIL-CABLE-USB-C-2',
      'RETAIL-CABLE-USB-C-3',
      'RETAIL',
    ]);
  });

  test('bulk SKU generation detects missing SKUs and previews changes', () {
    final product = Product(id: 'p1', name: 'Cable');

    expect(inventoryProductNeedsSku(product), isTrue);
    expect(
      inventoryProductBulkSkuPreviewLabel(product: product, sku: 'CAT-CABLE'),
      'No SKU -> CAT-CABLE',
    );
  });
}
