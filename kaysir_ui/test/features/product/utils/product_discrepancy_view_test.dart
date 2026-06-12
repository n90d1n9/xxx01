import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_discrepancy_view.dart';

void main() {
  test('discrepancy view handles pending and counted differences safely', () {
    final entries = buildProductDiscrepancyEntries([
      Product(id: 'ok', name: 'A OK', actualStock: 5, systemStock: 5),
      Product(id: 'pending', name: 'B Pending', systemStock: 2),
      Product(id: 'over', name: 'C Over', actualStock: 7, systemStock: 4),
      Product(id: 'under', name: 'D Under', actualStock: 1, systemStock: 3),
    ]);

    expect(entries.map((entry) => entry.productName), [
      'B Pending',
      'C Over',
      'D Under',
    ]);
    expect(entries[0].actualStockLabel, 'Not counted');
    expect(entries[0].differenceLabel, 'Pending');
    expect(entries[1].differenceLabel, '+3');
    expect(entries[2].differenceLabel, '-2');
  });
}
