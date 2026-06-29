import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_urgency.dart';
import '../models/dashboard_action_urgency_summary.dart';
import 'dashboard_action_urgency_style.dart';

class DashboardActionUrgencyOverviewStrip extends StatelessWidget {
  final List<DashboardActionUrgencySummary> urgencies;
  final DashboardActionUrgencyTier? selectedUrgency;
  final ValueChanged<DashboardActionUrgencyTier?>? onChanged;

  const DashboardActionUrgencyOverviewStrip({
    super.key,
    required this.urgencies,
    this.selectedUrgency,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_outlined, color: HrisColors.primary),
              const SizedBox(width: 8),
              Text(
                'Urgency overview',
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
              final maxWidth = constraints.maxWidth;
              final columnCount =
                  maxWidth >= 560
                      ? 4
                      : maxWidth >= 360
                      ? 2
                      : 1;
              final tileWidth =
                  columnCount == 1
                      ? maxWidth
                      : (maxWidth - (spacing * (columnCount - 1))) /
                          columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final tier in DashboardActionUrgencyTier.values)
                    SizedBox(
                      width: tileWidth,
                      child: _UrgencyOverviewTile(
                        tier: tier,
                        count: _countFor(tier),
                        selected: selectedUrgency == tier,
                        onChanged: onChanged,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  int _countFor(DashboardActionUrgencyTier tier) {
    for (final urgency in urgencies) {
      if (urgency.tier == tier) {
        return urgency.totalCount;
      }
    }

    return 0;
  }
}

class _UrgencyOverviewTile extends StatelessWidget {
  final DashboardActionUrgencyTier tier;
  final int count;
  final bool selected;
  final ValueChanged<DashboardActionUrgencyTier?>? onChanged;

  const _UrgencyOverviewTile({
    required this.tier,
    required this.count,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = dashboardActionUrgencyLabel(tier);
    final color = dashboardActionUrgencyColor(tier);
    final enabled = count > 0 && onChanged != null;
    final tooltip =
        enabled
            ? selected
                ? 'Clear $label focus'
                : 'Focus $label'
            : count == 0
            ? 'No $label actions'
            : '$label actions';
    final textTheme = Theme.of(context).textTheme;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: enabled,
        enabled: enabled,
        selected: selected,
        child: Material(
          color: selected ? color.withValues(alpha: 0.08) : HrisColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected ? color : HrisColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: InkWell(
            onTap: enabled ? () => onChanged!(selected ? null : tier) : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 74),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: enabled ? 0.14 : 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        dashboardActionUrgencyIcon(tier),
                        size: 19,
                        color: enabled ? color : HrisColors.muted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  enabled || selected
                                      ? HrisColors.ink
                                      : HrisColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$count',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, size: 18, color: color),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
