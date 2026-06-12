import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_analytics.dart';

class DashboardRiskSeveritySummary extends StatelessWidget {
  final DashboardRiskRollup rollup;

  const DashboardRiskSeveritySummary({super.key, required this.rollup});

  @override
  Widget build(BuildContext context) {
    final items = [
      _RiskSeveritySummaryItem(
        severity: DashboardRiskSeverity.critical,
        count: rollup.criticalWorkspaceCount,
      ),
      _RiskSeveritySummaryItem(
        severity: DashboardRiskSeverity.elevated,
        count: rollup.elevatedWorkspaceCount,
      ),
      _RiskSeveritySummaryItem(
        severity: DashboardRiskSeverity.stable,
        count: rollup.stableWorkspaceCount,
      ),
    ];

    return Row(
      children:
          items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: item == items.last ? 0 : 8),
                    child: _RiskSeveritySummaryTile(item: item),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _RiskSeveritySummaryTile extends StatelessWidget {
  final _RiskSeveritySummaryItem item;

  const _RiskSeveritySummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = dashboardRiskSeverityColor(item.severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.severity.label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${item.count}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskSeveritySummaryItem {
  final DashboardRiskSeverity severity;
  final int count;

  const _RiskSeveritySummaryItem({required this.severity, required this.count});
}

Color dashboardRiskSeverityColor(DashboardRiskSeverity severity) {
  switch (severity) {
    case DashboardRiskSeverity.stable:
      return Colors.green.shade700;
    case DashboardRiskSeverity.elevated:
      return Colors.orange.shade800;
    case DashboardRiskSeverity.critical:
      return Colors.red.shade700;
  }
}
