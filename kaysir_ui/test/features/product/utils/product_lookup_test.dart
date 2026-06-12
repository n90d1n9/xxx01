import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_lookup.dart';

void main() {
  test('finds products by id and ignores blank ids', () {
    final products = [
      Product(id: 'p1', name: 'Coffee'),
      Product(id: 'p2', name: 'Tea'),
    ];

    expect(findProductById(products, 'p2')?.name, 'Tea');
    expect(findProductById(products, ' p1 ')?.name, 'Coffee');
    expect(findProductById(products, 'missing'), isNull);
    expect(findProductById(products, ' '), isNull);
    expect(findProductById(null, 'p1'), isNull);
  });
}
