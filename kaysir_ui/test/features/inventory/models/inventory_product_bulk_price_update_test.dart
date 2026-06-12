import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_price_update.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('bulk price update draft applies fixed prices', () {
    final product = Product(id: 'p1', name: 'Coffee', price: 12500);
    const draft = InventoryProductBulkPriceUpdateDraft(
      mode: InventoryProductBulkPriceUpdateMode.setFixed,
      value: 15000,
    );

    expect(draft.priceFor(product), 15000);
    expect(draft.apply(product).price, 15000);
  });

  test(
    'bulk price update draft adjusts percentages with currency rounding',
    () {
      final product = Product(id: 'p1', name: 'Coffee', price: 19900);

      const increase = InventoryProductBulkPriceUpdateDraft(
        mode: InventoryProductBulkPriceUpdateMode.increaseByPercent,
        value: 12.5,
      );
      const decrease = InventoryProductBulkPriceUpdateDraft(
        mode: InventoryProductBulkPriceUpdateMode.decreaseByPercent,
        value: 10,
      );

      expect(increase.priceFor(product), 22387.5);
      expect(decrease.priceFor(product), 17910);
    },
  );

  test('bulk price update value validation covers each mode', () {
    expect(
      validateInventoryProductBulkPriceValue(
        '0',
        InventoryProductBulkPriceUpdateMode.setFixed,
      ),
      'Enter a price greater than zero',
    );
    expect(
      validateInventoryProductBulkPriceValue(
        '-1',
        InventoryProductBulkPriceUpdateMode.increaseByPercent,
      ),
      'Enter a percentage greater than zero',
    );
    expect(
      validateInventoryProductBulkPriceValue(
        '150',
        InventoryProductBulkPriceUpdateMode.decreaseByPercent,
      ),
      'Enter a percentage from 1 to 100',
    );
    expect(
      validateInventoryProductBulkPriceValue(
        '10',
        InventoryProductBulkPriceUpdateMode.decreaseByPercent,
      ),
      isNull,
    );
  });
}
