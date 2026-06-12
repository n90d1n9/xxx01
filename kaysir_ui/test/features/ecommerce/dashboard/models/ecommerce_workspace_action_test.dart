import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/capability.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/health.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/section_order.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  test('actionsFor exposes default ready actions', () {
    final actions = actionsFor(
      overview: _overview(),
      health: _health(_overview()),
    );

    expect(actions.map((action) => action.id), [
      'start_checkout',
      'open_orders',
    ]);
    expect(actions.first.actionLabel, 'Open checkout');
  });

  test('ecommerceOperationalOrderRouteForCapabilities picks narrow routes', () {
    expect(
      ecommerceOperationalOrderRouteForCapabilities(const [
        ProductCapability.marketplaceOrders,
      ]),
      Routes.marketplaceOrdersPath,
    );
    expect(
      ecommerceOperationalOrderRouteForCapabilities(const [
        ProductCapability.pickupDelivery,
      ]),
      Routes.deliveryOrdersPath,
    );
    expect(
      ecommerceOperationalOrderRouteForCapabilities(const [
        ProductCapability.operationsReview,
      ]),
      Routes.wholesaleOrdersPath,
    );
    expect(
      ecommerceOperationalOrderRouteForCapabilities(const [
        ProductCapability.marketplaceOrders,
        ProductCapability.shipping,
      ]),
      Routes.ordersPath,
    );
  });

  test('actionsFor prioritizes operational reviews', () {
    final overview = _overview(
      cartLines: 1,
      cartUnits: 2,
      policyIssues: 2,
      attentionOrders: 3,
    );

    final actions = actionsFor(overview: overview, health: _health(overview));

    expect(actions.map((action) => action.id), [
      'order_attention_review',
      'promise_policy_review',
      'continue_checkout',
    ]);
    expect(actions.first.description, '3 orders need handoff review.');
  });

  test('actionsFor surfaces channel playbook review', () {
    final overview = _overview(policyIssues: 1);
    final actions = actionsFor(
      overview: overview,
      health: _health(overview, channelCoverageGapCount: 2),
    );

    expect(actions.map((action) => action.id), [
      'channel_playbook_review',
      'promise_policy_review',
    ]);
    expect(actions.first.title, 'Review channel playbook');
    expect(actions.first.focusSection, SectionSlot.channelStrategy);
    expect(
      actions.first.description,
      '2 channel coverage gaps need strategy review.',
    );
    expect(actions.first.actionLabel, 'Review playbook');
  });

  test('actionsFor prioritizes module and critical issues', () {
    final overview = _overview(attentionOrders: 2, criticalOrders: 1);
    final actions = actionsFor(
      overview: overview,
      health: _health(
        overview,
        moduleIssues: const [
          ModuleIssue(
            type: ModuleIssueType.blankModuleId,
            message: 'Blank module id',
          ),
          ModuleIssue(
            type: ModuleIssueType.blankDestinationRoute,
            message: 'Blank route',
          ),
        ],
      ),
      maxActions: 2,
    );

    expect(actions.map((action) => action.id), [
      'module_registry_review',
      'critical_order_review',
    ]);
    expect(actions.first.description, '2 module issues can affect navigation.');
  });

  test('actionsFor prioritizes product profile issues', () {
    final overview = _overview(attentionOrders: 2, criticalOrders: 1);
    final actions = actionsFor(
      overview: overview,
      health: _health(overview, productProfileIssues: const [Object()]),
      maxActions: 2,
    );

    expect(actions.map((action) => action.id), [
      'product_profile_review',
      'critical_order_review',
    ]);
    expect(
      actions.first.description,
      '1 profile issue can affect workspace configuration.',
    );
  });

  test('actionsFor can return no actions', () {
    expect(
      actionsFor(
        overview: _overview(),
        health: _health(_overview()),
        maxActions: 0,
      ),
      isEmpty,
    );
  });

  test('actionsFor supports custom action rules', () {
    final overview = _overview();
    final actions = actionsFor(
      overview: overview,
      health: _health(overview),
      rules: [
        ActionRule(
          id: 'disabled',
          sequence: 1,
          enabled: false,
          buildAction:
              (_) => const Action(
                id: 'disabled',
                title: 'Disabled',
                description: 'Should not render.',
                actionLabel: 'Disabled',
                routePath: '/commerce/disabled',
                icon: Icons.block_outlined,
                tone: ActionTone.secondary,
                priority: 1,
              ),
        ),
        ActionRule(
          id: 'subscriptions',
          sequence: 5,
          buildAction:
              (_) => const Action(
                id: 'subscriptions',
                title: 'Review subscriptions',
                description: '3 renewal orders are ready to confirm.',
                actionLabel: 'Open renewals',
                routePath: '/commerce/subscriptions',
                icon: Icons.autorenew_outlined,
                tone: ActionTone.warning,
                priority: 5,
              ),
        ),
        ...defaultActionRules,
      ],
    );

    expect(actions.map((action) => action.id), [
      'subscriptions',
      'start_checkout',
      'open_orders',
    ]);
  });

  test('actionsFor keeps the first duplicate action id', () {
    final overview = _overview();
    final actions = actionsFor(
      overview: overview,
      health: _health(overview),
      rules: [
        ActionRule(
          id: 'custom_checkout',
          sequence: 1,
          buildAction:
              (_) => const Action(
                id: 'start_checkout',
                title: 'Custom checkout',
                description: 'Custom checkout route.',
                actionLabel: 'Open custom checkout',
                routePath: '/commerce/custom-checkout',
                icon: Icons.storefront_outlined,
                tone: ActionTone.primary,
                priority: 1,
              ),
        ),
        ...defaultActionRules,
      ],
    );

    expect(actions.first.id, 'start_checkout');
    expect(actions.first.routePath, '/commerce/custom-checkout');
    expect(
      actions.where((action) => action.id == 'start_checkout'),
      hasLength(1),
    );
  });

  test('actionsFor filters rules by capabilities', () {
    final overview = _overview();
    final actions = actionsFor(
      overview: overview,
      health: _health(overview),
      capabilities: const [ProductCapability.subscriptionBilling],
      rules: [
        ActionRule(
          id: 'subscriptions',
          sequence: 1,
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
        ),
        ActionRule(
          id: 'remote_pay',
          sequence: 2,
          capabilityGate: const CapabilityGate.any([
            ProductCapability.remotePayment,
          ]),
          buildAction:
              (_) => const Action(
                id: 'remote_pay',
                title: 'Collect remote payment',
                description: 'Payment links are ready to send.',
                actionLabel: 'Open payments',
                routePath: '/commerce/payments',
                icon: Icons.payments_outlined,
                tone: ActionTone.primary,
                priority: 10,
              ),
        ),
      ],
    );

    expect(actions.map((action) => action.id), ['subscriptions']);
  });

  test('actionsFor filters ready actions by capabilities', () {
    final overview = _overview();

    expect(
      actionsFor(
        overview: overview,
        health: _health(overview),
        capabilities: const [ProductCapability.operationsReview],
      ).single,
      isA<Action>()
          .having((action) => action.id, 'id', 'open_orders')
          .having(
            (action) => action.routePath,
            'routePath',
            Routes.wholesaleOrdersPath,
          ),
    );
    expect(
      actionsFor(
        overview: overview,
        health: _health(overview),
        capabilities: const [ProductCapability.subscriptionBilling],
      ),
      isEmpty,
    );
  });

  test('specific action rules deep-link to specialized order workspaces', () {
    final overview = _overview(attentionOrders: 2);
    final health = _health(overview);

    expect(
      actionsFor(
        overview: overview,
        health: health,
        rules: [ecommerceMarketplaceQueueActionRule],
        capabilities: const [ProductCapability.marketplaceOrders],
      ).single.routePath,
      Routes.marketplaceOrdersPath,
    );
    expect(
      actionsFor(
        overview: overview,
        health: health,
        rules: [ecommerceFulfillmentQueueActionRule],
        capabilities: const [ProductCapability.pickupDelivery],
      ).single.routePath,
      Routes.deliveryOrdersPath,
    );
  });

  test('validateActionRules accepts the default registry', () {
    final overview = _overview();
    final issues = validateActionRules(
      overview: overview,
      health: _health(overview),
      rules: defaultActionRules,
    );

    expect(issues, isEmpty);
  });

  test('validateActionRules catches registry issues', () {
    final overview = _overview();
    final issues = validateActionRules(
      overview: overview,
      health: _health(overview),
      rules: [
        ActionRule(
          id: '',
          sequence: 1,
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
        ActionRule(id: 'duplicate', sequence: 2, buildAction: (_) => null),
        ActionRule(
          id: 'duplicate',
          sequence: 3,
          buildAction: (_) => throw StateError('bad action'),
        ),
      ],
    );

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        ActionRuleIssueType.blankRuleId,
        ActionRuleIssueType.blankActionId,
        ActionRuleIssueType.blankActionTitle,
        ActionRuleIssueType.blankActionDescription,
        ActionRuleIssueType.blankActionLabel,
        ActionRuleIssueType.invalidActionRoute,
        ActionRuleIssueType.duplicateRuleId,
        ActionRuleIssueType.actionBuildFailed,
      ]),
    );
  });

  test('validateActionRules catches empty and disabled registries', () {
    final overview = _overview();
    final health = _health(overview);

    expect(
      validateActionRules(
        overview: overview,
        health: health,
        rules: const [],
      ).single.type,
      ActionRuleIssueType.emptyRegistry,
    );
    expect(
      validateActionRules(
        overview: overview,
        health: health,
        rules: [
          ActionRule(id: 'disabled', enabled: false, buildAction: (_) => null),
        ],
      ).map((issue) => issue.type),
      contains(ActionRuleIssueType.noEnabledRules),
    );
    expect(
      validateActionRules(
        overview: overview,
        health: health,
        capabilities: const [ProductCapability.storefrontCheckout],
        rules: [
          ActionRule(
            id: 'subscriptions',
            capabilityGate: const CapabilityGate.any([
              ProductCapability.subscriptionBilling,
            ]),
            buildAction: (_) => null,
          ),
        ],
      ).map((issue) => issue.type),
      contains(ActionRuleIssueType.noEnabledRules),
    );
  });

  test('actionsFor skips invalid action output', () {
    final overview = _overview();
    final actions = actionsFor(
      overview: overview,
      health: _health(overview),
      rules: [
        ActionRule(
          id: 'bad',
          sequence: 1,
          buildAction:
              (_) => const Action(
                id: 'bad',
                title: 'Bad action',
                description: '',
                actionLabel: 'Open bad',
                routePath: 'commerce/bad',
                icon: Icons.block_outlined,
                tone: ActionTone.warning,
                priority: 1,
              ),
        ),
        ...defaultActionRules,
      ],
    );

    expect(actions.map((action) => action.id), [
      'start_checkout',
      'open_orders',
    ]);
  });
}

HealthSummary _health(
  Overview overview, {
  List<Object> productProfileIssues = const [],
  List<ModuleIssue> moduleIssues = const [],
  int channelCoverageGapCount = 0,
}) {
  return HealthSummary.fromWorkspace(
    overview: overview,
    productProfileIssues: productProfileIssues,
    moduleIssues: moduleIssues,
    channelCoverageGapCount: channelCoverageGapCount,
  );
}

Overview _overview({
  int cartLines = 0,
  int cartUnits = 0,
  int policyIssues = 0,
  int attentionOrders = 0,
  int criticalOrders = 0,
}) {
  return Overview(
    orderInsights: OrderInsights(
      orderCount: attentionOrders,
      revenue: 0,
      averageOrderValue: 0,
      paidOrderCount: 0,
      externalSettlementCount: 0,
      attentionOrderCount: attentionOrders,
      criticalAttentionOrderCount: criticalOrders,
      channelBreakdown: const [],
      fulfillmentBreakdown: const [],
    ),
    cartLineCount: cartLines,
    cartUnitCount: cartUnits,
    cartTotal: 0,
    promisePolicyIssueCount: policyIssues,
  );
}
