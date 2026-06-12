import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/cart/states/cart_providers.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('ecommerce cart uses POS product lines and totals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);
    final notifier = container.read(cartProvider.notifier);

    notifier.addProduct(product);
    notifier.addProduct(product);

    expect(container.read(cartProvider).single.product, product);
    expect(container.read(cartProvider).single.quantity, 2);
    expect(notifier.total, 100000);

    notifier.updateQuantity(product.id, 3);
    expect(container.read(cartProvider).single.quantity, 3);
    expect(notifier.total, 150000);

    notifier.updateQuantity(product.id, 0);
    expect(container.read(cartProvider), isEmpty);
  });
}
