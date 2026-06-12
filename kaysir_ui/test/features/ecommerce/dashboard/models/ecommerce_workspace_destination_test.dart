import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/capability.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/destination.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  test('destinations maps workspace state to route cards', () {
    final destinations = destinationsForModules(
      overview: const Overview(
        orderInsights: OrderInsights.empty,
        cartLineCount: 1,
        cartUnitCount: 3,
        cartTotal: 150000,
        promisePolicyIssueCount: 2,
      ),
      modules: defaultModules,
    );

    expect(destinations.map((destination) => destination.id), [
      'checkout',
      'orders',
      'promise_policy',
    ]);
    expect(destinations.first.routePath, Routes.checkoutPath);
    expect(destinations.first.metricValue, '3 items');
    expect(destinations.last.routePath, Routes.ordersPath);
    expect(destinations.last.metricValue, '2 issue(s)');
    expect(destinations.last.tone, DestinationTone.warning);
  });

  test('destinations reports healthy policy state', () {
    final destinations = destinationsForModules(
      overview: const Overview(
        orderInsights: OrderInsights.empty,
        cartLineCount: 0,
        cartUnitCount: 0,
        cartTotal: 0,
        promisePolicyIssueCount: 0,
      ),
      modules: defaultModules,
    );

    expect(destinations.first.metricValue, 'Ready');
    expect(destinations.last.metricValue, 'Ready');
    expect(destinations.last.tone, DestinationTone.success);
  });

  test('destinationsForModules sorts and filters modules', () {
    final destinations = destinationsForModules(
      overview: const Overview(
        orderInsights: OrderInsights.empty,
        cartLineCount: 0,
        cartUnitCount: 0,
        cartTotal: 0,
        promisePolicyIssueCount: 0,
      ),
      modules: [
        _module(id: 'late', sequence: 300),
        _module(id: 'disabled', sequence: 50, enabled: false),
        _module(id: 'early', sequence: 100),
        _module(id: 'same_sequence', sequence: 100),
      ],
    );

    expect(destinations.map((destination) => destination.id), [
      'early',
      'same_sequence',
      'late',
    ]);
  });

  test('destinationsForModules filters by capabilities', () {
    final destinations = destinationsForModules(
      overview: const Overview(
        orderInsights: OrderInsights.empty,
        cartLineCount: 0,
        cartUnitCount: 0,
        cartTotal: 0,
        promisePolicyIssueCount: 0,
      ),
      capabilities: const [ProductCapability.subscriptionBilling],
      modules: [
        _module(id: 'always', sequence: 100),
        _module(
          id: 'subscriptions',
          sequence: 200,
          capabilityGate: const CapabilityGate.any([
            ProductCapability.subscriptionBilling,
          ]),
        ),
        _module(
          id: 'remote_pay',
          sequence: 300,
          capabilityGate: const CapabilityGate.any([
            ProductCapability.remotePayment,
          ]),
        ),
      ],
    );

    expect(destinations.map((destination) => destination.id), [
      'always',
      'subscriptions',
    ]);
  });

  test('specialized order modules deep-link to specialized order routes', () {
    final destinations = destinationsForModules(
      overview: const Overview(
        orderInsights: OrderInsights.empty,
        cartLineCount: 0,
        cartUnitCount: 0,
        cartTotal: 0,
        promisePolicyIssueCount: 0,
      ),
      modules: const [
        ecommerceMarketplaceQueueWorkspaceModule,
        ecommerceFulfillmentQueueWorkspaceModule,
      ],
    );

    expect(
      destinations
          .singleWhere((destination) => destination.id == 'marketplace_queue')
          .routePath,
      Routes.marketplaceOrdersPath,
    );
    expect(
      destinations
          .singleWhere((destination) => destination.id == 'fulfillment_queue')
          .routePath,
      Routes.deliveryOrdersPath,
    );
  });

  test('validateModules accepts the default registry', () {
    final issues = validateModules(
      overview: const Overview(
        orderInsights: OrderInsights.empty,
        cartLineCount: 0,
        cartUnitCount: 0,
        cartTotal: 0,
        promisePolicyIssueCount: 0,
      ),
      modules: defaultModules,
    );

    expect(issues, isEmpty);
  });

  test('validateModules catches registry issues', () {
    final issues = validateModules(
      overview: const Overview(
        orderInsights: OrderInsights.empty,
        cartLineCount: 0,
        cartUnitCount: 0,
        cartTotal: 0,
        promisePolicyIssueCount: 0,
      ),
      modules: [
        _module(id: '', sequence: 10),
        _module(id: 'duplicate', sequence: 20),
        _module(id: 'duplicate', sequence: 30),
        _module(
          id: 'bad_destination',
          sequence: 40,
          destinationId: '',
          title: '',
          routePath: 'commerce/bad',
          actionLabel: '',
        ),
      ],
    );

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        ModuleIssueType.blankModuleId,
        ModuleIssueType.duplicateModuleId,
        ModuleIssueType.blankDestinationId,
        ModuleIssueType.blankDestinationTitle,
        ModuleIssueType.invalidDestinationRoute,
        ModuleIssueType.blankActionLabel,
      ]),
    );
  });

  test('validateModules catches empty and disabled registries', () {
    final overview = const Overview(
      orderInsights: OrderInsights.empty,
      cartLineCount: 0,
      cartUnitCount: 0,
      cartTotal: 0,
      promisePolicyIssueCount: 0,
    );

    expect(
      validateModules(overview: overview, modules: const []).single.type,
      ModuleIssueType.emptyRegistry,
    );
    expect(
      validateModules(
        overview: overview,
        modules: [_module(id: 'disabled', sequence: 10, enabled: false)],
      ).map((issue) => issue.type),
      contains(ModuleIssueType.noEnabledModules),
    );
    expect(
      validateModules(
        overview: overview,
        capabilities: const [ProductCapability.storefrontCheckout],
        modules: [
          _module(
            id: 'subscriptions',
            sequence: 10,
            capabilityGate: const CapabilityGate.any([
              ProductCapability.subscriptionBilling,
            ]),
          ),
        ],
      ).map((issue) => issue.type),
      contains(ModuleIssueType.noEnabledModules),
    );
  });
}

Module _module({
  required String id,
  required int sequence,
  bool enabled = true,
  String? destinationId,
  String? title,
  String? routePath,
  String? actionLabel,
  CapabilityGate capabilityGate = CapabilityGate.always,
}) {
  return Module(
    id: id,
    sequence: sequence,
    enabled: enabled,
    capabilityGate: capabilityGate,
    buildDestination:
        (_) => Destination(
          id: destinationId ?? id,
          title: title ?? id,
          subtitle: id,
          routePath: routePath ?? '/$id',
          metricLabel: 'Metric',
          metricValue: id,
          actionLabel: actionLabel ?? 'Open',
          icon: Icons.extension_outlined,
          tone: DestinationTone.secondary,
        ),
  );
}
