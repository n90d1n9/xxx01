import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compensation_models.dart';

class CompensationSummaryGrid extends StatelessWidget {
  final CompensationSummary summary;

  const CompensationSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Reviews',
          value: '${summary.reviewItems}',
          detail: '${summary.pendingApprovals} pending approval',
          icon: Icons.payments_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Benefits',
          value: '${summary.benefitIssues}',
          detail: 'enrollment issues',
          icon: Icons.health_and_safety_outlined,
          color: const Color(0xFF0F766E),
        ),
        HrisSummaryMetric(
          title: 'Allowances',
          value: '${summary.allowanceWatch}',
          detail: 'budgets to review',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Incentives',
          value: '${summary.incentivePending}',
          detail: 'payouts active',
          icon: Icons.emoji_events_outlined,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }
}
