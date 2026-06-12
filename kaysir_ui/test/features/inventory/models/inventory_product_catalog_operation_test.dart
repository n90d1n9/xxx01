import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_operation.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'product catalog operation messages describe single-product changes',
    () {
      final product = Product(id: 'p1', name: 'Scanner');

      expect(
        InventoryProductCatalogOperationResult.productAdded(product).message,
        'Scanner added to catalog',
      );
      expect(
        InventoryProductCatalogOperationResult.productDuplicated(
          source: product,
          duplicate: Product(id: 'p2', name: 'Copy of Scanner'),
        ).message,
        'Scanner duplicated as Copy of Scanner',
      );
      expect(
        InventoryProductCatalogOperationResult.productUpdated(product).message,
        'Scanner updated',
      );
      expect(
        InventoryProductCatalogOperationResult.productDeleted(product).message,
        'Scanner deleted',
      );
    },
  );

  test('product catalog operation messages describe bulk changes', () {
    var undone = false;

    expect(
      InventoryProductCatalogOperationResult.bulkCategoryUpdated(
        count: 2,
        category: 'Hardware',
      ).message,
      '2 products moved to Hardware',
    );
    expect(
      InventoryProductCatalogOperationResult.bulkPriceUpdated(
        1,
        undo: () => undone = true,
      ).message,
      '1 product price updated',
    );
    expect(
      InventoryProductCatalogOperationResult.bulkDescriptionsFilled(2).message,
      '2 product descriptions filled',
    );
    expect(
      InventoryProductCatalogOperationResult.bulkSkusGenerated(2).message,
      '2 products assigned SKUs',
    );
    expect(
      InventoryProductCatalogOperationResult.bulkShortcutsGenerated(2).message,
      '2 products assigned shortcuts',
    );
    final result = InventoryProductCatalogOperationResult.bulkPriceUpdated(
      1,
      undo: () => undone = true,
    );
    expect(result.canUndo, isTrue);
    result.undo?.call();
    expect(undone, isTrue);
    expect(
      InventoryProductCatalogOperationResult.bulkDeleted(3).message,
      '3 products deleted',
    );
  });
}
