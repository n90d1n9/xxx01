import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/cart/states/cart_providers.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_requirement.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/destination.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/health.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/presentation_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/section_order.dart';
import 'package:kaysir/features/ecommerce/dashboard/repositories/workspace_profile_preferences_repository.dart';
import 'package:kaysir/features/ecommerce/dashboard/states/workspace_provider.dart';
import 'package:kaysir/features/ecommerce/order/cart_item.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_promise_policy.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/ecommerce/order/states/order_fulfillment_promise_policy_provider.dart';
import 'package:kaysir/features/ecommerce/order/states/order_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('overviewProvider composes live workspace state', () {
    const invalidPolicy = OrderFulfillmentPromisePolicy(
      warningWindow: Duration.zero,
      defaultTarget: OrderFulfillmentPromiseTarget(
        id: '',
        label: '',
        duration: Duration.zero,
      ),
    );
    final container = _providerContainer(
      overrides: [
        ecommerceOrderFulfillmentPromisePolicyProvider.overrideWithValue(
          invalidPolicy,
        ),
      ],
    );
    addTearDown(container.dispose);
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

    container.read(cartProvider.notifier).addProduct(product);
    container
        .read(ecommerceOrdersProvider.notifier)
        .addOrder(
          [CartItem(product: product)],
          PaymentMethod.card,
          createdAt: DateTime(2026, 5, 31, 10),
        );

    final overview = container.read(overviewProvider);

    expect(overview.orderInsights.orderCount, 1);
    expect(overview.orderInsights.revenue, 50000);
    expect(overview.cartLineCount, 1);
    expect(overview.cartUnitCount, 1);
    expect(overview.promisePolicyIssueCount, greaterThan(0));
    expect(
      overview.operationalAlertCount,
      greaterThanOrEqualTo(overview.promisePolicyIssueCount),
    );
  });

  test('destinationsProvider exposes hub route cards', () {
    final container = _providerContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'tea', name: 'Tea', price: 25000);

    container.read(cartProvider.notifier).addProduct(product);

    final destinations = container.read(destinationsProvider);

    expect(destinations.map((destination) => destination.id), [
      'checkout',
      'orders',
      'promise_policy',
    ]);
    expect(destinations.first.routePath, Routes.checkoutPath);
    expect(destinations.first.metricValue, '1 item');
    expect(destinations[1].routePath, Routes.ordersPath);
    expect(destinations.last.routePath, Routes.ordersPath);
  });

  test('modulesProvider can be extended by product lines', () {
    final container = _providerContainer(
      overrides: [
        modulesProvider.overrideWithValue([
          ...defaultModules,
          Module(
            id: 'subscriptions',
            sequence: 250,
            buildDestination:
                (overview) => Destination(
                  id: 'subscriptions',
                  title: 'Subscriptions',
                  subtitle: 'Manage recurring commerce plans.',
                  routePath: '/commerce/subscriptions',
                  metricLabel: 'Plans',
                  metricValue: '${overview.cartLineCount}',
                  actionLabel: 'Open plans',
                  icon: Icons.autorenew_outlined,
                  tone: DestinationTone.secondary,
                ),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final destinations = container.read(destinationsProvider);

    expect(destinations.map((destination) => destination.id), [
      'checkout',
      'orders',
      'subscriptions',
      'promise_policy',
    ]);
    expect(
      destinations
          .singleWhere((destination) => destination.id == 'subscriptions')
          .routePath,
      '/commerce/subscriptions',
    );
  });

  test('workspace providers filter modules and actions by capabilities', () {
    final subscriptionModule = Module(
      id: 'subscriptions',
      sequence: 100,
      capabilityGate: const CapabilityGate.any([
        ProductCapability.subscriptionBilling,
      ]),
      buildDestination:
          (_) => const Destination(
            id: 'subscriptions',
            title: 'Subscriptions',
            subtitle: 'Manage recurring commerce plans.',
            routePath: '/commerce/subscriptions',
            metricLabel: 'Plans',
            metricValue: '3',
            actionLabel: 'Open plans',
            icon: Icons.autorenew_outlined,
            tone: DestinationTone.secondary,
          ),
    );
    final storefrontModule = Module(
      id: 'storefront',
      sequence: 200,
      capabilityGate: const CapabilityGate.any([
        ProductCapability.storefrontCheckout,
      ]),
      buildDestination:
          (_) => const Destination(
            id: 'storefront',
            title: 'Storefront checkout',
            subtitle: 'Create storefront orders.',
            routePath: '/commerce/checkout',
            metricLabel: 'Basket',
            metricValue: 'Ready',
            actionLabel: 'Open checkout',
            icon: Icons.point_of_sale_outlined,
            tone: DestinationTone.primary,
          ),
    );
    final subscriptionRule = ActionRule(
      id: 'subscriptions',
      capabilityGate: const CapabilityGate.any([
        ProductCapability.subscriptionBilling,
      ]),
      buildAction:
          (_) => const Action(
            id: 'subscriptions',
            title: 'Review subscriptions',
            description: 'Renewal orders need confirmation.',
            actionLabel: 'Open renewals',
            routePath: '/commerce/subscriptions',
            icon: Icons.autorenew_outlined,
            tone: ActionTone.warning,
            priority: 5,
          ),
    );
    final storefrontRule = ActionRule(
      id: 'storefront',
      capabilityGate: const CapabilityGate.any([
        ProductCapability.storefrontCheckout,
      ]),
      buildAction:
          (_) => const Action(
            id: 'storefront',
            title: 'Start checkout',
            description: 'Create a storefront order.',
            actionLabel: 'Open checkout',
            routePath: '/commerce/checkout',
            icon: Icons.point_of_sale_outlined,
            tone: ActionTone.primary,
            priority: 10,
          ),
    );
    final profile = ProductProfile.standard.copyWith(
      id: 'subscriptions',
      label: 'Subscription commerce',
      description: 'Recurring plan commerce profile.',
      capabilities: const [ProductCapability.subscriptionBilling],
      modules: [subscriptionModule, storefrontModule],
      actionRules: [subscriptionRule, storefrontRule],
    );
    final container = _providerContainer(
      overrides: [
        productProfilesProvider.overrideWithValue([profile]),
        productProfileIdProvider.overrideWith(
          (ref) => _profileIdNotifier('subscriptions'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(productCapabilitiesProvider), [
      ProductCapability.subscriptionBilling,
    ]);
    expect(
      container.read(destinationsProvider).map((destination) => destination.id),
      ['subscriptions'],
    );
    expect(container.read(actionsProvider).map((action) => action.id), [
      'subscriptions',
    ]);
    expect(container.read(moduleIssuesProvider), isEmpty);
    expect(container.read(actionRuleIssuesProvider), isEmpty);
  });

  test('productProfileProvider selects registered profiles', () {
    final module = Module(
      id: 'subscriptions',
      buildDestination:
          (_) => const Destination(
            id: 'subscriptions',
            title: 'Subscriptions',
            subtitle: 'Manage recurring commerce plans.',
            routePath: '/commerce/subscriptions',
            metricLabel: 'Plans',
            metricValue: '1',
            actionLabel: 'Open plans',
            icon: Icons.autorenew_outlined,
            tone: DestinationTone.secondary,
          ),
    );
    final actionRule = ActionRule(
      id: 'subscriptions',
      buildAction:
          (_) => const Action(
            id: 'subscriptions',
            title: 'Review subscriptions',
            description: 'Renewal orders need confirmation.',
            actionLabel: 'Open renewals',
            routePath: '/commerce/subscriptions',
            icon: Icons.autorenew_outlined,
            tone: ActionTone.warning,
            priority: 5,
          ),
    );
    final profile = ProductProfile.standard.copyWith(
      id: 'subscriptions',
      label: 'Subscription commerce',
      description: 'Recurring plan commerce profile.',
      presentationProfile: PresentationProfile.operationsFirst,
      modules: [module],
      actionRules: [actionRule],
    );
    final container = _providerContainer(
      overrides: [
        productProfilesProvider.overrideWithValue([profile]),
        productProfileIdProvider.overrideWith(
          (ref) => _profileIdNotifier('subscriptions'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(productProfileProvider).id, 'subscriptions');
    expect(container.read(presentationProfileProvider).id, 'operations_first');
    expect(container.read(modulesProvider), [module]);
    expect(container.read(actionRulesProvider), [actionRule]);
  });

  test('productProfileIdProvider can switch profiles', () async {
    final store = MemoryProfilePreferencesStore();
    final container = ProviderContainer(
      overrides: [
        profilePreferencesRepositoryProvider.overrideWithValue(
          ProfilePreferencesRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(productProfileProvider).id, 'standard');

    await container
        .read(productProfileIdProvider.notifier)
        .selectProfile('operations_first');
    await container.read(productProfileIdProvider.notifier).flush();

    expect(container.read(productProfileProvider).id, 'operations_first');
    expect(container.read(presentationProfileProvider).id, 'operations_first');
    expect(store.snapshot, {'selectedProfileId': 'operations_first'});
  });

  test('productProfileIdProvider hydrates persisted profile', () async {
    final store = MemoryProfilePreferencesStore(
      initialSnapshot: const {'selectedProfileId': 'remote_payment'},
    );
    final container = ProviderContainer(
      overrides: [
        profilePreferencesRepositoryProvider.overrideWithValue(
          ProfilePreferencesRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(productProfileIdProvider.notifier).hydrate();

    expect(container.read(productProfileProvider).id, 'remote_payment');
  });

  test('product profile search providers keep scoped query state', () {
    const pickerScope = 'picker';
    const sidebarScope = 'sidebar';
    final container = _providerContainer();
    addTearDown(container.dispose);

    container
        .read(productProfileSearchQueryProvider(pickerScope).notifier)
        .state = 'price lists';

    final pickerResults = container.read(
      productProfileSearchResultsProvider(pickerScope),
    );
    final sidebarResults = container.read(
      productProfileSearchResultsProvider(sidebarScope),
    );

    expect(pickerResults.map((result) => result.profile.id), [
      'marketplace_operations',
    ]);
    expect(
      pickerResults.single.primaryMatch?.type,
      ProductProfileSearchMatchType.channelCoverageRequirement,
    );
    expect(container.read(productProfileSearchQueryProvider(sidebarScope)), '');
    expect(sidebarResults.length, defaultProductProfiles.length);
  });

  test('product profile search providers keep scoped match type filters', () {
    const pickerScope = 'picker';
    const sidebarScope = 'sidebar';
    final container = _providerContainer();
    addTearDown(container.dispose);

    container
        .read(productProfileSearchQueryProvider(pickerScope).notifier)
        .state = 'price lists';
    container
        .read(productProfileSearchMatchTypesProvider(pickerScope).notifier)
        .state = const {ProductProfileSearchMatchType.recommendation};

    final pickerResults = container.read(
      productProfileSearchResultsProvider(pickerScope),
    );
    final sidebarResults = container.read(
      productProfileSearchResultsProvider(sidebarScope),
    );

    expect(pickerResults.map((result) => result.profile.id), [
      'marketplace_operations',
    ]);
    expect(
      pickerResults.single.primaryMatch?.type,
      ProductProfileSearchMatchType.recommendation,
    );
    expect(
      container.read(productProfileSearchMatchTypesProvider(sidebarScope)),
      isEmpty,
    );
    expect(sidebarResults.length, defaultProductProfiles.length);
  });

  test('product profile comparison rows follow scoped search results', () {
    const registryScope = 'registry';
    final container = _providerContainer();
    addTearDown(container.dispose);

    expect(
      container
          .read(profileSearchComparisonRowsProvider(registryScope))
          .map((row) => row.profileId),
      [
        'standard',
        'operations_first',
        'remote_payment',
        'subscription_commerce',
        'fulfillment_first',
        'marketplace_operations',
      ],
    );

    container
        .read(productProfileSearchQueryProvider(registryScope).notifier)
        .state = 'seller center';

    expect(
      container
          .read(profileSearchComparisonRowsProvider(registryScope))
          .map((row) => row.profileId),
      ['marketplace_operations'],
    );
  });

  test(
    'product profile search providers support scoped profile registries',
    () {
      const pickerScope = 'custom_picker';
      final profiles = [
        ProductProfile.standard,
        ProductProfile.marketplaceOperations,
      ];
      final container = _providerContainer(
        overrides: [
          productProfileSearchProfilesProvider(
            pickerScope,
          ).overrideWithValue(profiles),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container
            .read(productProfileSearchResultsProvider(pickerScope))
            .map((result) => result.profile.id),
        ['standard', 'marketplace_operations'],
      );

      container
          .read(productProfileSearchQueryProvider(pickerScope).notifier)
          .state = 'price lists';

      expect(
        container
            .read(productProfileSearchResultsProvider(pickerScope))
            .map((result) => result.profile.id),
        ['marketplace_operations'],
      );
    },
  );

  test('product preset selection drives filtered workspace state', () {
    final container = _providerContainer(
      overrides: [
        productProfileIdProvider.overrideWith(
          (ref) => _profileIdNotifier('fulfillment_first'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(viewStateProvider);
    final channelStrategy = container.read(channelStrategyProvider);

    expect(state.productProfile.id, 'fulfillment_first');
    expect(state.channelStrategy.channelCountLabel, '3 channels');
    expect(channelStrategy.fulfillmentTrackingCoverageLabel, '3 channels');
    expect(state.destinations.map((destination) => destination.id), [
      'orders',
      'fulfillment_queue',
      'promise_policy',
    ]);
    expect(state.actions.map((action) => action.id), [
      'fulfillment_queue_review',
      'open_orders',
    ]);
    expect(
      state.destinations
          .singleWhere((destination) => destination.id == 'fulfillment_queue')
          .routePath,
      Routes.deliveryOrdersPath,
    );
    expect(
      state.actions
          .singleWhere((action) => action.id == 'fulfillment_queue_review')
          .routePath,
      Routes.ordersPath,
    );
    expect(
      state.destinations.any((destination) => destination.id == 'checkout'),
      isFalse,
    );
  });

  test('channelStrategyProvider follows profile requirements', () {
    final container = _providerContainer(
      overrides: [
        productProfileIdProvider.overrideWith(
          (ref) => _profileIdNotifier('marketplace_operations'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final requirements = container.read(channelCoverageRequirementsProvider);
    final strategy = container.read(channelStrategyProvider);
    final state = container.read(viewStateProvider);

    expect(
      requirements.last,
      ecommerceMarketplacePriceListChannelCoverageRequirement,
    );
    expect(strategy.coverageRequirements, requirements);
    expect(
      strategy.coverageSignals.map((signal) => signal.label),
      contains('Price lists'),
    );
    expect(
      strategy.coverageSignals
          .singleWhere((signal) => signal.label == 'Price lists')
          .value,
      '2 channels',
    );
    expect(
      state.destinations
          .singleWhere((destination) => destination.id == 'marketplace_queue')
          .routePath,
      Routes.marketplaceOrdersPath,
    );
    expect(
      state.actions
          .singleWhere((action) => action.id == 'marketplace_queue_review')
          .routePath,
      Routes.marketplaceOrdersPath,
    );
  });

  test('productProfileIssuesProvider follows registry selection', () {
    final container = _providerContainer(
      overrides: [
        productProfileIdProvider.overrideWith(
          (ref) => _profileIdNotifier('missing'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final issues = container.read(productProfileIssuesProvider);
    final health = container.read(healthProvider);
    final diagnostics = container.read(registryDiagnosticsProvider);
    final actions = container.read(actionsProvider);

    expect(
      issues.single.type,
      ProductProfileIssueType.unknownSelectedProfileId,
    );
    expect(health.productProfileIssueCount, 1);
    expect(health.tone, HealthTone.danger);
    expect(diagnostics.productProfileIssueCount, 1);
    expect(diagnostics.issues.first.source, RegistryIssueSource.profile);
    expect(actions.first.id, 'product_profile_review');
  });

  test('presentationProfileProvider can be overridden', () {
    final container = _providerContainer(
      overrides: [
        presentationProfileProvider.overrideWithValue(
          PresentationProfile.operationsFirst,
        ),
      ],
    );
    addTearDown(container.dispose);

    final profile = container.read(presentationProfileProvider);

    expect(profile.id, 'operations_first');
    expect(profile.sectionOrder.slots.first, SectionSlot.operations);
  });

  test('moduleIssuesProvider follows module overrides', () {
    final container = _providerContainer(
      overrides: [
        modulesProvider.overrideWithValue([
          Module(
            id: 'bad',
            buildDestination:
                (_) => const Destination(
                  id: '',
                  title: '',
                  subtitle: 'Broken module',
                  routePath: 'commerce/bad',
                  metricLabel: 'Broken',
                  metricValue: '1',
                  actionLabel: '',
                  icon: Icons.extension_off_outlined,
                  tone: DestinationTone.warning,
                ),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final issues = container.read(moduleIssuesProvider);

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        ModuleIssueType.blankDestinationId,
        ModuleIssueType.blankDestinationTitle,
        ModuleIssueType.invalidDestinationRoute,
        ModuleIssueType.blankActionLabel,
      ]),
    );
  });

  test('healthProvider includes registry diagnostics', () {
    final container = _providerContainer(
      overrides: [
        modulesProvider.overrideWithValue([
          Module(
            id: 'bad',
            buildDestination:
                (_) => const Destination(
                  id: '',
                  title: 'Broken module',
                  subtitle: 'Broken module',
                  routePath: '/commerce/bad',
                  metricLabel: 'Broken',
                  metricValue: '1',
                  actionLabel: 'Open',
                  icon: Icons.extension_off_outlined,
                  tone: DestinationTone.warning,
                ),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final health = container.read(healthProvider);

    expect(health.tone, HealthTone.danger);
    expect(health.moduleIssueCount, 1);
    expect(health.title, 'Critical workspace attention');
    expect(
      health.signals.singleWhere((signal) => signal.id == 'modules').value,
      '1 issue',
    );
  });

  test('healthProvider includes channel coverage gaps', () {
    const leanMarketplaceChannel = POSCommerceChannel(
      id: 'lean_marketplace',
      kind: POSCommerceChannelKind.marketplace,
      label: 'Lean marketplace',
      description: 'Marketplace channel without fulfillment handoff mapping.',
      preferredLayout: POSLayoutPreference.checkout,
      fulfillmentModes: [],
      capabilities: [POSCommerceChannelCapability.inventoryReservation],
    );
    final profile = ProductProfile.standard.copyWith(
      id: 'lean_marketplace',
      label: 'Lean marketplace commerce',
      description: 'Marketplace profile still missing fulfillment mapping.',
      capabilities: const [ProductCapability.marketplaceOrders],
      salesChannels: const [leanMarketplaceChannel],
    );
    final container = _providerContainer(
      overrides: [
        productProfilesProvider.overrideWithValue([profile]),
        productProfileIdProvider.overrideWith(
          (ref) => _profileIdNotifier('lean_marketplace'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final health = container.read(healthProvider);
    final actions = container.read(actionsProvider);

    expect(health.tone, HealthTone.warning);
    expect(health.productProfileIssueCount, 0);
    expect(health.channelCoverageGapCount, 1);
    expect(health.message, '1 channel coverage gap needs playbook review.');
    expect(
      health.signals
          .singleWhere((signal) => signal.id == 'channel_coverage')
          .value,
      '1 gap',
    );
    expect(actions.first.id, 'channel_playbook_review');
    expect(actions.first.routePath, Routes.routePath);
  });

  test('actionsProvider follows health priority', () {
    final container = _providerContainer(
      overrides: [
        modulesProvider.overrideWithValue([
          Module(
            id: 'bad',
            buildDestination:
                (_) => const Destination(
                  id: '',
                  title: 'Broken module',
                  subtitle: 'Broken module',
                  routePath: '/commerce/bad',
                  metricLabel: 'Broken',
                  metricValue: '1',
                  actionLabel: 'Open',
                  icon: Icons.extension_off_outlined,
                  tone: DestinationTone.warning,
                ),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final actions = container.read(actionsProvider);

    expect(actions.first.id, 'module_registry_review');
    expect(actions.first.routePath, Routes.routePath);
  });

  test('actionRulesProvider can be extended', () {
    final container = _providerContainer(
      overrides: [
        actionRulesProvider.overrideWithValue([
          ActionRule(
            id: 'subscriptions',
            sequence: 5,
            buildAction:
                (_) => const Action(
                  id: 'subscriptions',
                  title: 'Review subscriptions',
                  description: 'Renewal orders need confirmation.',
                  actionLabel: 'Open renewals',
                  routePath: '/commerce/subscriptions',
                  icon: Icons.autorenew_outlined,
                  tone: ActionTone.warning,
                  priority: 5,
                ),
          ),
          ...defaultActionRules,
        ]),
      ],
    );
    addTearDown(container.dispose);

    final actions = container.read(actionsProvider);

    expect(actions.map((action) => action.id), [
      'subscriptions',
      'start_checkout',
      'open_orders',
    ]);
  });

  test('actionRuleIssuesProvider follows rule overrides', () {
    final container = _providerContainer(
      overrides: [
        actionRulesProvider.overrideWithValue([
          ActionRule(
            id: 'bad',
            buildAction:
                (_) => const Action(
                  id: '',
                  title: '',
                  description: '',
                  actionLabel: '',
                  routePath: 'commerce/bad',
                  icon: Icons.block_outlined,
                  tone: ActionTone.warning,
                  priority: 1,
                ),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final issues = container.read(actionRuleIssuesProvider);
    final health = container.read(healthProvider);

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        ActionRuleIssueType.blankActionId,
        ActionRuleIssueType.blankActionTitle,
        ActionRuleIssueType.blankActionDescription,
        ActionRuleIssueType.blankActionLabel,
        ActionRuleIssueType.invalidActionRoute,
      ]),
    );
    expect(health.actionRuleIssueCount, issues.length);
    expect(health.tone, HealthTone.danger);
  });

  test('registryDiagnosticsProvider combines registries', () {
    final container = _providerContainer(
      overrides: [
        modulesProvider.overrideWithValue([
          Module(
            id: 'bad_module',
            buildDestination:
                (_) => const Destination(
                  id: '',
                  title: 'Broken module',
                  subtitle: 'Broken module',
                  routePath: '/commerce/bad',
                  metricLabel: 'Broken',
                  metricValue: '1',
                  actionLabel: 'Open',
                  icon: Icons.extension_off_outlined,
                  tone: DestinationTone.warning,
                ),
          ),
        ]),
        actionRulesProvider.overrideWithValue([
          ActionRule(
            id: 'bad_action',
            buildAction:
                (_) => const Action(
                  id: '',
                  title: 'Broken action',
                  description: 'Broken action',
                  actionLabel: 'Open',
                  routePath: '/commerce/bad-action',
                  icon: Icons.block_outlined,
                  tone: ActionTone.warning,
                  priority: 1,
                ),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final diagnostics = container.read(registryDiagnosticsProvider);

    expect(diagnostics.moduleIssueCount, 1);
    expect(diagnostics.actionRuleIssueCount, 1);
    expect(diagnostics.totalIssueCount, 2);
    expect(diagnostics.issues.map((issue) => issue.source.label), [
      'Module',
      'Action',
    ]);
  });

  test('viewStateProvider aggregates screen state', () {
    final container = _providerContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'dates', name: 'Dates', price: 30000);

    container.read(cartProvider.notifier).addProduct(product);

    final state = container.read(viewStateProvider);

    expect(state.productProfile.id, 'standard');
    expect(state.channelStrategy.channelCount, 3);
    expect(state.hasChannelStrategy, isTrue);
    expect(state.overview.cartLineCount, 1);
    expect(state.health.isReady, isTrue);
    expect(state.destinations.map((destination) => destination.id), [
      'checkout',
      'orders',
      'promise_policy',
    ]);
    expect(state.actions.first.id, 'continue_checkout');
    expect(state.registryDiagnostics.hasIssues, isFalse);
    expect(state.hasDestinations, isTrue);
    expect(state.hasPriorityActions, isTrue);
    expect(state.hasRegistryIssues, isFalse);
  });
}

ProviderContainer _providerContainer({List<dynamic> overrides = const []}) {
  return ProviderContainer(
    overrides: [_profilePreferencesRepositoryOverride(), ...overrides],
  );
}

dynamic _profilePreferencesRepositoryOverride() {
  return profilePreferencesRepositoryProvider.overrideWithValue(
    _memoryRepository(),
  );
}

ProductProfileIdNotifier _profileIdNotifier(String profileId) {
  return ProductProfileIdNotifier(
    repository: _memoryRepository(),
    initialProfileId: profileId,
    autoHydrate: false,
  );
}

ProfilePreferencesRepository _memoryRepository() {
  return ProfilePreferencesRepository(store: MemoryProfilePreferencesStore());
}
