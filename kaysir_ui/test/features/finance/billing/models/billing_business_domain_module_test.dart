import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item_adapter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('BillingBusinessDomainModule exposes immutable behavior adapters', () {
    final profile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final adapter = _workOrderAdapter(domain: 'service');

    final module = BillingBusinessDomainModule(
      profile: profile,
      lineItemAdapters: [adapter],
    );

    expect(module.key, 'service');
    expect(module.hasLineItemAdapters, isTrue);
    expect(
      module.supports(BillingBusinessDomainCapability.servicePeriods),
      isTrue,
    );
    expect(() => module.lineItemAdapters.add(adapter), throwsUnsupportedError);

    final lineItem = module.lineItemAdapterRegistry.adapt(
      const _WorkOrder('wo-1', 'Repair visit', 240),
      domain: 'SERVICE',
      type: 'WORK_ORDER',
    );

    expect(lineItem.id, 'wo-1');
    expect(lineItem.source?.domain, 'service');
    expect(lineItem.netSubtotal, 240);
  });

  test('BillingBusinessDomainModule exposes domain issue policy', () {
    final policy = BillingInvoiceIssuePolicy(
      domain: 'service',
      label: 'Service',
      taxMode: BillingInvoiceTaxMode.exclusive,
      paymentScheduleOptions: BillingPaymentScheduleOptions.upfrontAndBalance(
        upfrontRatio: 0.25,
      ),
    );

    final module = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
      ),
      issuePolicy: policy,
    );

    expect(module.hasIssuePolicy, isTrue);
    expect(module.issuePolicy, policy);
    expect(module.issuePolicy?.paymentScheduleOptions?.upfrontRatio, 0.25);
  });

  test('BillingBusinessDomainModule exposes domain navigation policy', () {
    final navigationPolicy = BillingBusinessDomainNavigationPolicy(
      destinationIds: const [
        BillingNavigationDestinationId.dashboard,
        BillingNavigationDestinationId.createInvoice,
      ],
      quickActionIds: const [BillingNavigationDestinationId.createInvoice],
      defaultDestinationId: BillingNavigationDestinationId.createInvoice,
    );

    final module = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
      ),
      navigationPolicy: navigationPolicy,
    );

    expect(module.hasNavigationPolicy, isTrue);
    expect(module.navigationPolicy, navigationPolicy);
    expect(
      module.navigationPolicy?.defaultDestinationId,
      BillingNavigationDestinationId.createInvoice,
    );
    expect(
      () => module.navigationPolicy?.destinationIds?.add(
        BillingNavigationDestinationId.reports,
      ),
      throwsUnsupportedError,
    );
    expect(
      module.copyWith(navigationPolicy: null).hasNavigationPolicy,
      isFalse,
    );
  });

  test('BillingBusinessDomainModule exposes domain screen registry', () {
    final screenRegistry = BillingBusinessDomainScreenRegistry(
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
    );

    final module = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
      ),
      navigationPolicy: BillingBusinessDomainNavigationPolicy(
        destinationIds: const [
          BillingNavigationDestinationId.dashboard,
          BillingNavigationDestinationId.createInvoice,
        ],
      ),
      screenRegistry: screenRegistry,
    );

    expect(module.hasScreenRegistry, isTrue);
    expect(module.screenRegistry, screenRegistry);
    expect(
      module.screenRegistry
          ?.requireScreen(BillingNavigationDestinationId.createInvoice)
          .key,
      'service.create_invoice',
    );
    expect(
      module.screenRegistry
          ?.requireScreen(BillingNavigationDestinationId.dashboard)
          .presentation,
      BillingBusinessDomainScreenPresentation.embedded,
    );
    expect(
      () => module.screenRegistry?.screens.add(
        const BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.reports,
          surface: BillingNavigationSurface.dashboard,
          key: 'service.reports',
        ),
      ),
      throwsUnsupportedError,
    );
    expect(module.copyWith(screenRegistry: null).hasScreenRegistry, isFalse);
  });

  test('BillingBusinessDomainModule rejects navigation without a screen', () {
    final screenRegistry = BillingBusinessDomainScreenRegistry(
      screens: const [
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.dashboard,
          surface: BillingNavigationSurface.dashboard,
          key: 'service.dashboard',
        ),
      ],
    );

    expect(
      () => BillingBusinessDomainModule(
        profile: BillingBusinessDomainProfile(
          domain: 'service',
          label: 'Service',
          defaultSourceType: 'work_order',
        ),
        navigationPolicy: BillingBusinessDomainNavigationPolicy(
          destinationIds: const [
            BillingNavigationDestinationId.dashboard,
            BillingNavigationDestinationId.createInvoice,
          ],
        ),
        screenRegistry: screenRegistry,
      ),
      throwsStateError,
    );
  });

  test('BillingBusinessDomainNavigationPolicy validates exposed actions', () {
    expect(
      () => BillingBusinessDomainNavigationPolicy(
        destinationIds: const [
          BillingNavigationDestinationId.dashboard,
          BillingNavigationDestinationId.dashboard,
        ],
      ),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainNavigationPolicy(
        destinationIds: const [BillingNavigationDestinationId.dashboard],
        quickActionIds: const [BillingNavigationDestinationId.createInvoice],
      ),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainNavigationPolicy(
        destinationIds: const [BillingNavigationDestinationId.dashboard],
        defaultDestinationId: BillingNavigationDestinationId.createInvoice,
      ),
      throwsStateError,
    );
  });

  test('BillingBusinessDomainNavigationPolicy constrains to screens', () {
    final policy = BillingBusinessDomainNavigationPolicy(
      destinationIds: const [
        BillingNavigationDestinationId.dashboard,
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.cartCheckout,
      ],
      quickActionIds: const [
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.cartCheckout,
      ],
      defaultDestinationId: BillingNavigationDestinationId.productWorkspace,
    );

    final constrained = policy.constrainedTo(const [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.productWorkspace,
    ]);
    final withoutDefault = policy.constrainedTo(const [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.cartCheckout,
    ]);

    expect(constrained.destinationIds, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.productWorkspace,
    ]);
    expect(constrained.quickActionIds, [
      BillingNavigationDestinationId.productWorkspace,
    ]);
    expect(
      constrained.defaultDestinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(withoutDefault.destinationIds, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.cartCheckout,
    ]);
    expect(withoutDefault.quickActionIds, [
      BillingNavigationDestinationId.cartCheckout,
    ]);
    expect(withoutDefault.defaultDestinationId, isNull);
  });

  test('BillingBusinessDomainScreenRegistry validates unique screens', () {
    final registry = BillingBusinessDomainScreenRegistry(
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
          presentation: BillingBusinessDomainScreenPresentation.sheet,
        ),
      ],
    );

    expect(registry.destinationIds, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.createInvoice,
    ]);
    expect(
      registry
          .screensForSurface(BillingNavigationSurface.dashboard)
          .map((screen) => screen.key),
      ['service.dashboard', 'service.create_invoice'],
    );
    expect(
      registry
          .requireScreen(BillingNavigationDestinationId.dashboard)
          .requiresTenant,
      isFalse,
    );
    expect(
      registry
          .screensForPresentation(BillingBusinessDomainScreenPresentation.sheet)
          .map((screen) => screen.destinationId),
      [BillingNavigationDestinationId.createInvoice],
    );
    expect(
      () => BillingBusinessDomainScreenRegistry(
        screens: const [
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.dashboard,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.dashboard',
          ),
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.dashboard,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.dashboard_duplicate',
          ),
        ],
      ),
      throwsStateError,
    );
  });

  test('BillingBusinessDomainScreenRegistry extends screens immutably', () {
    final registry = BillingBusinessDomainScreenRegistry(
      screens: const [
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.dashboard,
          surface: BillingNavigationSurface.dashboard,
          key: 'service.dashboard',
          requiresTenant: false,
        ),
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.reports,
          surface: BillingNavigationSurface.dashboard,
          key: 'service.reports',
        ),
      ],
    );

    final extended = registry.extend(
      hiddenDestinationIds: const [BillingNavigationDestinationId.reports],
      extensions: const [
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.dashboard,
          surface: BillingNavigationSurface.dashboard,
          key: 'service.dashboard.route',
          requiresTenant: false,
          presentation: BillingBusinessDomainScreenPresentation.route,
        ),
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.createInvoice,
          surface: BillingNavigationSurface.dashboard,
          key: 'service.create_invoice',
          presentation: BillingBusinessDomainScreenPresentation.sheet,
        ),
      ],
    );

    expect(registry.destinationIds, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.reports,
    ]);
    expect(extended.destinationIds, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.createInvoice,
    ]);
    expect(
      extended.requireScreen(BillingNavigationDestinationId.dashboard).key,
      'service.dashboard.route',
    );
    expect(
      extended
          .requireScreen(BillingNavigationDestinationId.dashboard)
          .presentation,
      BillingBusinessDomainScreenPresentation.route,
    );
    expect(
      registry.without(const [
        BillingNavigationDestinationId.dashboard,
      ]).destinationIds,
      [BillingNavigationDestinationId.reports],
    );
  });

  test('BillingBusinessDomainScreenRegistry rejects duplicate extensions', () {
    final registry = BillingBusinessDomainScreenRegistry(
      screens: const [
        BillingBusinessDomainScreenDescriptor(
          destinationId: BillingNavigationDestinationId.dashboard,
          surface: BillingNavigationSurface.dashboard,
          key: 'service.dashboard',
        ),
      ],
    );

    expect(
      () => registry.extend(
        extensions: const [
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.createInvoice,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.create_invoice',
          ),
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.createInvoice,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.create_invoice.duplicate',
          ),
        ],
      ),
      throwsStateError,
    );
  });

  test('BillingBusinessDomainModule rejects cross-domain adapters', () {
    final profile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service',
      defaultSourceType: 'work_order',
    );

    expect(
      () => BillingBusinessDomainModule(
        profile: profile,
        lineItemAdapters: [_workOrderAdapter(domain: 'commerce')],
      ),
      throwsStateError,
    );
  });

  test('BillingBusinessDomainModule rejects cross-domain issue policies', () {
    final profile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service',
      defaultSourceType: 'work_order',
    );

    expect(
      () => BillingBusinessDomainModule(
        profile: profile,
        issuePolicy: BillingInvoiceIssuePolicy(
          domain: 'commerce',
          label: 'Commerce',
          taxMode: BillingInvoiceTaxMode.exclusive,
        ),
      ),
      throwsStateError,
    );
  });

  test('BillingBusinessDomainModuleRegistry composes modules immutably', () {
    final service = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
      ),
      lineItemAdapters: [_workOrderAdapter(domain: 'service')],
    );
    final usage = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'usage',
        label: 'Usage',
        defaultSourceType: 'meter_reading',
      ),
      lineItemAdapters: [_usageAdapter()],
    );
    final registry = BillingBusinessDomainModuleRegistry(modules: [service]);

    final extended = registry.registerAll([usage]);

    expect(registry.domainKeys, ['service']);
    expect(extended.domainKeys, ['service', 'usage']);
    expect(extended.requireModule('USAGE'), usage);
    expect(extended.profileRegistry.requireProfile('usage'), usage.profile);
    expect(extended.issuePolicyForDomain('service'), isNull);
    expect(() => extended.domainKeys.add('manual'), throwsUnsupportedError);

    final lineItem = extended.lineItemAdapterRegistry.adapt(
      const _UsageReading('meter-1', 12, 3.5),
      domain: 'usage',
      type: 'meter_reading',
    );

    expect(lineItem.description, 'Meter meter-1');
    expect(lineItem.netSubtotal, 42);
  });

  test('BillingBusinessDomainModuleRegistry rejects duplicate modules', () {
    final module = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
      ),
    );

    expect(
      () => BillingBusinessDomainModuleRegistry(
        modules: [module, module.copyWith()],
      ),
      throwsStateError,
    );
  });
}

BillingInvoiceLineItemAdapter _workOrderAdapter({required String domain}) {
  return BillingInvoiceLineItemAdapter(
    domain: domain,
    type: 'work_order',
    canAdapt: (value) => value is _WorkOrder,
    toLineItem: (value) {
      final workOrder = value as _WorkOrder;
      return BillingInvoiceLineItem(
        id: workOrder.id,
        description: workOrder.label,
        quantity: 1,
        unitPrice: workOrder.amount,
        unitLabel: 'job',
        source: BillingInvoiceLineItemSource(
          domain: domain,
          type: 'work_order',
          id: workOrder.id,
        ),
      );
    },
  );
}

BillingInvoiceLineItemAdapter _usageAdapter() {
  return BillingInvoiceLineItemAdapter(
    domain: 'usage',
    type: 'meter_reading',
    canAdapt: (value) => value is _UsageReading,
    toLineItem: (value) {
      final reading = value as _UsageReading;
      return BillingInvoiceLineItem(
        id: reading.id,
        description: 'Meter ${reading.id}',
        quantity: reading.quantity,
        unitPrice: reading.unitPrice,
        unitLabel: 'unit',
        source: BillingInvoiceLineItemSource(
          domain: 'usage',
          type: 'meter_reading',
          id: reading.id,
        ),
      );
    },
  );
}

class _WorkOrder {
  final String id;
  final String label;
  final double amount;

  const _WorkOrder(this.id, this.label, this.amount);
}

class _UsageReading {
  final String id;
  final double quantity;
  final double unitPrice;

  const _UsageReading(this.id, this.quantity, this.unitPrice);
}
