import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_state_mutations.dart';

void main() {
  test('upsert replaces existing products without duplicating ids', () {
    final original = Product(id: 'p1', name: 'Coffee', price: 10000);
    final updated = original.copyWith(name: 'Iced Coffee', price: 12000);
    final products = [original, Product(id: 'p2', name: 'Tea', price: 8000)];

    final next = upsertProductInList(products, updated);

    expect(next, hasLength(2));
    expect(next.first.name, 'Iced Coffee');
    expect(next.first.price, 12000);
    expect(next.map((product) => product.id), ['p1', 'p2']);
  });

  test('upsert appends new products and remove deletes by id', () {
    final products = [Product(id: 'p1', name: 'Coffee', price: 10000)];
    final inserted = Product(id: 'p2', name: 'Tea', price: 8000);

    final next = upsertProductInList(products, inserted);
    final removed = removeProductFromList(next, 'p1');

    expect(next.map((product) => product.id), ['p1', 'p2']);
    expect(removed.map((product) => product.id), ['p2']);
  });
}
