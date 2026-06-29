import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_analytics.dart';

class DashboardInsightsPanel extends StatelessWidget {
  final DashboardInsightSummary summary;

  const DashboardInsightsPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.auto_graph_outlined,
      title: 'Executive pulse',
      subtitle: 'Signals distilled from the current dashboard period',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Dept avg',
              value: '${summary.averageDepartmentPerformance}%',
            ),
            HrisMetricStripItem(
              label: 'Total hires',
              value: '${summary.totalHires}',
            ),
            HrisMetricStripItem(
              label: 'Improved KPIs',
              value: '${summary.improvedMetricCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            children: [
              _InsightRow(
                icon: Icons.workspace_premium_outlined,
                label: 'Strongest department',
                value: summary.strongestDepartment,
              ),
              const SizedBox(height: 10),
              _InsightRow(
                icon: Icons.trending_up_outlined,
                label: 'Fastest improving',
                value: summary.fastestImprovingDepartment,
              ),
              const SizedBox(height: 10),
              _InsightRow(
                icon: Icons.person_add_alt_outlined,
                label: 'Peak hiring month',
                value: summary.peakHiringMonth,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: HrisColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: HrisColors.primary, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
