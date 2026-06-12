import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product_catalog_view_preset.dart';

void main() {
  test('product catalog view presets expose reusable catalog queues', () {
    const summary = InventoryProductCatalogSummary(
      productCount: 12,
      trackedProductCount: 9,
      inStockProductCount: 7,
      untrackedProductCount: 3,
      attentionProductCount: 5,
      totalQuantity: 80,
      totalInventoryValue: 1200,
      categoryCount: 4,
    );

    final presets = buildProductCatalogViewPresets(summary);

    expect(
      presets.map((preset) => preset.id),
      ProductCatalogViewPresetId.values,
    );
    expect(presets[0].filter, InventoryProductCatalogFilter.all);
    expect(presets[1].filter, InventoryProductCatalogFilter.attention);
    expect(presets[2].countLabel, '7 ready');
    expect(presets[3].countLabel, '3 setup');
  });
}
