import '../models/billing_product.dart';

abstract class BillingProductCatalogRepository {
  Future<List<Product>> fetchProducts(String tenantId);
}

class DemoBillingProductCatalogRepository
    implements BillingProductCatalogRepository {
  final Duration latency;

  const DemoBillingProductCatalogRepository({
    this.latency = const Duration(milliseconds: 800),
  });

  @override
  Future<List<Product>> fetchProducts(String tenantId) async {
    await _wait();
    return const [
      Product(
        id: 'p1',
        name: 'Business Plan',
        price: 79.99,
        category: 'Subscription',
        imageUrl: 'assets/business_plan.png',
      ),
      Product(
        id: 'p2',
        name: 'Premium Support',
        price: 29.99,
        category: 'Service',
        imageUrl: 'assets/support.png',
      ),
      Product(
        id: 'p3',
        name: 'Website Hosting',
        price: 15.99,
        category: 'Hosting',
        imageUrl: 'assets/hosting.png',
      ),
      Product(
        id: 'p4',
        name: 'Custom Domain',
        price: 12.99,
        category: 'Domain',
        imageUrl: 'assets/domain.png',
      ),
      Product(
        id: 'p5',
        name: 'Pro Analytics',
        price: 49.99,
        category: 'Add-on',
        imageUrl: 'assets/analytics.png',
      ),
    ];
  }

  Future<void> _wait() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}
