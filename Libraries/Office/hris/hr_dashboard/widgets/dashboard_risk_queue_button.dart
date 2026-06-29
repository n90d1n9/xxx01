import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_analytics.dart';
import 'dashboard_risk_severity_summary.dart';

class DashboardRiskQueueButton extends StatelessWidget {
  final DashboardRiskRollup rollup;

  const DashboardRiskQueueButton({super.key, required this.rollup});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showRiskQueue(context),
      icon: const Icon(Icons.format_list_bulleted_rounded),
      label: Text('View all ${rollup.workspaceCount} workspaces'),
    );
  }

  void _showRiskQueue(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _DashboardRiskQueueSheet(rollup: rollup),
    );
  }
}

class _DashboardRiskQueueSheet extends StatelessWidget {
  final DashboardRiskRollup rollup;

  const _DashboardRiskQueueSheet({required this.rollup});

  @override
  Widget build(BuildContext context) {
    final rankedItems = rollup.rankedItems;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Risk queue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ranked by total risk, then time-sensitive work.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: rankedItems.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _RiskQueueTile(
                      rank: index + 1,
                      item: rankedItems[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskQueueTile extends StatelessWidget {
  final int rank;
  final DashboardRiskItem item;

  const _RiskQueueTile({required this.rank, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = dashboardRiskSeverityColor(item.severity);

    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
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
                item.severity.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${item.totalRisks} risk / ${item.timeSensitiveRisks} due',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Open ${item.label} workspace',
            onPressed: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.go(item.route);
            },
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}
