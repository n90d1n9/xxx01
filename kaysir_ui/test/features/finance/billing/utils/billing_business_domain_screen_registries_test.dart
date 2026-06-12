import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_screen_registries.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('standardBillingDomainScreenRegistry composes core screen packs', () {
    final registry = standardBillingDomainScreenRegistry(
      hiddenDestinationIds: const [BillingNavigationDestinationId.reports],
      extensions: const [
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.productWorkspace,
          surface: BillingNavigationSurface.productWorkspace,
          key: 'service.workspace',
          presentation: BillingBusinessDomainScreenPresentation.route,
        ),
      ],
    );

    expect(registry.contains(BillingNavigationDestinationId.dashboard), isTrue);
    expect(
      registry.contains(BillingNavigationDestinationId.policyCenter),
      isTrue,
    );
    expect(registry.contains(BillingNavigationDestinationId.reports), isFalse);
    expect(
      registry
          .requireScreen(BillingNavigationDestinationId.productWorkspace)
          .key,
      'service.workspace',
    );
  });

  test('commerceBillingDomainScreenRegistry supports product overrides', () {
    final registry = commerceBillingDomainScreenRegistry(
      hiddenDestinationIds: const [BillingNavigationDestinationId.cartCheckout],
      extensions: const [
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.productWorkspace,
          surface: BillingNavigationSurface.productWorkspace,
          key: 'commerce.catalog_workspace',
          presentation: BillingBusinessDomainScreenPresentation.route,
        ),
      ],
    );

    expect(registry.contains(BillingNavigationDestinationId.dashboard), isTrue);
    expect(
      registry.contains(BillingNavigationDestinationId.cartCheckout),
      isFalse,
    );
    expect(
      registry
          .requireScreen(BillingNavigationDestinationId.productWorkspace)
          .key,
      'commerce.catalog_workspace',
    );
  });
}
