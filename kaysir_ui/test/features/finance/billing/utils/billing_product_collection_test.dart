import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_product_filter.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_collection.dart';

void main() {
  test('billingProductCategories returns stable sorted categories', () {
    final categories = billingProductCategories(_products());

    expect(categories, ['Add-on', 'Hosting']);
  });

  test('filterBillingProducts searches names categories and ids', () {
    final products = _products();

    final byName = filterBillingProducts(products, query: 'analytics');
    final byCategory = filterBillingProducts(products, query: 'hosting');
    final byId = filterBillingProducts(products, query: 'support');

    expect(byName.map((product) => product.id), ['analytics']);
    expect(byCategory.map((product) => product.id), ['hosting']);
    expect(byId.map((product) => product.id), ['support']);
  });

  test('filterBillingProducts filters category and sorts by price', () {
    final products = _products();

    final filtered = filterBillingProducts(
      products,
      category: 'Add-on',
      sort: BillingProductSortOption.priceHighToLow,
    );

    expect(filtered.map((product) => product.id), ['analytics', 'support']);
  });

  test('filterBillingProducts defaults to name ascending', () {
    final products = _products();

    final filtered = filterBillingProducts(products);

    expect(filtered.map((product) => product.name), [
      'Premium Support',
      'Pro Analytics',
      'Website Hosting',
    ]);
  });
}

List<Product> _products() {
  return const [
    Product(
      id: 'hosting',
      name: 'Website Hosting',
      price: 15.99,
      category: 'Hosting',
    ),
    Product(
      id: 'support',
      name: 'Premium Support',
      price: 29.99,
      category: 'Add-on',
    ),
    Product(
      id: 'analytics',
      name: 'Pro Analytics',
      price: 49.99,
      category: 'Add-on',
    ),
  ];
}
