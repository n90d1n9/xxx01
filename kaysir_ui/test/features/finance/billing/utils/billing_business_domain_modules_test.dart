import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/models/billing_cart_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_screen_registries.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('standardBillingDomainModuleRegistry exposes standard modules', () {
    final registry = standardBillingDomainModuleRegistry();

    expect(registry.domainKeys, ['commerce', 'construction', 'digital']);
    expect(registry.requireModule('commerce').hasLineItemAdapters, isTrue);
    expect(registry.requireModule('commerce').hasNavigationPolicy, isTrue);
    expect(registry.requireModule('commerce').hasScreenRegistry, isTrue);
    expect(registry.requireModule('construction').hasLineItemAdapters, isFalse);
    expect(registry.requireModule('construction').hasIssuePolicy, isTrue);
    expect(
      registry.profileRegistry.requireProfile('digital').defaultSourceType,
      'subscription',
    );
    expect(
      registry
          .issuePolicyForDomain('construction')
          ?.paymentScheduleOptions
          ?.strategy,
      BillingPaymentScheduleStrategy.splitEqual,
    );
  });

  test(
    'standardBillingDomainModuleRegistry exposes module navigation policy',
    () {
      final registry = standardBillingDomainModuleRegistry();
      final commercePolicy =
          registry.requireModule('commerce').navigationPolicy;
      final constructionPolicy =
          registry.requireModule('construction').navigationPolicy;

      expect(
        commercePolicy?.destinationIds,
        contains(BillingNavigationDestinationId.cartCheckout),
      );
      expect(
        commercePolicy?.defaultDestinationId,
        BillingNavigationDestinationId.productWorkspace,
      );
      expect(
        constructionPolicy?.destinationIds,
        isNot(contains(BillingNavigationDestinationId.cartCheckout)),
      );
      expect(
        constructionPolicy?.quickActionIds,
        contains(BillingNavigationDestinationId.createInvoice),
      );
    },
  );

  test(
    'standardBillingDomainModuleRegistry exposes module screen registry',
    () {
      final registry = standardBillingDomainModuleRegistry();
      final commerceRegistry =
          registry.requireModule('commerce').screenRegistry;
      final constructionRegistry =
          registry.requireModule('construction').screenRegistry;

      expect(
        commerceRegistry?.contains(
          BillingNavigationDestinationId.productWorkspace,
        ),
        isTrue,
      );
      expect(
        commerceRegistry
            ?.requireScreen(BillingNavigationDestinationId.cartCheckout)
            .surface,
        BillingNavigationSurface.productWorkspace,
      );
      expect(
        commerceRegistry
            ?.requireScreen(BillingNavigationDestinationId.productWorkspace)
            .presentation,
        BillingBusinessDomainScreenPresentation.route,
      );
      expect(
        commerceRegistry
            ?.requireScreen(BillingNavigationDestinationId.cartCheckout)
            .presentation,
        BillingBusinessDomainScreenPresentation.workflow,
      );
      expect(
        constructionRegistry
            ?.requireScreen(BillingNavigationDestinationId.createInvoice)
            .presentation,
        BillingBusinessDomainScreenPresentation.sheet,
      );
      expect(
        constructionRegistry?.contains(
          BillingNavigationDestinationId.cartCheckout,
        ),
        isFalse,
      );
      expect(
        registry
            .screenRegistryForDomain('DIGITAL')
            ?.contains(BillingNavigationDestinationId.createInvoice),
        isTrue,
      );
    },
  );

  test('domain module builders accept composed screen registries', () {
    final screenRegistry = commerceBillingDomainScreenRegistry(
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
    final module = commerceBillingDomainModule(screenRegistry: screenRegistry);

    expect(module.screenRegistry, screenRegistry);
    expect(
      module.screenRegistry?.contains(
        BillingNavigationDestinationId.cartCheckout,
      ),
      isFalse,
    );
    expect(
      module.screenRegistry
          ?.requireScreen(BillingNavigationDestinationId.productWorkspace)
          .key,
      'commerce.catalog_workspace',
    );
  });

  test('standardBillingDomainModuleRegistry adapts commerce cart items', () {
    const item = CartItem(
      product: Product(
        id: 'sku-1',
        name: 'Retail item',
        price: 50,
        category: 'Retail',
      ),
      quantity: 2,
      tenantId: 'tenant-a',
    );
    final registry = standardBillingDomainModuleRegistry();

    final lineItem = registry.lineItemAdapterRegistry.adapt(
      item,
      domain: 'Commerce',
      type: 'Cart_Item',
    );

    expect(lineItem.id, 'cart-tenant-a-sku-1');
    expect(lineItem.source?.domain, 'commerce');
    expect(lineItem.source?.type, 'cart_item');
    expect(lineItem.netSubtotal, 100);
  });

  test('standardBillingDomainModuleRegistry composes product modules', () {
    final serviceProfile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final serviceModule = profileOnlyBillingDomainModule(serviceProfile);

    final registry = standardBillingDomainModuleRegistry(
      additionalModules: [serviceModule],
    );

    expect(registry.domainKeys, [
      'commerce',
      'construction',
      'digital',
      'service',
    ]);
    expect(registry.requireModule('SERVICE'), serviceModule);
    expect(registry.profileRegistry.requireProfile('service'), serviceProfile);
  });

  test('standardBillingDomainModuleRegistry rejects duplicate modules', () {
    expect(
      () => standardBillingDomainModuleRegistry(
        additionalModules: [
          profileOnlyBillingDomainModule(
            BillingBusinessDomainProfile(
              domain: 'commerce',
              label: 'Retail',
              defaultSourceType: 'cart_item',
            ),
          ),
        ],
      ),
      throwsStateError,
    );
  });
}
