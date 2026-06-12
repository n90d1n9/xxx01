import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/health.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  test('HealthSummary reports ready workspace state', () {
    final health = HealthSummary.fromWorkspace(
      overview: _overview(),
      moduleIssues: const [],
    );

    expect(health.tone, HealthTone.success);
    expect(health.isReady, isTrue);
    expect(health.title, 'Ready to sell');
    expect(
      health.message,
      'Modules, promise policy, and order queue are clear.',
    );
    expect(health.signals.map((signal) => signal.value), [
      'Ready',
      'Ready',
      'Ready',
      'Ready',
      'Ready',
      'Clear',
    ]);
  });

  test('HealthSummary flags channel coverage review', () {
    final health = HealthSummary.fromWorkspace(
      overview: _overview(),
      moduleIssues: const [],
      channelCoverageGapCount: 2,
    );

    expect(health.tone, HealthTone.warning);
    expect(health.channelCoverageGapCount, 2);
    expect(health.title, 'Operational review needed');
    expect(health.message, '2 channel coverage gaps need playbook review.');
    expect(
      health.signals
          .singleWhere((signal) => signal.id == 'channel_coverage')
          .value,
      '2 gaps',
    );
    expect(
      health.signals
          .singleWhere((signal) => signal.id == 'channel_coverage')
          .detail,
      'Playbook needs review',
    );
  });

  test('HealthSummary flags policy and order review', () {
    final health = HealthSummary.fromWorkspace(
      overview: _overview(policyIssues: 2, attentionOrders: 3),
      moduleIssues: const [],
    );

    expect(health.tone, HealthTone.warning);
    expect(health.title, 'Operational review needed');
    expect(
      health.message,
      '2 promise policy issues and 3 order reviews need attention.',
    );
    expect(
      health.signals
          .singleWhere((signal) => signal.id == 'promise_policy')
          .value,
      '2 issues',
    );
    expect(
      health.signals
          .singleWhere((signal) => signal.id == 'order_attention')
          .value,
      '3 reviews',
    );
  });

  test('HealthSummary prioritizes critical signals', () {
    final health = HealthSummary.fromWorkspace(
      overview: _overview(attentionOrders: 2, criticalOrders: 1),
      moduleIssues: const [
        ModuleIssue(
          type: ModuleIssueType.blankModuleId,
          message: 'Blank module id',
        ),
      ],
    );

    expect(health.tone, HealthTone.danger);
    expect(health.title, 'Critical workspace attention');
    expect(health.message, '1 module registry issue needs cleanup.');
    expect(
      health.signals.singleWhere((signal) => signal.id == 'modules').value,
      '1 issue',
    );
    expect(
      health.signals
          .singleWhere((signal) => signal.id == 'order_attention')
          .value,
      '1 critical order',
    );
  });

  test('HealthSummary flags product profile issues', () {
    final health = HealthSummary.fromWorkspace(
      overview: _overview(attentionOrders: 2, criticalOrders: 1),
      productProfileIssues: const [Object(), Object()],
      moduleIssues: const [],
    );

    expect(health.tone, HealthTone.danger);
    expect(health.productProfileIssueCount, 2);
    expect(health.message, '2 product profile issues need cleanup.');
    expect(
      health.signals.singleWhere((signal) => signal.id == 'profiles').value,
      '2 issues',
    );
  });

  test('HealthSummary flags action registry issues', () {
    final health = HealthSummary.fromWorkspace(
      overview: _overview(attentionOrders: 2, criticalOrders: 1),
      moduleIssues: const [],
      actionRuleIssues: const [Object(), Object()],
    );

    expect(health.tone, HealthTone.danger);
    expect(health.actionRuleIssueCount, 2);
    expect(health.message, '2 action registry issues need cleanup.');
    expect(
      health.signals.singleWhere((signal) => signal.id == 'actions').value,
      '2 issues',
    );
  });
}

Overview _overview({
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
    cartLineCount: 0,
    cartUnitCount: 0,
    cartTotal: 0,
    promisePolicyIssueCount: policyIssues,
  );
}
