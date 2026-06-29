import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/workforce_planning_models.dart';

class WorkforcePlanningSummaryGrid extends StatelessWidget {
  final WorkforcePlanningSummary summary;

  const WorkforcePlanningSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.compactCurrency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Actual HC',
          value: '${summary.totalActual}',
          detail: '${summary.totalPlanned} planned',
          icon: Icons.groups_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Open roles',
          value: '${summary.openPositions}',
          detail: '${summary.pendingApprovals} pending approvals',
          icon: Icons.person_add_alt_outlined,
          color: const Color(0xFF0F766E),
        ),
        HrisSummaryMetric(
          title: 'Forecast gap',
          value: '${summary.forecastGap}',
          detail: 'positions below plan',
          icon: Icons.trending_down_outlined,
          color: const Color(0xFFB45309),
        ),
        HrisSummaryMetric(
          title: 'Risk budget',
          value: currency.format(summary.budgetAtRisk),
          detail: '${summary.highRisks} high capacity risks',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFFBE123C),
        ),
      ],
    );
  }
}
