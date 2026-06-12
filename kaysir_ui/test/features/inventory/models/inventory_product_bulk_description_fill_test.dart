import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_description_fill.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('bulk description fill resolves product tokens', () {
    const draft = InventoryProductBulkDescriptionFillDraft(
      template: '{name} in {category} with SKU {sku} at {price}.',
    );
    final products = [
      Product(
        id: 'p1',
        name: 'Cable',
        sku: 'CB-001',
        category: 'Accessories',
        price: 25,
      ),
    ];

    final updatedProducts = draft.applyAll(products);

    expect(
      updatedProducts.single.description,
      r'Cable in Accessories with SKU CB-001 at $25.00.',
    );
  });

  test('bulk description fill detects missing descriptions and previews', () {
    final product = Product(id: 'p1', name: 'Cable');

    expect(inventoryProductNeedsDescription(product), isTrue);
    expect(
      inventoryProductNeedsDescription(
        product.copyWith(description: 'USB-C cable'),
      ),
      isFalse,
    );
    expect(
      inventoryProductBulkDescriptionPreviewLabel(
        product: product,
        description: 'Cable in Accessories.',
      ),
      'No description -> Cable in Accessories.',
    );
    expect(
      validateInventoryProductBulkDescriptionTemplate('   '),
      'Enter a description template',
    );
  });
}
