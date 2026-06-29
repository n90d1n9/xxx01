import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_analytics.dart';
import 'dashboard_risk_queue_button.dart';
import 'dashboard_risk_severity_summary.dart';

class DashboardRiskRollupPanel extends StatelessWidget {
  final DashboardRiskRollup rollup;

  const DashboardRiskRollupPanel({super.key, required this.rollup});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.warning_amber_outlined,
      title: 'Risk command',
      subtitle: 'Cross-workspace risk pressure and urgent deadlines',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Total risks',
              value: '${rollup.totalRisks}',
            ),
            HrisMetricStripItem(
              label: 'Time-sensitive',
              value: '${rollup.timeSensitiveRisks}',
            ),
            HrisMetricStripItem(
              label: 'Top workspace',
              value: rollup.highestRiskWorkspace,
            ),
          ],
        ),
        DashboardRiskSeveritySummary(rollup: rollup),
        ...rollup.topItems.map((item) => _RiskRow(item: item)),
        Align(
          alignment: Alignment.centerLeft,
          child: DashboardRiskQueueButton(rollup: rollup),
        ),
      ],
    );
  }
}

class _RiskRow extends StatelessWidget {
  final DashboardRiskItem item;

  const _RiskRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final severityColor = dashboardRiskSeverityColor(item.severity);

    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.priority_high_rounded,
              color: severityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SeverityPill(
                      severity: item.severity,
                      color: severityColor,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.leadingSignal,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.totalRisks}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${item.timeSensitiveRisks} due',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Open ${item.label} workspace',
            onPressed: () => context.go(item.route),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  final DashboardRiskSeverity severity;
  final Color color;

  const _SeverityPill({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        severity.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
