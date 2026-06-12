import 'module.dart';
import 'overview.dart';

enum HealthTone { success, warning, danger }

class HealthSignal {
  final String id;
  final String label;
  final String value;
  final String detail;
  final HealthTone tone;

  const HealthSignal({
    required this.id,
    required this.label,
    required this.value,
    required this.detail,
    required this.tone,
  });
}

class HealthSummary {
  final HealthTone tone;
  final String title;
  final String message;
  final int productProfileIssueCount;
  final int moduleIssueCount;
  final int actionRuleIssueCount;
  final int channelCoverageGapCount;
  final int promisePolicyIssueCount;
  final int orderAttentionCount;
  final int criticalOrderAttentionCount;
  final List<HealthSignal> signals;

  const HealthSummary({
    required this.tone,
    required this.title,
    required this.message,
    this.productProfileIssueCount = 0,
    required this.moduleIssueCount,
    required this.actionRuleIssueCount,
    this.channelCoverageGapCount = 0,
    required this.promisePolicyIssueCount,
    required this.orderAttentionCount,
    required this.criticalOrderAttentionCount,
    required this.signals,
  });

  factory HealthSummary.fromWorkspace({
    required Overview overview,
    Iterable<Object> productProfileIssues = const [],
    required Iterable<ModuleIssue> moduleIssues,
    Iterable<Object> actionRuleIssues = const [],
    int channelCoverageGapCount = 0,
  }) {
    final productProfileIssueCount = productProfileIssues.length;
    final moduleIssueCount = moduleIssues.length;
    final actionRuleIssueCount = actionRuleIssues.length;
    final promisePolicyIssueCount = overview.promisePolicyIssueCount;
    final orderAttentionCount = overview.orderInsights.attentionOrderCount;
    final criticalOrderAttentionCount =
        overview.orderInsights.criticalAttentionOrderCount;
    final tone = _resolveTone(
      productProfileIssueCount: productProfileIssueCount,
      moduleIssueCount: moduleIssueCount,
      actionRuleIssueCount: actionRuleIssueCount,
      channelCoverageGapCount: channelCoverageGapCount,
      promisePolicyIssueCount: promisePolicyIssueCount,
      orderAttentionCount: orderAttentionCount,
      criticalOrderAttentionCount: criticalOrderAttentionCount,
    );

    return HealthSummary(
      tone: tone,
      title: _titleFor(tone),
      message: _messageFor(
        productProfileIssueCount: productProfileIssueCount,
        moduleIssueCount: moduleIssueCount,
        actionRuleIssueCount: actionRuleIssueCount,
        channelCoverageGapCount: channelCoverageGapCount,
        promisePolicyIssueCount: promisePolicyIssueCount,
        orderAttentionCount: orderAttentionCount,
        criticalOrderAttentionCount: criticalOrderAttentionCount,
      ),
      productProfileIssueCount: productProfileIssueCount,
      moduleIssueCount: moduleIssueCount,
      actionRuleIssueCount: actionRuleIssueCount,
      channelCoverageGapCount: channelCoverageGapCount,
      promisePolicyIssueCount: promisePolicyIssueCount,
      orderAttentionCount: orderAttentionCount,
      criticalOrderAttentionCount: criticalOrderAttentionCount,
      signals: List.unmodifiable([
        _productProfilesSignal(productProfileIssueCount),
        _moduleSignal(moduleIssueCount),
        _actionRulesSignal(actionRuleIssueCount),
        _channelCoverageSignal(channelCoverageGapCount),
        _promisePolicySignal(promisePolicyIssueCount),
        _orderAttentionSignal(
          orderAttentionCount: orderAttentionCount,
          criticalOrderAttentionCount: criticalOrderAttentionCount,
        ),
      ]),
    );
  }

  bool get isReady => tone == HealthTone.success;
}

HealthTone _resolveTone({
  required int productProfileIssueCount,
  required int moduleIssueCount,
  required int actionRuleIssueCount,
  required int channelCoverageGapCount,
  required int promisePolicyIssueCount,
  required int orderAttentionCount,
  required int criticalOrderAttentionCount,
}) {
  if (productProfileIssueCount > 0 ||
      moduleIssueCount > 0 ||
      actionRuleIssueCount > 0 ||
      criticalOrderAttentionCount > 0) {
    return HealthTone.danger;
  }
  if (channelCoverageGapCount > 0 ||
      promisePolicyIssueCount > 0 ||
      orderAttentionCount > 0) {
    return HealthTone.warning;
  }
  return HealthTone.success;
}

String _titleFor(HealthTone tone) {
  return switch (tone) {
    HealthTone.success => 'Ready to sell',
    HealthTone.warning => 'Operational review needed',
    HealthTone.danger => 'Critical workspace attention',
  };
}

String _messageFor({
  required int productProfileIssueCount,
  required int moduleIssueCount,
  required int actionRuleIssueCount,
  required int channelCoverageGapCount,
  required int promisePolicyIssueCount,
  required int orderAttentionCount,
  required int criticalOrderAttentionCount,
}) {
  if (productProfileIssueCount > 0) {
    return '${_count(productProfileIssueCount, 'product profile issue')} '
        '${_needs(productProfileIssueCount)} cleanup.';
  }
  if (moduleIssueCount > 0) {
    return '${_count(moduleIssueCount, 'module registry issue')} '
        '${_needs(moduleIssueCount)} cleanup.';
  }
  if (actionRuleIssueCount > 0) {
    return '${_count(actionRuleIssueCount, 'action registry issue')} '
        '${_needs(actionRuleIssueCount)} cleanup.';
  }
  if (criticalOrderAttentionCount > 0) {
    return '${_count(criticalOrderAttentionCount, 'high-priority order')} '
        '${_needs(criticalOrderAttentionCount)} fulfillment data.';
  }
  if (channelCoverageGapCount > 0) {
    return '${_count(channelCoverageGapCount, 'channel coverage gap')} '
        '${_needs(channelCoverageGapCount)} playbook review.';
  }
  if (promisePolicyIssueCount > 0 && orderAttentionCount > 0) {
    return '${_count(promisePolicyIssueCount, 'promise policy issue')} and '
        '${_count(orderAttentionCount, 'order review')} need attention.';
  }
  if (promisePolicyIssueCount > 0) {
    return '${_count(promisePolicyIssueCount, 'promise policy issue')} '
        '${_needs(promisePolicyIssueCount)} review.';
  }
  if (orderAttentionCount > 0) {
    return '${_count(orderAttentionCount, 'order')} '
        '${_needs(orderAttentionCount)} review before handoff.';
  }
  return 'Modules, promise policy, and order queue are clear.';
}

HealthSignal _productProfilesSignal(int issueCount) {
  return HealthSignal(
    id: 'profiles',
    label: 'Profiles',
    value: issueCount == 0 ? 'Ready' : _count(issueCount, 'issue'),
    detail:
        issueCount == 0
            ? 'Product profile registry healthy'
            : 'Profiles need cleanup',
    tone: issueCount == 0 ? HealthTone.success : HealthTone.danger,
  );
}

HealthSignal _moduleSignal(int issueCount) {
  return HealthSignal(
    id: 'modules',
    label: 'Modules',
    value: issueCount == 0 ? 'Ready' : _count(issueCount, 'issue'),
    detail:
        issueCount == 0
            ? 'Navigation registry healthy'
            : 'Registry needs cleanup',
    tone: issueCount == 0 ? HealthTone.success : HealthTone.danger,
  );
}

HealthSignal _actionRulesSignal(int issueCount) {
  return HealthSignal(
    id: 'actions',
    label: 'Priority actions',
    value: issueCount == 0 ? 'Ready' : _count(issueCount, 'issue'),
    detail:
        issueCount == 0
            ? 'Action registry healthy'
            : 'Action rules need cleanup',
    tone: issueCount == 0 ? HealthTone.success : HealthTone.danger,
  );
}

HealthSignal _channelCoverageSignal(int gapCount) {
  return HealthSignal(
    id: 'channel_coverage',
    label: 'Channel coverage',
    value: gapCount == 0 ? 'Ready' : _count(gapCount, 'gap'),
    detail:
        gapCount == 0 ? 'Channel playbook healthy' : 'Playbook needs review',
    tone: gapCount == 0 ? HealthTone.success : HealthTone.warning,
  );
}

HealthSignal _promisePolicySignal(int issueCount) {
  return HealthSignal(
    id: 'promise_policy',
    label: 'Promise policy',
    value: issueCount == 0 ? 'Ready' : _count(issueCount, 'issue'),
    detail:
        issueCount == 0
            ? 'Promise targets valid'
            : 'Targets need configuration',
    tone: issueCount == 0 ? HealthTone.success : HealthTone.warning,
  );
}

HealthSignal _orderAttentionSignal({
  required int orderAttentionCount,
  required int criticalOrderAttentionCount,
}) {
  final hasCritical = criticalOrderAttentionCount > 0;
  final hasAttention = orderAttentionCount > 0;

  return HealthSignal(
    id: 'order_attention',
    label: 'Order attention',
    value:
        hasCritical
            ? _count(criticalOrderAttentionCount, 'critical order')
            : hasAttention
            ? _count(orderAttentionCount, 'review')
            : 'Clear',
    detail:
        hasCritical
            ? '${_count(orderAttentionCount, 'total review')} in queue'
            : hasAttention
            ? 'Fulfillment queue needs action'
            : 'No actionable orders',
    tone:
        hasCritical
            ? HealthTone.danger
            : hasAttention
            ? HealthTone.warning
            : HealthTone.success,
  );
}

String _count(int count, String singular) {
  return '$count ${count == 1 ? singular : '${singular}s'}';
}

String _needs(int count) {
  return count == 1 ? 'needs' : 'need';
}
