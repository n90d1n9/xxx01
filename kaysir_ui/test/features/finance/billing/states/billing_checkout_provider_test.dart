import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_checkout.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_checkout_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_cart_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_checkout_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';

void main() {
  test('submitCurrentCart submits checkout and clears the cart', () async {
    final repository = _FakeBillingCheckoutRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    container.read(currentTenantProvider.notifier).state = const Tenant(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
    );
    container
        .read(cartProvider.notifier)
        .addToCart(
          const Product(
            id: 'support',
            name: 'Premium Support',
            price: 29.99,
            category: 'Service',
          ),
          'tenant-a',
        );
    container
        .read(cartProvider.notifier)
        .addToCart(
          const Product(
            id: 'hosting',
            name: 'Website Hosting',
            price: 15.99,
            category: 'Hosting',
          ),
          'tenant-b',
        );

    final receipt =
        await container
            .read(billingCheckoutControllerProvider.notifier)
            .submitCurrentCart();

    expect(repository.requests, hasLength(1));
    expect(repository.requests.single.tenantId, 'tenant-a');
    expect(repository.requests.single.itemCount, 1);
    expect(repository.requests.single.total, 29.99);
    expect(repository.requests.single.hasLineItems, isTrue);
    expect(
      repository.requests.single.lineItems.single.source?.domain,
      'commerce',
    );
    expect(repository.requests.single.lineItems.single.unitPrice, 29.99);
    expect(receipt.id, 'receipt-1');
    expect(receipt.tenantName, 'Acme Corp');
    expect(container.read(cartProvider), hasLength(1));
    expect(container.read(cartProvider).single.tenantId, 'tenant-b');
    expect(
      container.read(billingCheckoutControllerProvider).value?.id,
      'receipt-1',
    );
  });

  test(
    'submitCurrentCart respects overridable domain profile totals',
    () async {
      final repository = _FakeBillingCheckoutRepository();
      final container = _container(
        repository,
        profile: digitalSubscriptionBillingDomainProfile(taxRate: 0.1),
      );
      addTearDown(container.dispose);

      container.read(currentTenantProvider.notifier).state = const Tenant(
        id: 'tenant-a',
        name: 'Acme Corp',
        logoUrl: '',
      );
      container
          .read(cartProvider.notifier)
          .addToCart(
            const Product(
              id: 'plan-pro',
              name: 'Pro plan',
              price: 100,
              category: 'Subscription',
            ),
            'tenant-a',
          );

      final receipt =
          await container
              .read(billingCheckoutControllerProvider.notifier)
              .submitCurrentCart();

      expect(repository.requests.single.total, 110);
      expect(
        repository.requests.single.lineItems.single.source?.domain,
        'digital',
      );
      expect(
        repository.requests.single.lineItems.single.source?.type,
        'subscription',
      );
      expect(repository.requests.single.lineItems.single.taxRate, 0.1);
      expect(receipt.total, 110);
    },
  );

  test('submitCurrentCart uses active tenant domain profile', () async {
    final repository = _FakeBillingCheckoutRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    container.read(currentTenantProvider.notifier).state = const Tenant(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
      preferences: BillingTenantPreferences(businessDomain: 'digital'),
    );
    container
        .read(cartProvider.notifier)
        .addToCart(
          const Product(
            id: 'plan-pro',
            name: 'Pro plan',
            price: 100,
            category: 'Subscription',
          ),
          'tenant-a',
        );

    await container
        .read(billingCheckoutControllerProvider.notifier)
        .submitCurrentCart();

    expect(
      repository.requests.single.lineItems.single.source?.domain,
      'digital',
    );
    expect(
      repository.requests.single.lineItems.single.source?.type,
      'subscription',
    );
  });

  test('submitCurrentCart rejects an empty cart', () async {
    final repository = _FakeBillingCheckoutRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    container.read(currentTenantProvider.notifier).state = const Tenant(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
    );

    expect(
      container
          .read(billingCheckoutControllerProvider.notifier)
          .submitCurrentCart(),
      throwsStateError,
    );
    expect(repository.requests, isEmpty);
  });
}

ProviderContainer _container(
  BillingCheckoutRepository repository, {
  BillingBusinessDomainProfile? profile,
}) {
  return ProviderContainer(
    overrides: [
      billingCheckoutRepositoryProvider.overrideWithValue(repository),
      if (profile != null)
        billingCheckoutDomainProfileProvider.overrideWithValue(profile),
    ],
  );
}

class _FakeBillingCheckoutRepository implements BillingCheckoutRepository {
  final requests = <BillingCheckoutRequest>[];

  @override
  Future<BillingCheckoutReceipt> submitCheckout(
    BillingCheckoutRequest request,
  ) async {
    requests.add(request);
    return BillingCheckoutReceipt(
      id: 'receipt-${requests.length}',
      tenantId: request.tenantId,
      tenantName: request.tenantName,
      total: request.total,
      itemCount: request.itemCount,
      createdAt: DateTime(2026, 5, 31),
    );
  }
}
