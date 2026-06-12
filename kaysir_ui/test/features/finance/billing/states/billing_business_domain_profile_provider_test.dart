import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item_adapter.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_blueprint_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_pack_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_profile_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_checkout_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_module_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_plan.dart';

void main() {
  test('registry provider exposes the standard billing domains', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registry = container.read(
      billingBusinessDomainProfileRegistryProvider,
    );

    expect(registry.requireProfile('commerce').domain, 'commerce');
    expect(registry.requireProfile('construction').domain, 'construction');
    expect(registry.requireProfile('digital').domain, 'digital');
  });

  test('module registry provider derives standard packs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final packRegistry = container.read(
      billingBusinessDomainPackRegistryProvider,
    );
    final packReadiness = container.read(
      billingBusinessDomainPackRegistryReadinessProvider(true),
    );
    final packContract = container.read(
      billingBusinessDomainPackContractRegistryProvider(true),
    );
    final moduleRegistry = container.read(
      billingBusinessDomainModuleRegistryProvider,
    );

    expect(packRegistry.domainKeys, moduleRegistry.domainKeys);
    expect(moduleRegistry.requireModule('commerce').profile.domain, 'commerce');
    expect(packReadiness.domainKeys, moduleRegistry.domainKeys);
    expect(packReadiness.isReady, isTrue);
    expect(packReadiness.warningIssueCount, 4);
    expect(packContract.domainKeys, moduleRegistry.domainKeys);
    expect(packContract.isReleaseReady, isTrue);
    expect(packContract.openRequirementCount, 4);
    expect(packContract.warningRequirementCount, 4);
    expect(packContract.blockedRequirementCount, 0);
  });

  test('module registry provider accepts custom pack registries', () {
    final serviceProfile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service operations',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final container = ProviderContainer(
      overrides: [
        billingBusinessDomainPackRegistryProvider.overrideWithValue(
          BillingBusinessDomainPackRegistry(
            packs: [
              BillingBusinessDomainPack(
                module: BillingBusinessDomainModule(profile: serviceProfile),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final moduleRegistry = container.read(
      billingBusinessDomainModuleRegistryProvider,
    );

    expect(moduleRegistry.domainKeys, ['service']);
    expect(
      container
          .read(
            billingTenantDomainProfileProvider(
              const BillingTenantPreferences(businessDomain: 'service'),
            ),
          )
          .label,
      'Service operations',
    );
  });

  test('registry coverage provider audits active domain modules', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final tenantReadyReport = container.read(
      billingBusinessDomainModuleRegistryNavigationCoverageProvider(true),
    );
    final noTenantReport = container.read(
      billingBusinessDomainModuleRegistryNavigationCoverageProvider(false),
    );

    expect(tenantReadyReport.isComplete, isTrue);
    expect(tenantReadyReport.domainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(noTenantReport.isComplete, isFalse);
    expect(noTenantReport.hasIssues, isTrue);
    expect(noTenantReport.incompleteDomainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(
      tenantReadyReport.requireReportForDomain('commerce').destinationIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
    expect(
      noTenantReport
          .issuesForDomain('digital')
          .map((issue) => issue.destinationId),
      contains(BillingNavigationDestinationId.createInvoice),
    );
  });

  test('registry readiness provider audits active domain modules', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final tenantReadyReport = container.read(
      billingBusinessDomainModuleRegistryReadinessProvider(true),
    );
    final noTenantReport = container.read(
      billingBusinessDomainModuleRegistryReadinessProvider(false),
    );

    expect(tenantReadyReport.isReady, isTrue);
    expect(tenantReadyReport.domainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(tenantReadyReport.warningIssueCount, 2);
    expect(
      tenantReadyReport.warningIssues.map((issue) => issue.kind),
      everyElement(
        BillingDomainModuleReadinessIssueKind.missingLineItemAdapter,
      ),
    );
    expect(noTenantReport.isReady, isFalse);
    expect(noTenantReport.blockedDomainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(
      noTenantReport
          .requireReportForDomain('commerce')
          .hasIssueKind(
            BillingDomainModuleReadinessIssueKind.navigationCoverage,
          ),
      isTrue,
    );
  });

  test('tenant profile provider can resolve custom domain registries', () {
    final serviceProfile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service operations',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final container = ProviderContainer(
      overrides: [
        billingBusinessDomainProfileRegistryProvider.overrideWithValue(
          BillingBusinessDomainProfileRegistry(profiles: [serviceProfile]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final profile = container.read(
      billingTenantDomainProfileProvider(
        const BillingTenantPreferences(businessDomain: 'service'),
      ),
    );

    expect(profile, serviceProfile);
  });

  test('module registry provider exposes product domain behavior', () {
    final serviceProfile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service operations',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final serviceModule = BillingBusinessDomainModule(
      profile: serviceProfile,
      lineItemAdapters: [
        BillingInvoiceLineItemAdapter(
          domain: 'service',
          type: 'work_order',
          canAdapt: (value) => value is _WorkOrder,
          toLineItem: (value) {
            final workOrder = value as _WorkOrder;
            return BillingInvoiceLineItem(
              id: workOrder.id,
              description: workOrder.label,
              quantity: 1,
              unitPrice: workOrder.amount,
              source: BillingInvoiceLineItemSource(
                domain: 'service',
                type: 'work_order',
                id: workOrder.id,
              ),
            );
          },
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        billingBusinessDomainModuleRegistryProvider.overrideWithValue(
          BillingBusinessDomainModuleRegistry(modules: [serviceModule]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final profile = container.read(
      billingTenantDomainProfileProvider(
        const BillingTenantPreferences(businessDomain: 'SERVICE'),
      ),
    );
    final lineItem = container
        .read(billingInvoiceLineItemAdapterRegistryProvider)
        .adapt(
          const _WorkOrder('wo-1', 'Repair visit', 240),
          domain: 'service',
          type: 'work_order',
        );

    expect(profile, serviceProfile);
    expect(lineItem.id, 'wo-1');
    expect(lineItem.source?.domain, 'service');
  });

  test('tenant module provider resolves custom module registries', () {
    final serviceProfile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service operations',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final serviceModule = BillingBusinessDomainModule(profile: serviceProfile);
    final container = ProviderContainer(
      overrides: [
        billingBusinessDomainModuleRegistryProvider.overrideWithValue(
          BillingBusinessDomainModuleRegistry(modules: [serviceModule]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final module = container.read(
      billingTenantDomainModuleProvider(
        const BillingTenantPreferences(businessDomain: ' SERVICE '),
      ),
    );

    expect(module, serviceModule);
    expect(
      container
          .read(billingBusinessDomainModuleForDomainProvider('service'))
          .profile,
      serviceProfile,
    );
  });

  test('tenant module readiness provider follows tenant domains', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final constructionReport = container.read(
      billingTenantDomainModuleReadinessProvider(
        const BillingNavigationLaunchPlannerRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );
    final blockedCommerceReport = container.read(
      billingTenantDomainModuleReadinessProvider(
        const BillingNavigationLaunchPlannerRequest(
          preferences: BillingTenantPreferences(businessDomain: 'commerce'),
          hasTenant: false,
        ),
      ),
    );

    expect(constructionReport.domainKey, 'construction');
    expect(constructionReport.isReady, isTrue);
    expect(constructionReport.hasWarnings, isTrue);
    expect(
      constructionReport.hasIssueKind(
        BillingDomainModuleReadinessIssueKind.missingLineItemAdapter,
      ),
      isTrue,
    );
    expect(blockedCommerceReport.isReady, isFalse);
    expect(
      blockedCommerceReport.hasIssueKind(
        BillingDomainModuleReadinessIssueKind.navigationCoverage,
      ),
      isTrue,
    );
  });

  test('checkout domain profile follows the selected tenant', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(currentTenantProvider.notifier).state = const Tenant(
      id: 'tenant-digital',
      name: 'Digital tenant',
      logoUrl: '',
      preferences: BillingTenantPreferences(businessDomain: 'digital'),
    );

    final profile = container.read(billingCheckoutDomainProfileProvider);

    expect(profile.domain, 'digital');
    expect(
      profile.supports(BillingBusinessDomainCapability.recurringSubscriptions),
      isTrue,
    );
  });

  test('checkout domain profile falls back before tenant selection', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(billingCheckoutDomainProfileProvider).domain,
      'commerce',
    );
  });

  test('checkout domain module follows the selected tenant', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(currentTenantProvider.notifier).state = const Tenant(
      id: 'tenant-construction',
      name: 'Construction tenant',
      logoUrl: '',
      preferences: BillingTenantPreferences(businessDomain: 'construction'),
    );

    final module = container.read(billingCheckoutDomainModuleProvider);

    expect(module.key, 'construction');
    expect(module.profile.defaultSourceType, 'milestone');
    expect(module.hasIssuePolicy, isTrue);
  });

  test('tenant navigation set provider resolves domain destinations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final commerceNavigationSet = container.read(
      billingTenantDomainNavigationSetProvider(
        const BillingTenantPreferences(businessDomain: 'commerce'),
      ),
    );
    final constructionNavigationSet = container.read(
      billingTenantDomainNavigationSetProvider(
        const BillingTenantPreferences(businessDomain: 'construction'),
      ),
    );

    expect(commerceNavigationSet.profile.domain, 'commerce');
    expect(
      commerceNavigationSet.exposes(
        BillingNavigationDestinationId.cartCheckout,
      ),
      isTrue,
    );
    expect(constructionNavigationSet.profile.domain, 'construction');
    expect(
      constructionNavigationSet.exposes(
        BillingNavigationDestinationId.cartCheckout,
      ),
      isFalse,
    );
  });

  test(
    'tenant module navigation set provider resolves domain destinations',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final commerceNavigationSet = container.read(
        billingTenantDomainModuleNavigationSetProvider(
          const BillingTenantPreferences(businessDomain: 'commerce'),
        ),
      );
      final constructionNavigationSet = container.read(
        billingTenantDomainModuleNavigationSetProvider(
          const BillingTenantPreferences(businessDomain: 'construction'),
        ),
      );

      expect(commerceNavigationSet.profile.domain, 'commerce');
      expect(
        commerceNavigationSet.exposes(
          BillingNavigationDestinationId.cartCheckout,
        ),
        isTrue,
      );
      expect(constructionNavigationSet.profile.domain, 'construction');
      expect(
        constructionNavigationSet.exposes(
          BillingNavigationDestinationId.cartCheckout,
        ),
        isFalse,
      );
    },
  );

  test('tenant module screen registry provider resolves domain screens', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final commerceRegistry = container.read(
      billingTenantDomainModuleScreenRegistryProvider(
        const BillingTenantPreferences(businessDomain: 'commerce'),
      ),
    );
    final constructionRegistry = container.read(
      billingBusinessDomainScreenRegistryForDomainProvider('construction'),
    );
    final navigationSet = container.read(
      billingTenantDomainModuleNavigationSetProvider(
        const BillingTenantPreferences(businessDomain: 'commerce'),
      ),
    );

    expect(
      commerceRegistry?.contains(BillingNavigationDestinationId.cartCheckout),
      isTrue,
    );
    expect(
      constructionRegistry?.contains(
        BillingNavigationDestinationId.cartCheckout,
      ),
      isFalse,
    );
    expect(
      navigationSet.screenRegistry?.contains(
        BillingNavigationDestinationId.productWorkspace,
      ),
      isTrue,
    );
    expect(
      commerceRegistry
          ?.screensForPresentation(
            BillingBusinessDomainScreenPresentation.sheet,
          )
          .map((screen) => screen.destinationId),
      contains(BillingNavigationDestinationId.createInvoice),
    );
  });

  test('default module navigation planner gates tenant routes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final planner = container.read(
      billingDefaultDomainModuleNavigationLaunchPlannerProvider(false),
    );

    expect(planner.navigationSet?.profile.domain, 'commerce');
    expect(
      planner
          .stateFor(BillingNavigationDestinationId.productWorkspace)
          .isEnabled,
      isFalse,
    );
    expect(
      planner.stateFor(BillingNavigationDestinationId.tenants).isEnabled,
      isTrue,
    );
  });

  test('tenant module navigation planner follows tenant domain modules', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final planner = container.read(
      billingTenantDomainModuleNavigationLaunchPlannerProvider(
        const BillingNavigationLaunchPlannerRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(planner.navigationSet?.profile.domain, 'construction');
    expect(
      planner.quickActionIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      planner.stateFor(BillingNavigationDestinationId.cartCheckout).isEnabled,
      isFalse,
    );
  });

  test('default module navigation snapshots expose launch state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final destinationSnapshot = container.read(
      billingDefaultDomainModuleDestinationLaunchSnapshotProvider(false),
    );
    final quickActionSnapshot = container.read(
      billingDefaultDomainModuleQuickActionLaunchSnapshotProvider(false),
    );

    expect(
      destinationSnapshot.defaultDestinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(
      destinationSnapshot
          .stateFor(BillingNavigationDestinationId.productWorkspace)
          ?.isEnabled,
      isFalse,
    );
    expect(
      destinationSnapshot.selectedDestinationIdFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      quickActionSnapshot.disabledStates.map((state) => state.destinationId),
      contains(BillingNavigationDestinationId.createInvoice),
    );
    expect(
      quickActionSnapshot.firstEnabledState()?.destinationId,
      BillingNavigationDestinationId.tenants,
    );
  });

  test('default module dispatch snapshots expose surface decisions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final destinationSnapshot = container.read(
      billingDefaultDomainModuleDestinationDispatchSnapshotProvider(
        const BillingDefaultNavigationDispatchSnapshotRequest(
          hasTenant: false,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );
    final quickActionSnapshot = container.read(
      billingDefaultDomainModuleQuickActionDispatchSnapshotProvider(
        const BillingDefaultNavigationDispatchSnapshotRequest(
          hasTenant: false,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );

    expect(
      destinationSnapshot
          .planFor(BillingNavigationDestinationId.productWorkspace)
          ?.isUnavailable,
      isTrue,
    );
    expect(
      destinationSnapshot.selectedDestinationIdFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      quickActionSnapshot.planFor(BillingNavigationDestinationId.tenants)?.kind,
      BillingNavigationDispatchKind.route,
    );
    expect(
      quickActionSnapshot.firstActionablePlan()?.destinationId,
      BillingNavigationDestinationId.tenants,
    );
  });

  test('tenant module navigation snapshots follow tenant domain modules', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const request = BillingNavigationLaunchPlannerRequest(
      preferences: BillingTenantPreferences(businessDomain: 'construction'),
      hasTenant: true,
    );

    final destinationSnapshot = container.read(
      billingTenantDomainModuleDestinationLaunchSnapshotProvider(request),
    );
    final quickActionSnapshot = container.read(
      billingTenantDomainModuleQuickActionLaunchSnapshotProvider(request),
    );

    expect(
      destinationSnapshot.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      destinationSnapshot.statesForSurface(
        BillingNavigationSurface.productWorkspace,
      ),
      isEmpty,
    );
    expect(
      quickActionSnapshot.destinationIds,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
    expect(quickActionSnapshot.disabledStates, isEmpty);
  });

  test('tenant module dispatch snapshots follow current surface', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const request = BillingNavigationDispatchSnapshotRequest(
      preferences: BillingTenantPreferences(businessDomain: 'construction'),
      hasTenant: true,
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    final destinationSnapshot = container.read(
      billingTenantDomainModuleDestinationDispatchSnapshotProvider(request),
    );
    final quickActionSnapshot = container.read(
      billingTenantDomainModuleQuickActionDispatchSnapshotProvider(request),
    );

    expect(
      destinationSnapshot.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      quickActionSnapshot.routePlans.map((plan) => plan.destinationId),
      containsAll([
        BillingNavigationDestinationId.invoices,
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.tenants,
      ]),
    );
    expect(
      quickActionSnapshot.localPlans.map((plan) => plan.destinationId),
      containsAll([
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.issueOutbox,
      ]),
    );
  });

  test('default module navigation coverage reports tenant gaps', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final report = container.read(
      billingDefaultDomainModuleNavigationCoverageProvider(false),
    );

    expect(report.navigationSet.profile.domain, 'commerce');
    expect(report.isComplete, isFalse);
    expect(
      report.reachableDestinationIds,
      containsAll([
        BillingNavigationDestinationId.dashboard,
        BillingNavigationDestinationId.tenants,
      ]),
    );
    expect(
      report.unreachableDestinationIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
    expect(
      report
          .coverageFor(BillingNavigationDestinationId.productWorkspace)
          .disabledReason,
      'Select a tenant first',
    );
  });

  test('tenant module navigation coverage follows tenant domains', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final commerceReport = container.read(
      billingTenantDomainModuleNavigationCoverageProvider(
        const BillingNavigationLaunchPlannerRequest(
          preferences: BillingTenantPreferences(businessDomain: 'commerce'),
          hasTenant: true,
        ),
      ),
    );
    final constructionReport = container.read(
      billingTenantDomainModuleNavigationCoverageProvider(
        const BillingNavigationLaunchPlannerRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(commerceReport.isComplete, isTrue);
    expect(constructionReport.isComplete, isTrue);
    expect(
      commerceReport.destinationIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
    expect(
      constructionReport.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      constructionReport
          .coverageFor(BillingNavigationDestinationId.createInvoice)
          .actionableSurfaces,
      containsAll([
        BillingNavigationSurface.dashboard,
        BillingNavigationSurface.productWorkspace,
      ]),
    );
  });

  test('default module launch state provider evaluates destinations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final productWorkspaceState = container.read(
      billingDefaultDomainModuleNavigationLaunchStateProvider(
        const BillingDefaultNavigationLaunchStateRequest(
          destinationId: BillingNavigationDestinationId.productWorkspace,
          hasTenant: false,
        ),
      ),
    );
    final tenantsState = container.read(
      billingDefaultDomainModuleNavigationLaunchStateProvider(
        const BillingDefaultNavigationLaunchStateRequest(
          destinationId: BillingNavigationDestinationId.tenants,
          hasTenant: false,
        ),
      ),
    );

    expect(productWorkspaceState.isEnabled, isFalse);
    expect(productWorkspaceState.disabledReason, 'Select a tenant first');
    expect(tenantsState.isEnabled, isTrue);
  });

  test('tenant module launch state provider evaluates hidden destinations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cartCheckoutState = container.read(
      billingTenantDomainModuleNavigationLaunchStateProvider(
        const BillingTenantNavigationLaunchStateRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          destinationId: BillingNavigationDestinationId.cartCheckout,
          hasTenant: true,
        ),
      ),
    );
    final invoicesState = container.read(
      billingTenantDomainModuleNavigationLaunchStateProvider(
        const BillingTenantNavigationLaunchStateRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          destinationId: BillingNavigationDestinationId.invoices,
          hasTenant: true,
        ),
      ),
    );

    expect(cartCheckoutState.isEnabled, isFalse);
    expect(
      cartCheckoutState.disabledReason,
      'This destination is not available for this billing domain.',
    );
    expect(invoicesState.isEnabled, isTrue);
  });

  test('navigation launch requests derive tenant state consistently', () {
    final plannerRequest = BillingNavigationLaunchPlannerRequest.fromTenant(
      preferences: const BillingTenantPreferences(businessDomain: 'digital'),
      tenantId: 'tenant-42',
    );
    final emptyTenantRequest = BillingNavigationLaunchPlannerRequest.fromTenant(
      preferences: const BillingTenantPreferences(businessDomain: 'digital'),
      tenantId: '',
    );

    expect(plannerRequest.hasTenant, isTrue);
    expect(emptyTenantRequest.hasTenant, isFalse);
    expect(
      BillingNavigationDispatchSnapshotRequest.fromTenant(
        preferences: const BillingTenantPreferences(businessDomain: 'digital'),
        tenantId: 'tenant-42',
        currentSurface: BillingNavigationSurface.dashboard,
      ).plannerRequest,
      plannerRequest,
    );
    expect(
      plannerRequest.stateRequestFor(BillingNavigationDestinationId.reports),
      BillingTenantNavigationLaunchStateRequest.fromTenant(
        preferences: const BillingTenantPreferences(businessDomain: 'digital'),
        tenantId: 'tenant-42',
        destinationId: BillingNavigationDestinationId.reports,
      ),
    );
    expect(
      BillingDefaultNavigationLaunchStateRequest.forDestination(
        BillingNavigationDestinationId.tenants,
      ),
      const BillingDefaultNavigationLaunchStateRequest(
        destinationId: BillingNavigationDestinationId.tenants,
        hasTenant: false,
      ),
    );
  });

  test('tenant module navigation set provider honors custom module policy', () {
    final serviceModule = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service operations',
        defaultSourceType: 'work_order',
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
    final container = ProviderContainer(
      overrides: [
        billingBusinessDomainModuleRegistryProvider.overrideWithValue(
          BillingBusinessDomainModuleRegistry(modules: [serviceModule]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final navigationSet = container.read(
      billingTenantDomainModuleNavigationSetProvider(
        const BillingTenantPreferences(businessDomain: 'service'),
      ),
    );

    expect(navigationSet.profile.domain, 'service');
    expect(
      navigationSet.exposes(BillingNavigationDestinationId.productWorkspace),
      isTrue,
    );
    expect(
      navigationSet.exposes(BillingNavigationDestinationId.reports),
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

  test('tenant navigation set provider normalizes tenant domain keys', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final navigationSet = container.read(
      billingTenantDomainNavigationSetProvider(
        const BillingTenantPreferences(businessDomain: ' Construction '),
      ),
    );

    expect(navigationSet.profile.domain, 'construction');
    expect(
      navigationSet.exposes(BillingNavigationDestinationId.invoices),
      isTrue,
    );
    expect(
      navigationSet.exposes(BillingNavigationDestinationId.cartCheckout),
      isFalse,
    );
  });

  test('domain blueprint providers expose reusable module contracts', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registry = container.read(
      billingBusinessDomainModuleBlueprintRegistryProvider(true),
    );
    final construction = container.read(
      billingTenantDomainModuleBlueprintProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );
    final blockedDefault = container.read(
      billingDefaultDomainModuleBlueprintProvider(false),
    );

    expect(registry.domainKeys, ['commerce', 'construction', 'digital']);
    expect(registry.isLaunchReady, isTrue);
    expect(registry.warningContractCount, 2);
    expect(construction.productModeLabel, 'Project billing');
    expect(
      construction.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      construction.requireContract('line_items').state,
      BillingBusinessDomainBlueprintContractState.warning,
    );
    expect(blockedDefault.domainKey, 'commerce');
    expect(blockedDefault.isLaunchReady, isFalse);
    expect(
      blockedDefault.requireContract('navigation').state,
      BillingBusinessDomainBlueprintContractState.blocker,
    );
  });

  test('blueprint planning providers expose reusable release decisions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registryMatrix = container.read(
      billingBusinessDomainModuleBlueprintFitMatrixProvider(true),
    );
    final registryPortfolio = container.read(
      billingBusinessDomainModuleBlueprintLaunchPortfolioProvider(true),
    );
    final blockedPortfolio = container.read(
      billingBusinessDomainModuleBlueprintLaunchPortfolioProvider(false),
    );
    final defaultPortfolio = container.read(
      billingDefaultDomainModuleBlueprintLaunchPortfolioProvider(true),
    );
    final constructionPortfolio = container.read(
      billingTenantDomainModuleBlueprintLaunchPortfolioProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registryMatrix.domainKeys, ['commerce', 'construction', 'digital']);
    expect(registryMatrix.supportedCellCount, 7);
    expect(registryPortfolio.packageCount, 1);
    expect(registryPortfolio.hardenCount, 2);
    expect(registryPortfolio.blockedCount, 0);
    expect(blockedPortfolio.blockedCount, 3);
    expect(defaultPortfolio.domainKeys, ['commerce']);
    expect(
      defaultPortfolio.requirePlanForDomain('commerce').supportedSignalLabels,
      ['Checkout', 'Omni-channel'],
    );
    expect(constructionPortfolio.domainKeys, ['construction']);
    expect(
      constructionPortfolio.requirePlanForDomain('construction').lane,
      BillingBusinessDomainBlueprintLaunchLane.harden,
    );
  });

  test('product package providers map releasable billing products', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registry = container.read(billingProductPackageRegistryProvider);
    final portfolio = container.read(
      billingBusinessDomainModuleProductPackagePortfolioProvider(true),
    );
    final blockedPortfolio = container.read(
      billingBusinessDomainModuleProductPackagePortfolioProvider(false),
    );
    final defaultPortfolio = container.read(
      billingDefaultDomainModuleProductPackagePortfolioProvider(true),
    );
    final constructionPortfolio = container.read(
      billingTenantDomainModuleProductPackagePortfolioProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registry.packageKeys, [
      'commerce_checkout',
      'project_billing',
      'digital_subscriptions',
      'service_operations',
      'omni_channel_billing',
    ]);
    expect(portfolio.packageCount, 5);
    expect(portfolio.packageNowCount, 2);
    expect(portfolio.hardenCount, 3);
    expect(blockedPortfolio.blockedCount, 5);
    expect(defaultPortfolio.packageNowCount, 2);
    expect(defaultPortfolio.unavailableCount, 3);
    expect(constructionPortfolio.hardenCount, 2);
    expect(
      constructionPortfolio.requirePlanForPackage('service_operations').lane,
      BillingProductPackageLane.harden,
    );
  });
}

class _WorkOrder {
  final String id;
  final String label;
  final double amount;

  const _WorkOrder(this.id, this.label, this.amount);
}
