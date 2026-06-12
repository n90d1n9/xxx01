import 'package:flutter/material.dart';

import '../routes.dart';
import 'capability.dart';
import 'destination.dart';
import 'overview.dart';

typedef DestinationBuilder = Destination Function(Overview overview);

enum ModuleIssueType {
  emptyRegistry,
  noEnabledModules,
  blankModuleId,
  duplicateModuleId,
  destinationBuildFailed,
  blankDestinationId,
  duplicateDestinationId,
  blankDestinationTitle,
  blankDestinationRoute,
  invalidDestinationRoute,
  blankActionLabel,
}

class ModuleIssue {
  final ModuleIssueType type;
  final String message;
  final String? moduleId;
  final String? destinationId;

  const ModuleIssue({
    required this.type,
    required this.message,
    this.moduleId,
    this.destinationId,
  });
}

class Module {
  final String id;
  final int sequence;
  final bool enabled;
  final CapabilityGate capabilityGate;
  final DestinationBuilder buildDestination;

  const Module({
    required this.id,
    required this.buildDestination,
    this.sequence = 0,
    this.enabled = true,
    this.capabilityGate = CapabilityGate.always,
  });

  Destination destinationFor(Overview overview) {
    return buildDestination(overview);
  }

  bool supportsCapabilities(Iterable<ProductCapability> capabilities) {
    return capabilityGate.allows(capabilities);
  }
}

const defaultModules = <Module>[
  Module(
    id: 'checkout',
    sequence: 100,
    capabilityGate: CapabilityGate.any([
      ProductCapability.storefrontCheckout,
      ProductCapability.marketplaceOrders,
      ProductCapability.remotePayment,
    ]),
    buildDestination: ecommerceCheckoutWorkspaceDestination,
  ),
  Module(
    id: 'orders',
    sequence: 200,
    capabilityGate: CapabilityGate.any([
      ProductCapability.marketplaceOrders,
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ]),
    buildDestination: ecommerceOrdersWorkspaceDestination,
  ),
  Module(
    id: 'promise_policy',
    sequence: 300,
    capabilityGate: CapabilityGate.any([
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ]),
    buildDestination: ecommercePromisePolicyWorkspaceDestination,
  ),
];

const ecommerceRemotePaymentWorkspaceModule = Module(
  id: 'remote_payments',
  sequence: 90,
  capabilityGate: CapabilityGate.any([ProductCapability.remotePayment]),
  buildDestination: ecommerceRemotePaymentWorkspaceDestination,
);

const ecommerceMarketplaceQueueWorkspaceModule = Module(
  id: 'marketplace_queue',
  sequence: 190,
  capabilityGate: CapabilityGate.any([ProductCapability.marketplaceOrders]),
  buildDestination: ecommerceMarketplaceQueueWorkspaceDestination,
);

const ecommerceSubscriptionRenewalsWorkspaceModule = Module(
  id: 'subscription_renewals',
  sequence: 210,
  capabilityGate: CapabilityGate.any([ProductCapability.subscriptionBilling]),
  buildDestination: ecommerceSubscriptionRenewalsWorkspaceDestination,
);

const ecommerceFulfillmentQueueWorkspaceModule = Module(
  id: 'fulfillment_queue',
  sequence: 220,
  capabilityGate: CapabilityGate.any([
    ProductCapability.pickupDelivery,
    ProductCapability.shipping,
    ProductCapability.operationsReview,
  ]),
  buildDestination: ecommerceFulfillmentQueueWorkspaceDestination,
);

List<ModuleIssue> validateModules({
  required Iterable<Module> modules,
  required Overview overview,
  Iterable<ProductCapability>? capabilities,
}) {
  final moduleList = modules.toList(growable: false);
  final issues = <ModuleIssue>[];
  final seenModuleIds = <String>{};
  final seenDestinationIds = <String>{};

  if (moduleList.isEmpty) {
    issues.add(
      const ModuleIssue(
        type: ModuleIssueType.emptyRegistry,
        message: 'Add at least one commerce workspace module.',
      ),
    );
    return List.unmodifiable(issues);
  }

  if (_activeModulesForCapabilities(moduleList, capabilities).isEmpty) {
    issues.add(
      const ModuleIssue(
        type: ModuleIssueType.noEnabledModules,
        message: 'Enable at least one commerce workspace module.',
      ),
    );
  }

  for (final module in moduleList) {
    final moduleId = module.id.trim();
    if (moduleId.isEmpty) {
      issues.add(
        const ModuleIssue(
          type: ModuleIssueType.blankModuleId,
          message: 'Commerce workspace modules need a stable module id.',
        ),
      );
    } else if (!seenModuleIds.add(moduleId)) {
      issues.add(
        ModuleIssue(
          type: ModuleIssueType.duplicateModuleId,
          moduleId: moduleId,
          message: 'Duplicate commerce workspace module id "$moduleId".',
        ),
      );
    }

    if (!module.enabled) continue;
    if (capabilities != null && !module.supportsCapabilities(capabilities)) {
      continue;
    }

    late final Destination destination;
    try {
      destination = module.destinationFor(overview);
    } catch (_) {
      issues.add(
        ModuleIssue(
          type: ModuleIssueType.destinationBuildFailed,
          moduleId: moduleId.isEmpty ? null : moduleId,
          message:
              moduleId.isEmpty
                  ? 'A commerce workspace module failed to build its destination.'
                  : 'Commerce workspace module "$moduleId" failed to build its destination.',
        ),
      );
      continue;
    }

    _validateDestination(
      issues: issues,
      destination: destination,
      moduleId: moduleId,
      seenDestinationIds: seenDestinationIds,
    );
  }

  return List.unmodifiable(issues);
}

void _validateDestination({
  required List<ModuleIssue> issues,
  required Destination destination,
  required String moduleId,
  required Set<String> seenDestinationIds,
}) {
  final destinationId = destination.id.trim();
  final routePath = destination.routePath.trim();
  final issueModuleId = moduleId.isEmpty ? null : moduleId;
  final issueDestinationId = destinationId.isEmpty ? null : destinationId;

  if (destinationId.isEmpty) {
    issues.add(
      ModuleIssue(
        type: ModuleIssueType.blankDestinationId,
        moduleId: issueModuleId,
        message:
            moduleId.isEmpty
                ? 'Commerce workspace destinations need a stable id.'
                : 'Commerce workspace module "$moduleId" returned a destination without an id.',
      ),
    );
  } else if (!seenDestinationIds.add(destinationId)) {
    issues.add(
      ModuleIssue(
        type: ModuleIssueType.duplicateDestinationId,
        moduleId: issueModuleId,
        destinationId: destinationId,
        message:
            'Duplicate commerce workspace destination id "$destinationId".',
      ),
    );
  }

  if (destination.title.trim().isEmpty) {
    issues.add(
      ModuleIssue(
        type: ModuleIssueType.blankDestinationTitle,
        moduleId: issueModuleId,
        destinationId: issueDestinationId,
        message:
            destinationId.isEmpty
                ? 'Commerce workspace destinations need a visible title.'
                : 'Commerce workspace destination "$destinationId" needs a visible title.',
      ),
    );
  }

  if (routePath.isEmpty) {
    issues.add(
      ModuleIssue(
        type: ModuleIssueType.blankDestinationRoute,
        moduleId: issueModuleId,
        destinationId: issueDestinationId,
        message:
            destinationId.isEmpty
                ? 'Commerce workspace destinations need a route path.'
                : 'Commerce workspace destination "$destinationId" needs a route path.',
      ),
    );
  } else if (!routePath.startsWith('/')) {
    final label =
        destinationId.isEmpty
            ? (moduleId.isEmpty ? 'unknown' : moduleId)
            : destinationId;
    issues.add(
      ModuleIssue(
        type: ModuleIssueType.invalidDestinationRoute,
        moduleId: issueModuleId,
        destinationId: issueDestinationId,
        message:
            'Commerce workspace destination "$label" route must start with "/".',
      ),
    );
  }

  if (destination.actionLabel.trim().isEmpty) {
    issues.add(
      ModuleIssue(
        type: ModuleIssueType.blankActionLabel,
        moduleId: issueModuleId,
        destinationId: issueDestinationId,
        message:
            destinationId.isEmpty
                ? 'Commerce workspace destinations need an action label.'
                : 'Commerce workspace destination "$destinationId" needs an action label.',
      ),
    );
  }
}

List<Destination> destinationsForModules({
  required Overview overview,
  required Iterable<Module> modules,
  Iterable<ProductCapability>? capabilities,
}) {
  final sortedModules =
      _activeModulesForCapabilities(modules, capabilities).toList()
        ..sort((a, b) {
          final sequenceComparison = a.sequence.compareTo(b.sequence);
          if (sequenceComparison != 0) return sequenceComparison;
          return a.id.compareTo(b.id);
        });

  return List.unmodifiable(
    sortedModules.map((module) => module.destinationFor(overview)),
  );
}

Iterable<Module> _activeModulesForCapabilities(
  Iterable<Module> modules,
  Iterable<ProductCapability>? capabilities,
) {
  final enabledModules = modules.where((module) => module.enabled);
  if (capabilities == null) return enabledModules;

  return enabledModules.where(
    (module) => module.supportsCapabilities(capabilities),
  );
}

Destination ecommerceCheckoutWorkspaceDestination(Overview overview) {
  return Destination(
    id: 'checkout',
    title: ' POS',
    subtitle: 'Create storefront, marketplace, and remote checkout orders.',
    routePath: Routes.checkoutPath,
    metricLabel: 'Basket',
    metricValue: overview.cartLineCount == 0 ? 'Ready' : overview.cartLabel,
    actionLabel: 'Open checkout',
    icon: Icons.point_of_sale_outlined,
    tone: DestinationTone.primary,
  );
}

Destination ecommerceRemotePaymentWorkspaceDestination(Overview overview) {
  return Destination(
    id: 'remote_payments',
    title: 'Remote payments',
    subtitle:
        'Prepare payment-link checkout for chat, social, and assisted orders.',
    routePath: Routes.checkoutPath,
    metricLabel: 'Basket',
    metricValue: overview.cartLineCount == 0 ? 'Ready' : overview.cartLabel,
    actionLabel: 'Open payments',
    icon: Icons.payments_outlined,
    tone: DestinationTone.primary,
  );
}

Destination ecommerceOrdersWorkspaceDestination(Overview overview) {
  return Destination(
    id: 'orders',
    title: 'Order workspace',
    subtitle: 'Review fulfillment, settlement, SLA, and channel workload.',
    routePath: Routes.ordersPath,
    metricLabel: 'Orders',
    metricValue: '${overview.orderInsights.orderCount}',
    actionLabel: 'Open orders',
    icon: Icons.receipt_long_outlined,
    tone: DestinationTone.secondary,
  );
}

Destination ecommerceMarketplaceQueueWorkspaceDestination(Overview overview) {
  return Destination(
    id: 'marketplace_queue',
    title: 'Marketplace queue',
    subtitle:
        'Review marketplace orders, external settlement, and handoff load.',
    routePath: Routes.marketplaceOrdersPath,
    metricLabel: 'Orders',
    metricValue: '${overview.orderInsights.orderCount}',
    actionLabel: 'Open marketplace',
    icon: Icons.store_mall_directory_outlined,
    tone:
        overview.orderInsights.attentionOrderCount == 0
            ? DestinationTone.secondary
            : DestinationTone.warning,
  );
}

Destination ecommerceSubscriptionRenewalsWorkspaceDestination(
  Overview overview,
) {
  return Destination(
    id: 'subscription_renewals',
    title: 'Subscription renewals',
    subtitle:
        'Track recurring commerce orders, renewal payment, and plan handoff.',
    routePath: Routes.ordersPath,
    metricLabel: 'Renewals',
    metricValue:
        overview.orderInsights.orderCount == 0
            ? 'Ready'
            : '${overview.orderInsights.orderCount}',
    actionLabel: 'Review renewals',
    icon: Icons.autorenew_outlined,
    tone: DestinationTone.secondary,
  );
}

Destination ecommerceFulfillmentQueueWorkspaceDestination(Overview overview) {
  return Destination(
    id: 'fulfillment_queue',
    title: 'Fulfillment queue',
    subtitle: 'Coordinate pickup, delivery, shipping, and exception handling.',
    routePath: Routes.deliveryOrdersPath,
    metricLabel: 'Attention',
    metricValue:
        overview.orderInsights.attentionOrderCount == 0
            ? 'Clear'
            : '${overview.orderInsights.attentionOrderCount}',
    actionLabel: 'Review queue',
    icon: Icons.local_shipping_outlined,
    tone:
        overview.orderInsights.attentionOrderCount == 0
            ? DestinationTone.success
            : DestinationTone.warning,
  );
}

Destination ecommercePromisePolicyWorkspaceDestination(Overview overview) {
  return Destination(
    id: 'promise_policy',
    title: 'Promise policy',
    subtitle: 'Inspect fulfillment promise targets and configuration health.',
    routePath: Routes.ordersPath,
    metricLabel: 'Policy',
    metricValue: overview.policyHealthLabel,
    actionLabel: 'Review policy',
    icon: Icons.rule_folder_outlined,
    tone:
        overview.hasPolicyIssues
            ? DestinationTone.warning
            : DestinationTone.success,
  );
}
