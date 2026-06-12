import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('product custom attributes round trip through json and copy', () {
    final product = Product(
      id: 'p1',
      name: 'Spinach',
      customAttributes: {'expiry_date': '2026-07-01', 'batch_number': 'B-01'},
    );

    final fromJson = Product.fromJson(product.toJson());
    final copied = fromJson.copyWith(
      customAttributes: {'freshness_status': 'Monitor'},
    );

    expect(fromJson.customAttributes, {
      'expiry_date': '2026-07-01',
      'batch_number': 'B-01',
    });
    expect(copied.customAttributes, {'freshness_status': 'Monitor'});
  });
}
