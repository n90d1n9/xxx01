import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_catalog_quality_panel_layout.dart';

void main() {
  test('catalog quality panel layout uses compact single column', () {
    final layout = ProductCatalogQualityPanelLayout.forWidth(360);

    expect(layout.maxWidth, 360);
    expect(layout.columnCount, 1);
    expect(layout.gap, 10);
    expect(layout.tileWidth, 360);
  });

  test('catalog quality panel layout uses medium columns', () {
    final twoColumn = ProductCatalogQualityPanelLayout.forWidth(480);
    final threeColumn = ProductCatalogQualityPanelLayout.forWidth(720);

    expect(twoColumn.columnCount, 2);
    expect(twoColumn.tileWidth, 235);
    expect(threeColumn.columnCount, 3);
    expect(threeColumn.tileWidth, closeTo(233.33, 0.01));
  });

  test('catalog quality panel layout uses dense desktop columns', () {
    final layout = ProductCatalogQualityPanelLayout.forWidth(1000);

    expect(layout.columnCount, 5);
    expect(layout.tileWidth, 192);
  });

  test('catalog quality panel layout sanitizes invalid metrics', () {
    final layout = ProductCatalogQualityPanelLayout.forWidth(-10, gap: -4);

    expect(layout.maxWidth, 0);
    expect(layout.columnCount, 1);
    expect(layout.gap, 0);
    expect(layout.tileWidth, 0);
  });
}
