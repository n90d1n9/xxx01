import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/workforce_planning_models.dart';
import 'workforce_planning_status_styles.dart';

class HeadcountPlanPanel extends StatelessWidget {
  final List<HeadcountPlan> plans;

  const HeadcountPlanPanel({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Headcount Plan',
      subtitle: '${plans.length} departments',
      emptyMessage: 'No matching headcount plans',
      children: plans.map((plan) => _HeadcountTile(plan: plan)).toList(),
    );
  }
}

class _HeadcountTile extends StatelessWidget {
  final HeadcountPlan plan;

  const _HeadcountTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final statusColor = planStatusColor(plan.status);
    final currency = NumberFormat.compactCurrency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.department,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: planStatusLabel(plan.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Owner: ${plan.ownerName} - ${currency.format(plan.budget)} budget',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Planned', value: '${plan.planned}'),
              HrisMetricStripItem(label: 'Actual', value: '${plan.actual}'),
              HrisMetricStripItem(label: 'Forecast', value: '${plan.forecast}'),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.forecastRate,
            color: statusColor,
            label:
                '${(plan.forecastRate * 100).toStringAsFixed(0)}% forecast coverage',
          ),
        ],
      ),
    );
  }
}
