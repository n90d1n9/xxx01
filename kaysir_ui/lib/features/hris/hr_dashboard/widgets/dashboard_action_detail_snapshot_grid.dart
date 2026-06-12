import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_detail_snapshot.dart';
import '../models/dashboard_action_status.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_action_urgency.dart';
import 'dashboard_action_style.dart';
import 'dashboard_action_urgency_style.dart';

class DashboardActionDetailSnapshotGrid extends StatelessWidget {
  final DashboardActionDetailSnapshot snapshot;

  const DashboardActionDetailSnapshotGrid({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.dashboard_customize_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Decision snapshot',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final columnCount = constraints.maxWidth >= 520 ? 2 : 1;
              final tileWidth =
                  columnCount == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final item in snapshot.items)
                    SizedBox(
                      width: tileWidth,
                      child: _SnapshotTile(item: item),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  final DashboardActionDetailSnapshotItem item;

  const _SnapshotTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(item);

    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconFor(item), color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(DashboardActionDetailSnapshotItem item) {
    return switch (item.kind) {
      DashboardActionDetailSnapshotKind.owner => Icons.account_circle_outlined,
      DashboardActionDetailSnapshotKind.urgency => dashboardActionUrgencyIcon(
        item.urgency ?? DashboardActionUrgencyTier.planned,
      ),
      DashboardActionDetailSnapshotKind.status => Icons.bolt_outlined,
      DashboardActionDetailSnapshotKind.signal => Icons.insights_outlined,
    };
  }

  Color _colorFor(DashboardActionDetailSnapshotItem item) {
    return switch (item.kind) {
      DashboardActionDetailSnapshotKind.owner => HrisColors.primary,
      DashboardActionDetailSnapshotKind.urgency => dashboardActionUrgencyColor(
        item.urgency ?? DashboardActionUrgencyTier.planned,
      ),
      DashboardActionDetailSnapshotKind.status => dashboardActionStatusColor(
        item.status ?? DashboardActionStatus.open,
      ),
      DashboardActionDetailSnapshotKind.signal => dashboardActionPriorityColor(
        item.priority ?? DashboardActionPriority.medium,
      ),
    };
  }
}
