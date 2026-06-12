import 'package:flutter/material.dart';

import '../routes.dart';
import 'capability.dart';
import 'health.dart';
import 'overview.dart';
import 'section_order.dart';

enum ActionTone { primary, secondary, warning, danger }

typedef ActionBuilder = Action? Function(ActionContext context);

enum ActionRuleIssueType {
  emptyRegistry,
  noEnabledRules,
  blankRuleId,
  duplicateRuleId,
  actionBuildFailed,
  blankActionId,
  blankActionTitle,
  blankActionDescription,
  blankActionLabel,
  blankActionRoute,
  invalidActionRoute,
}

class ActionRuleIssue {
  final ActionRuleIssueType type;
  final String message;
  final String? ruleId;
  final String? actionId;

  const ActionRuleIssue({
    required this.type,
    required this.message,
    this.ruleId,
    this.actionId,
  });
}

class ActionContext {
  final Overview overview;
  final HealthSummary health;
  final List<ProductCapability> capabilities;

  const ActionContext({
    required this.overview,
    required this.health,
    this.capabilities = const [],
  });
}

class Action {
  final String id;
  final String title;
  final String description;
  final String actionLabel;
  final String routePath;
  final IconData icon;
  final ActionTone tone;
  final int priority;
  final SectionSlot? focusSection;

  const Action({
    required this.id,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.routePath,
    required this.icon,
    required this.tone,
    required this.priority,
    this.focusSection,
  });
}

class ActionRule {
  final String id;
  final int sequence;
  final bool enabled;
  final CapabilityGate capabilityGate;
  final ActionBuilder buildAction;

  const ActionRule({
    required this.id,
    required this.buildAction,
    this.sequence = 0,
    this.enabled = true,
    this.capabilityGate = CapabilityGate.always,
  });

  Action? actionFor(ActionContext context) {
    return buildAction(context);
  }

  bool supportsCapabilities(Iterable<ProductCapability> capabilities) {
    return capabilityGate.allows(capabilities);
  }
}

final List<ActionRule> defaultActionRules = List.unmodifiable([
  ActionRule(
    id: 'product_profile_review',
    sequence: 5,
    buildAction: _productProfileReviewAction,
  ),
  ActionRule(
    id: 'module_registry_review',
    sequence: 10,
    buildAction: _moduleRegistryReviewAction,
  ),
  ActionRule(
    id: 'critical_order_review',
    sequence: 20,
    capabilityGate: CapabilityGate.any([
      ProductCapability.marketplaceOrders,
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ]),
    buildAction: _criticalOrderReviewAction,
  ),
  ActionRule(
    id: 'order_attention_review',
    sequence: 30,
    capabilityGate: CapabilityGate.any([
      ProductCapability.marketplaceOrders,
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ]),
    buildAction: _orderAttentionReviewAction,
  ),
  ActionRule(
    id: 'channel_playbook_review',
    sequence: 35,
    buildAction: _channelPlaybookReviewAction,
  ),
  ActionRule(
    id: 'promise_policy_review',
    sequence: 40,
    capabilityGate: CapabilityGate.any([
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ]),
    buildAction: _promisePolicyReviewAction,
  ),
  ActionRule(
    id: 'continue_checkout',
    sequence: 50,
    capabilityGate: CapabilityGate.any([
      ProductCapability.storefrontCheckout,
      ProductCapability.marketplaceOrders,
      ProductCapability.remotePayment,
    ]),
    buildAction: _continueCheckoutAction,
  ),
]);

const ecommerceRemotePaymentActionRule = ActionRule(
  id: 'remote_payment_checkout',
  sequence: 15,
  capabilityGate: CapabilityGate.any([ProductCapability.remotePayment]),
  buildAction: _remotePaymentCheckoutAction,
);

const ecommerceMarketplaceQueueActionRule = ActionRule(
  id: 'marketplace_queue_review',
  sequence: 16,
  capabilityGate: CapabilityGate.any([ProductCapability.marketplaceOrders]),
  buildAction: _marketplaceQueueAction,
);

const ecommerceSubscriptionRenewalActionRule = ActionRule(
  id: 'subscription_renewal_review',
  sequence: 17,
  capabilityGate: CapabilityGate.any([ProductCapability.subscriptionBilling]),
  buildAction: _subscriptionRenewalAction,
);

const ecommerceFulfillmentQueueActionRule = ActionRule(
  id: 'fulfillment_queue_review',
  sequence: 18,
  capabilityGate: CapabilityGate.any([
    ProductCapability.pickupDelivery,
    ProductCapability.shipping,
    ProductCapability.operationsReview,
  ]),
  buildAction: _fulfillmentQueueAction,
);

String ecommerceOperationalOrderRouteForCapabilities(
  Iterable<ProductCapability> capabilities,
) {
  final capabilitySet = capabilities.toSet();
  final hasMarketplace = capabilitySet.contains(
    ProductCapability.marketplaceOrders,
  );
  final hasPickupDelivery = capabilitySet.contains(
    ProductCapability.pickupDelivery,
  );
  final hasShipping = capabilitySet.contains(ProductCapability.shipping);
  final hasOperationsReview = capabilitySet.contains(
    ProductCapability.operationsReview,
  );

  if (hasMarketplace && !hasPickupDelivery && !hasShipping) {
    return Routes.marketplaceOrdersPath;
  }
  if (hasPickupDelivery && !hasMarketplace && !hasShipping) {
    return Routes.deliveryOrdersPath;
  }
  if (hasOperationsReview && !hasMarketplace && !hasPickupDelivery) {
    return Routes.wholesaleOrdersPath;
  }

  return Routes.ordersPath;
}

List<ActionRuleIssue> validateActionRules({
  required Iterable<ActionRule> rules,
  required Overview overview,
  required HealthSummary health,
  Iterable<ProductCapability>? capabilities,
}) {
  final ruleList = rules.toList(growable: false);
  final issues = <ActionRuleIssue>[];
  final seenRuleIds = <String>{};
  final activeCapabilities = capabilities?.toList(growable: false) ?? const [];
  final context = ActionContext(
    overview: overview,
    health: health,
    capabilities: activeCapabilities,
  );

  if (ruleList.isEmpty) {
    issues.add(
      const ActionRuleIssue(
        type: ActionRuleIssueType.emptyRegistry,
        message: 'Add at least one commerce workspace action rule.',
      ),
    );
    return List.unmodifiable(issues);
  }

  if (_activeRulesForCapabilities(ruleList, capabilities).isEmpty) {
    issues.add(
      const ActionRuleIssue(
        type: ActionRuleIssueType.noEnabledRules,
        message: 'Enable at least one commerce workspace action rule.',
      ),
    );
  }

  for (final rule in ruleList) {
    final ruleId = rule.id.trim();
    if (ruleId.isEmpty) {
      issues.add(
        const ActionRuleIssue(
          type: ActionRuleIssueType.blankRuleId,
          message: 'Commerce workspace action rules need a stable rule id.',
        ),
      );
    } else if (!seenRuleIds.add(ruleId)) {
      issues.add(
        ActionRuleIssue(
          type: ActionRuleIssueType.duplicateRuleId,
          ruleId: ruleId,
          message: 'Duplicate commerce workspace action rule id "$ruleId".',
        ),
      );
    }

    if (!rule.enabled) continue;
    if (capabilities != null && !rule.supportsCapabilities(capabilities)) {
      continue;
    }

    final Action? action;
    try {
      action = rule.actionFor(context);
    } catch (_) {
      issues.add(
        ActionRuleIssue(
          type: ActionRuleIssueType.actionBuildFailed,
          ruleId: ruleId.isEmpty ? null : ruleId,
          message:
              ruleId.isEmpty
                  ? 'A commerce workspace action rule failed to build an action.'
                  : 'Commerce workspace action rule "$ruleId" failed to build an action.',
        ),
      );
      continue;
    }

    if (action == null) continue;

    _validateAction(issues: issues, ruleId: ruleId, action: action);
  }

  return List.unmodifiable(issues);
}

List<Action> actionsFor({
  required Overview overview,
  required HealthSummary health,
  Iterable<ActionRule>? rules,
  Iterable<ProductCapability>? capabilities,
  int maxActions = 3,
}) {
  if (maxActions <= 0) return const [];

  final activeCapabilities = capabilities?.toList(growable: false) ?? const [];
  final context = ActionContext(
    overview: overview,
    health: health,
    capabilities: activeCapabilities,
  );
  final sortedRules =
      _activeRulesForCapabilities(
          rules ?? defaultActionRules,
          capabilities,
        ).toList()
        ..sort((a, b) {
          final sequenceComparison = a.sequence.compareTo(b.sequence);
          if (sequenceComparison != 0) return sequenceComparison;
          return a.id.compareTo(b.id);
        });

  final actions = <Action>[];
  final seenActionIds = <String>{};

  for (final rule in sortedRules) {
    try {
      _addAction(actions, seenActionIds, rule.actionFor(context));
    } catch (_) {
      continue;
    }
  }

  if (actions.isEmpty || _shouldOfferReadyActions(context)) {
    for (final readyAction in _readyActions) {
      if (capabilities != null &&
          !readyAction.capabilityGate.allows(capabilities)) {
        continue;
      }
      _addAction(
        actions,
        seenActionIds,
        readyAction.action.id == 'open_orders'
            ? _readyOrderWorkspaceActionFor(context)
            : readyAction.action,
      );
    }
  }

  actions.sort((a, b) {
    final priorityComparison = a.priority.compareTo(b.priority);
    if (priorityComparison != 0) return priorityComparison;
    return a.title.compareTo(b.title);
  });

  return List.unmodifiable(actions.take(maxActions));
}

Iterable<ActionRule> _activeRulesForCapabilities(
  Iterable<ActionRule> rules,
  Iterable<ProductCapability>? capabilities,
) {
  final enabledRules = rules.where((rule) => rule.enabled);
  if (capabilities == null) return enabledRules;

  return enabledRules.where((rule) => rule.supportsCapabilities(capabilities));
}

void _validateAction({
  required List<ActionRuleIssue> issues,
  required String ruleId,
  required Action action,
}) {
  final issueRuleId = ruleId.isEmpty ? null : ruleId;
  final actionId = action.id.trim();
  final routePath = action.routePath.trim();
  final issueActionId = actionId.isEmpty ? null : actionId;

  if (actionId.isEmpty) {
    issues.add(
      ActionRuleIssue(
        type: ActionRuleIssueType.blankActionId,
        ruleId: issueRuleId,
        message:
            ruleId.isEmpty
                ? 'Commerce workspace actions need a stable action id.'
                : 'Commerce workspace action rule "$ruleId" returned an action without an id.',
      ),
    );
  }

  if (action.title.trim().isEmpty) {
    issues.add(
      ActionRuleIssue(
        type: ActionRuleIssueType.blankActionTitle,
        ruleId: issueRuleId,
        actionId: issueActionId,
        message:
            actionId.isEmpty
                ? 'Commerce workspace actions need a visible title.'
                : 'Commerce workspace action "$actionId" needs a visible title.',
      ),
    );
  }

  if (action.description.trim().isEmpty) {
    issues.add(
      ActionRuleIssue(
        type: ActionRuleIssueType.blankActionDescription,
        ruleId: issueRuleId,
        actionId: issueActionId,
        message:
            actionId.isEmpty
                ? 'Commerce workspace actions need helper text.'
                : 'Commerce workspace action "$actionId" needs helper text.',
      ),
    );
  }

  if (action.actionLabel.trim().isEmpty) {
    issues.add(
      ActionRuleIssue(
        type: ActionRuleIssueType.blankActionLabel,
        ruleId: issueRuleId,
        actionId: issueActionId,
        message:
            actionId.isEmpty
                ? 'Commerce workspace actions need a button label.'
                : 'Commerce workspace action "$actionId" needs a button label.',
      ),
    );
  }

  if (routePath.isEmpty) {
    issues.add(
      ActionRuleIssue(
        type: ActionRuleIssueType.blankActionRoute,
        ruleId: issueRuleId,
        actionId: issueActionId,
        message:
            actionId.isEmpty
                ? 'Commerce workspace actions need a route path.'
                : 'Commerce workspace action "$actionId" needs a route path.',
      ),
    );
  } else if (!routePath.startsWith('/')) {
    final label =
        actionId.isEmpty ? (ruleId.isEmpty ? 'unknown' : ruleId) : actionId;
    issues.add(
      ActionRuleIssue(
        type: ActionRuleIssueType.invalidActionRoute,
        ruleId: issueRuleId,
        actionId: issueActionId,
        message:
            'Commerce workspace action "$label" route must start with "/".',
      ),
    );
  }
}

Action? _productProfileReviewAction(ActionContext context) {
  if (context.health.productProfileIssueCount == 0) return null;

  return Action(
    id: 'product_profile_review',
    title: 'Review product profiles',
    description:
        '${_count(context.health.productProfileIssueCount, 'profile issue')} can affect workspace configuration.',
    actionLabel: 'Review profiles',
    routePath: Routes.routePath,
    icon: Icons.view_quilt_outlined,
    tone: ActionTone.danger,
    priority: 5,
  );
}

Action? _moduleRegistryReviewAction(ActionContext context) {
  if (context.health.moduleIssueCount == 0) return null;

  return Action(
    id: 'module_registry_review',
    title: 'Review workspace modules',
    description:
        '${_count(context.health.moduleIssueCount, 'module issue')} can affect navigation.',
    actionLabel: 'Review modules',
    routePath: Routes.routePath,
    icon: Icons.extension_outlined,
    tone: ActionTone.danger,
    priority: 10,
  );
}

Action? _remotePaymentCheckoutAction(ActionContext context) {
  return Action(
    id: 'remote_payment_checkout',
    title:
        context.overview.cartLineCount == 0
            ? 'Start remote payment'
            : 'Send payment link',
    description:
        context.overview.cartLineCount == 0
            ? 'Prepare a link-ready checkout session for assisted selling.'
            : context.overview.cartLabel,
    actionLabel: 'Open payments',
    routePath: Routes.checkoutPath,
    icon: Icons.payments_outlined,
    tone: ActionTone.primary,
    priority: 15,
  );
}

Action? _marketplaceQueueAction(ActionContext context) {
  return Action(
    id: 'marketplace_queue_review',
    title: 'Review marketplace queue',
    description:
        context.overview.orderInsights.externalSettlementCount == 0
            ? 'Marketplace handoff and settlement workload is ready.'
            : '${_count(context.overview.orderInsights.externalSettlementCount, 'external settlement')} ${_needs(context.overview.orderInsights.externalSettlementCount)} review.',
    actionLabel: 'Open marketplace',
    routePath: Routes.marketplaceOrdersPath,
    icon: Icons.store_mall_directory_outlined,
    tone: ActionTone.secondary,
    priority: 16,
  );
}

Action? _subscriptionRenewalAction(ActionContext context) {
  return Action(
    id: 'subscription_renewal_review',
    title: 'Review subscription renewals',
    description:
        context.overview.orderInsights.orderCount == 0
            ? 'Renewal workspace is ready for recurring commerce.'
            : '${_count(context.overview.orderInsights.orderCount, 'renewal order')} ready for review.',
    actionLabel: 'Review renewals',
    routePath: Routes.ordersPath,
    icon: Icons.autorenew_outlined,
    tone: ActionTone.secondary,
    priority: 17,
  );
}

Action? _fulfillmentQueueAction(ActionContext context) {
  final attentionCount = context.overview.orderInsights.attentionOrderCount;

  return Action(
    id: 'fulfillment_queue_review',
    title: 'Review fulfillment queue',
    description:
        attentionCount == 0
            ? 'Pickup, delivery, and shipping handoff is clear.'
            : '${_count(attentionCount, 'order')} need fulfillment review.',
    actionLabel: 'Review queue',
    routePath: ecommerceOperationalOrderRouteForCapabilities(
      context.capabilities,
    ),
    icon: Icons.local_shipping_outlined,
    tone: attentionCount == 0 ? ActionTone.secondary : ActionTone.warning,
    priority: attentionCount == 0 ? 60 : 18,
  );
}

Action? _criticalOrderReviewAction(ActionContext context) {
  if (context.health.criticalOrderAttentionCount == 0) return null;

  return Action(
    id: 'critical_order_review',
    title: 'Resolve critical orders',
    description:
        '${_count(context.health.criticalOrderAttentionCount, 'order')} '
        '${_needs(context.health.criticalOrderAttentionCount)} fulfillment data.',
    actionLabel: 'Open orders',
    routePath: ecommerceOperationalOrderRouteForCapabilities(
      context.capabilities,
    ),
    icon: Icons.report_gmailerrorred_outlined,
    tone: ActionTone.danger,
    priority: 20,
  );
}

Action? _orderAttentionReviewAction(ActionContext context) {
  if (context.health.criticalOrderAttentionCount > 0 ||
      context.health.orderAttentionCount == 0) {
    return null;
  }

  return Action(
    id: 'order_attention_review',
    title: 'Review order queue',
    description:
        '${_count(context.health.orderAttentionCount, 'order')} '
        '${_needs(context.health.orderAttentionCount)} handoff review.',
    actionLabel: 'Open orders',
    routePath: ecommerceOperationalOrderRouteForCapabilities(
      context.capabilities,
    ),
    icon: Icons.receipt_long_outlined,
    tone: ActionTone.warning,
    priority: 30,
  );
}

Action? _channelPlaybookReviewAction(ActionContext context) {
  if (context.health.channelCoverageGapCount == 0) return null;

  return Action(
    id: 'channel_playbook_review',
    title: 'Review channel playbook',
    description:
        '${_count(context.health.channelCoverageGapCount, 'channel coverage gap')} '
        '${_needs(context.health.channelCoverageGapCount)} strategy review.',
    actionLabel: 'Review playbook',
    routePath: Routes.routePath,
    icon: Icons.route_outlined,
    tone: ActionTone.warning,
    priority: 35,
    focusSection: SectionSlot.channelStrategy,
  );
}

Action? _promisePolicyReviewAction(ActionContext context) {
  if (context.overview.promisePolicyIssueCount == 0) return null;

  return Action(
    id: 'promise_policy_review',
    title: 'Review promise policy',
    description:
        '${_count(context.overview.promisePolicyIssueCount, 'promise target')} '
        '${_needs(context.overview.promisePolicyIssueCount)} configuration.',
    actionLabel: 'Review policy',
    routePath: ecommerceOperationalOrderRouteForCapabilities(
      context.capabilities,
    ),
    icon: Icons.rule_folder_outlined,
    tone: ActionTone.warning,
    priority: 40,
  );
}

Action? _continueCheckoutAction(ActionContext context) {
  if (context.overview.cartLineCount == 0) return null;

  return Action(
    id: 'continue_checkout',
    title: 'Continue active checkout',
    description: context.overview.cartLabel,
    actionLabel: 'Open checkout',
    routePath: Routes.checkoutPath,
    icon: Icons.point_of_sale_outlined,
    tone: ActionTone.primary,
    priority: 50,
  );
}

const _readyActions = [
  _ReadyWorkspaceAction(
    capabilityGate: CapabilityGate.any([
      ProductCapability.storefrontCheckout,
      ProductCapability.marketplaceOrders,
      ProductCapability.remotePayment,
    ]),
    action: Action(
      id: 'start_checkout',
      title: 'Start ecommerce checkout',
      description: 'Create a storefront, marketplace, or remote order.',
      actionLabel: 'Open checkout',
      routePath: Routes.checkoutPath,
      icon: Icons.point_of_sale_outlined,
      tone: ActionTone.primary,
      priority: 80,
    ),
  ),
  _ReadyWorkspaceAction(
    capabilityGate: CapabilityGate.any([
      ProductCapability.marketplaceOrders,
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ]),
    action: Action(
      id: 'open_orders',
      title: 'Open order workspace',
      description: 'Review fulfillment, settlement, and channel workload.',
      actionLabel: 'Open orders',
      routePath: Routes.ordersPath,
      icon: Icons.receipt_long_outlined,
      tone: ActionTone.secondary,
      priority: 90,
    ),
  ),
];

class _ReadyWorkspaceAction {
  final CapabilityGate capabilityGate;
  final Action action;

  const _ReadyWorkspaceAction({
    required this.capabilityGate,
    required this.action,
  });
}

Action _readyOrderWorkspaceActionFor(ActionContext context) {
  return Action(
    id: 'open_orders',
    title: 'Open order workspace',
    description: 'Review fulfillment, settlement, and channel workload.',
    actionLabel: 'Open orders',
    routePath: ecommerceOperationalOrderRouteForCapabilities(
      context.capabilities,
    ),
    icon: Icons.receipt_long_outlined,
    tone: ActionTone.secondary,
    priority: 90,
  );
}

void _addAction(
  List<Action> actions,
  Set<String> seenActionIds,
  Action? action,
) {
  if (action == null) return;

  final actionId = action.id.trim();
  if (actionId.isEmpty ||
      action.title.trim().isEmpty ||
      action.description.trim().isEmpty ||
      action.actionLabel.trim().isEmpty ||
      !action.routePath.trim().startsWith('/') ||
      !seenActionIds.add(actionId)) {
    return;
  }

  actions.add(action);
}

bool _shouldOfferReadyActions(ActionContext context) {
  return context.health.isReady && context.overview.cartLineCount == 0;
}

String _count(int count, String singular) {
  return '$count ${count == 1 ? singular : '${singular}s'}';
}

String _needs(int count) {
  return count == 1 ? 'needs' : 'need';
}
