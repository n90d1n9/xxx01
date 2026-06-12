import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_count_capture_view.dart';

void main() {
  test('resolves count capture targets by id barcode sku or name', () {
    expect(
      resolveProductCountCaptureTarget(_products, 'p1')?.nameLabel,
      'Coffee',
    );
    expect(
      resolveProductCountCaptureTarget(_products, ' 123456 ')?.nameLabel,
      'Tea',
    );
    expect(
      resolveProductCountCaptureTarget(_products, 'DT-1')?.nameLabel,
      'Dates',
    );
    expect(
      resolveProductCountCaptureTarget(_products, 'milk')?.nameLabel,
      'Milk',
    );
    expect(resolveProductCountCaptureTarget(_products, 'missing'), isNull);
    expect(resolveProductCountCaptureTarget(_products, ' '), isNull);
    expect(resolveProductCountCaptureTarget(null, 'p1'), isNull);
  });

  test('builds searchable count capture suggestions with pending first', () {
    final allTargets = buildProductCountCaptureTargets(products: _products);
    final beverageTargets = buildProductCountCaptureTargets(
      products: _products,
      query: 'beverage',
    );
    final idTargets = buildProductCountCaptureTargets(
      products: _products,
      query: 'p3',
    );

    expect(allTargets.map((target) => target.nameLabel), [
      'Coffee',
      'Dates',
      'Milk',
      'Tea',
    ]);
    expect(beverageTargets.map((target) => target.nameLabel), [
      'Coffee',
      'Tea',
    ]);
    expect(idTargets.single.nameLabel, 'Dates');
  });

  test('count capture target exposes safe labels and count status', () {
    final pending = ProductCountCaptureTarget(product: Product(name: ' '));
    final variance = ProductCountCaptureTarget(
      product: Product(name: 'Tea', actualStock: 7, systemStock: 4),
    );
    final matched = ProductCountCaptureTarget(
      product: Product(name: 'Milk', actualStock: 3, systemStock: 3),
    );

    expect(pending.nameLabel, 'Unnamed product');
    expect(pending.skuLabel, 'No SKU');
    expect(pending.barcodeLabel, 'No barcode');
    expect(pending.categoryLabel, 'Uncategorized');
    expect(pending.actualStockLabel, 'Not counted');
    expect(pending.varianceLabel, 'Pending');
    expect(pending.countStatusLabel, 'Pending');
    expect(variance.varianceLabel, '+3');
    expect(variance.countStatusLabel, 'Variance');
    expect(matched.varianceLabel, '0');
    expect(matched.countStatusLabel, 'Matched');
  });

  test(
    'count capture draft preview handles pending matched and variance input',
    () {
      final target = ProductCountCaptureTarget(
        product: Product(name: 'Coffee', systemStock: 4),
      );
      final missingTarget = buildProductCountCaptureDraftPreview(
        target: null,
        actualStockInput: '6',
      );
      final missingQuantity = buildProductCountCaptureDraftPreview(
        target: target,
        actualStockInput: ' ',
      );
      final matched = buildProductCountCaptureDraftPreview(
        target: target,
        actualStockInput: '4',
      );
      final variance = buildProductCountCaptureDraftPreview(
        target: target,
        actualStockInput: '6',
      );
      final invalid = buildProductCountCaptureDraftPreview(
        target: target,
        actualStockInput: '-1',
      );

      expect(
        missingTarget.status,
        ProductCountCapturePreviewStatus.missingTarget,
      );
      expect(
        missingQuantity.status,
        ProductCountCapturePreviewStatus.missingQuantity,
      );
      expect(matched.status, ProductCountCapturePreviewStatus.matched);
      expect(matched.varianceLabel, '0');
      expect(variance.status, ProductCountCapturePreviewStatus.variance);
      expect(variance.actualStockLabel, '6');
      expect(variance.varianceLabel, '+2');
      expect(invalid.status, ProductCountCapturePreviewStatus.missingQuantity);
      expect(invalid.actualStockLabel, 'Not entered');
    },
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Coffee',
    sku: 'CF-1',
    category: 'Beverage',
    systemStock: 4,
  ),
  Product(
    id: 'p2',
    name: 'Tea',
    sku: 'TE-1',
    barcode: '123456',
    category: 'Beverage',
    actualStock: 7,
    systemStock: 4,
  ),
  Product(
    id: 'p3',
    name: 'Dates',
    sku: 'DT-1',
    category: 'Snack',
    systemStock: 2,
  ),
  Product(
    id: 'p4',
    name: 'Milk',
    sku: 'ML-1',
    category: 'Dairy',
    actualStock: 3,
    systemStock: 3,
  ),
];
