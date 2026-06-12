import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('commerce profile exposes checkout workspace destinations', () {
    final ids = billingNavigationDestinationIdsForProfile(
      commerceBillingDomainProfile(),
    );

    expect(ids, contains(BillingNavigationDestinationId.dashboard));
    expect(ids, contains(BillingNavigationDestinationId.workCenter));
    expect(ids, contains(BillingNavigationDestinationId.productWorkspace));
    expect(ids, contains(BillingNavigationDestinationId.cartCheckout));
    expect(ids, contains(BillingNavigationDestinationId.invoices));
    expect(ids, contains(BillingNavigationDestinationId.createInvoice));
    expect(ids, contains(BillingNavigationDestinationId.reports));
    expect(ids, contains(BillingNavigationDestinationId.issueOutbox));
    expect(ids, contains(BillingNavigationDestinationId.diagnostics));
    expect(ids, contains(BillingNavigationDestinationId.tenants));
  });

  test(
    'construction profile keeps core billing without checkout workspace',
    () {
      final ids = billingNavigationDestinationIdsForProfile(
        constructionBillingDomainProfile(),
      );

      expect(ids, contains(BillingNavigationDestinationId.dashboard));
      expect(ids, contains(BillingNavigationDestinationId.workCenter));
      expect(
        ids,
        isNot(contains(BillingNavigationDestinationId.productWorkspace)),
      );
      expect(ids, isNot(contains(BillingNavigationDestinationId.cartCheckout)));
      expect(ids, contains(BillingNavigationDestinationId.invoices));
      expect(ids, contains(BillingNavigationDestinationId.createInvoice));
      expect(ids, contains(BillingNavigationDestinationId.reports));
      expect(ids, contains(BillingNavigationDestinationId.issueOutbox));
      expect(ids, contains(BillingNavigationDestinationId.diagnostics));
      expect(ids, contains(BillingNavigationDestinationId.tenants));
    },
  );

  test('destination policy supports partial product capabilities', () {
    final productOnly = BillingBusinessDomainProfile(
      domain: 'catalog',
      label: 'Catalog',
      defaultSourceType: 'sku',
      capabilities: const {BillingBusinessDomainCapability.productCatalog},
    );

    expect(
      billingNavigationDestinationSupportsProfile(
        BillingNavigationDestinationId.productWorkspace,
        productOnly,
      ),
      isTrue,
    );
    expect(
      billingNavigationDestinationSupportsProfile(
        BillingNavigationDestinationId.cartCheckout,
        productOnly,
      ),
      isFalse,
    );
  });

  test('quick action policy preserves quick-action order', () {
    final ids = billingQuickActionDestinationIdsForProfile(
      digitalSubscriptionBillingDomainProfile(),
    );

    expect(ids.first, BillingNavigationDestinationId.createInvoice);
    expect(
      ids,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
    expect(ids, isNot(contains(BillingNavigationDestinationId.cartCheckout)));
    expect(ids, contains(BillingNavigationDestinationId.invoices));
    expect(ids.last, BillingNavigationDestinationId.tenants);
  });

  test('navigation set keeps destinations and quick actions together', () {
    final navigationSet = billingDomainNavigationSetForProfile(
      constructionBillingDomainProfile(),
    );

    expect(navigationSet.profile.domain, 'construction');
    expect(
      navigationSet.exposes(BillingNavigationDestinationId.createInvoice),
      isTrue,
    );
    expect(
      navigationSet.exposes(BillingNavigationDestinationId.cartCheckout),
      isFalse,
    );
    expect(
      navigationSet.quickActionIds,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
    expect(
      navigationSet.quickActionIds,
      contains(BillingNavigationDestinationId.issueOutbox),
    );
    expect(
      navigationSet.exposes(BillingNavigationDestinationId.diagnostics),
      isTrue,
    );
    expect(
      navigationSet.quickActionIds,
      isNot(contains(BillingNavigationDestinationId.diagnostics)),
    );
  });

  test('module navigation delegates to module profile capabilities', () {
    final module = BillingBusinessDomainModule(
      profile: commerceBillingDomainProfile(),
    );

    final ids = billingNavigationDestinationIdsForModule(module);
    final navigationSet = billingDomainNavigationSetForModule(module);

    expect(
      billingNavigationDestinationSupportsModule(
        BillingNavigationDestinationId.cartCheckout,
        module,
      ),
      isTrue,
    );
    expect(ids, contains(BillingNavigationDestinationId.productWorkspace));
    expect(navigationSet.profile.domain, 'commerce');
    expect(
      navigationSet.quickActionIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
  });

  test('module navigation honors explicit module policy', () {
    final module = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
        capabilities: const {BillingBusinessDomainCapability.servicePeriods},
      ),
      navigationPolicy: BillingBusinessDomainNavigationPolicy(
        destinationIds: const [
          BillingNavigationDestinationId.dashboard,
          BillingNavigationDestinationId.productWorkspace,
          BillingNavigationDestinationId.createInvoice,
        ],
        quickActionIds: const [
          BillingNavigationDestinationId.productWorkspace,
          BillingNavigationDestinationId.createInvoice,
        ],
        defaultDestinationId: BillingNavigationDestinationId.productWorkspace,
      ),
    );

    final ids = billingNavigationDestinationIdsForModule(module);
    final navigationSet = billingDomainNavigationSetForModule(module);

    expect(ids, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.createInvoice,
    ]);
    expect(
      billingNavigationDestinationSupportsModule(
        BillingNavigationDestinationId.productWorkspace,
        module,
      ),
      isTrue,
    );
    expect(
      billingNavigationDestinationSupportsModule(
        BillingNavigationDestinationId.reports,
        module,
      ),
      isFalse,
    );
    expect(
      navigationSet.defaultDestinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(navigationSet.quickActionIds, [
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.createInvoice,
    ]);
  });

  test('module navigation respects registered screens', () {
    final module = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
        capabilities: const {
          BillingBusinessDomainCapability.productCatalog,
          BillingBusinessDomainCapability.cartCheckout,
        },
      ),
      screenRegistry: BillingBusinessDomainScreenRegistry(
        screens: const [
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.dashboard,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.dashboard',
            requiresTenant: false,
          ),
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.createInvoice,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.create_invoice',
          ),
        ],
      ),
    );

    final ids = billingNavigationDestinationIdsForModule(module);
    final navigationSet = billingDomainNavigationSetForModule(module);

    expect(ids, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.createInvoice,
    ]);
    expect(
      billingNavigationDestinationSupportsModule(
        BillingNavigationDestinationId.productWorkspace,
        module,
      ),
      isFalse,
    );
    expect(
      navigationSet.screenRegistry?.contains(
        BillingNavigationDestinationId.createInvoice,
      ),
      isTrue,
    );
    expect(
      navigationSet.quickActionIds,
      contains(BillingNavigationDestinationId.createInvoice),
    );
    expect(
      navigationSet.quickActionIds,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
  });

  test('launch plan exposes module screen metadata', () {
    final navigationSet = billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    );

    final plan = navigationSet.launchPlanFor(
      BillingNavigationDestinationId.cartCheckout,
      hasTenant: true,
    );

    expect(plan.isEnabled, isTrue);
    expect(plan.destinationId, BillingNavigationDestinationId.cartCheckout);
    expect(plan.screenKey, 'commerce.cart_checkout');
    expect(plan.surface, BillingNavigationSurface.productWorkspace);
    expect(plan.presentation, BillingBusinessDomainScreenPresentation.workflow);
    expect(plan.requiresTenant, isTrue);
  });

  test('launch plan blocks tenant-scoped screens without tenant context', () {
    final navigationSet = billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    );

    final invoicePlan = navigationSet.launchPlanFor(
      BillingNavigationDestinationId.createInvoice,
      hasTenant: false,
    );
    final tenantPlan = navigationSet.launchPlanFor(
      BillingNavigationDestinationId.tenants,
      hasTenant: false,
    );

    expect(invoicePlan.isEnabled, isFalse);
    expect(invoicePlan.disabledReason, 'Select a tenant first');
    expect(
      invoicePlan.presentation,
      BillingBusinessDomainScreenPresentation.sheet,
    );
    expect(tenantPlan.isEnabled, isTrue);
    expect(tenantPlan.requiresTenant, isFalse);
  });

  test('launch plan blocks unavailable module destinations', () {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );

    final plan = navigationSet.launchPlanFor(
      BillingNavigationDestinationId.cartCheckout,
      hasTenant: true,
    );

    expect(plan.isEnabled, isFalse);
    expect(
      plan.disabledReason,
      'This destination is not available for this billing domain.',
    );
    expect(plan.hasRegisteredScreen, isFalse);
  });
}
