import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_inline_notice.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_fulfillment_promise_policy.dart';

class OrderFulfillmentPromisePolicyNotice extends StatelessWidget {
  final List<OrderFulfillmentPromisePolicyIssue> issues;
  final int maxVisibleIssues;

  const OrderFulfillmentPromisePolicyNotice({
    super.key,
    required this.issues,
    this.maxVisibleIssues = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) return const SizedBox.shrink();

    final visibleIssues = issues.take(maxVisibleIssues).toList(growable: false);
    final hiddenCount = issues.length - visibleIssues.length;

    return POSInlineNotice(
      tone: POSInlineNoticeTone.danger,
      icon: Icons.rule_folder_outlined,
      title: 'Promise policy needs review',
      message:
          '${issues.length} ${_noun(issues.length, 'configuration issue')} can affect fulfillment targets for this workspace.',
      footer: Wrap(
        spacing: POSUiTokens.gap,
        runSpacing: POSUiTokens.gap,
        children: [
          ...visibleIssues.map(
            (issue) => _PromisePolicyIssuePill(
              key: ValueKey('promise_policy_issue_${issue.type.name}'),
              issue: issue,
            ),
          ),
          if (hiddenCount > 0)
            _PromisePolicyOverflowPill(hiddenCount: hiddenCount),
        ],
      ),
    );
  }
}

class _PromisePolicyIssuePill extends StatelessWidget {
  final OrderFulfillmentPromisePolicyIssue issue;

  const _PromisePolicyIssuePill({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 15, color: theme.colorScheme.error),
          const SizedBox(width: POSUiTokens.gap),
          Flexible(
            child: Text(
              issue.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromisePolicyOverflowPill extends StatelessWidget {
  final int hiddenCount;

  const _PromisePolicyOverflowPill({required this.hiddenCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        '+$hiddenCount more',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _noun(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
