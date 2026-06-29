import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_coverage_models.dart';
import 'holiday_formatters.dart';

class HolidayCoveragePlannerPanel extends StatelessWidget {
  final HolidayCoveragePlan plan;

  const HolidayCoveragePlannerPanel({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.health_and_safety_outlined,
      title: 'Coverage planner',
      subtitle: '${plan.horizonDays}-day readiness view',
      children: [
        _CoverageReadinessSurface(plan: plan),
        for (final item in plan.items) _CoveragePlanTile(item: item),
      ],
    );
  }
}

class _CoverageReadinessSurface extends StatelessWidget {
  final HolidayCoveragePlan plan;

  const _CoverageReadinessSurface({required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final score = _ScoreBadge(plan: plan);
          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CoverageStat(
                icon: Icons.priority_high_outlined,
                label: 'Urgent',
                value: '${plan.urgentCount}',
              ),
              _CoverageStat(
                icon: Icons.assignment_outlined,
                label: 'Needs plan',
                value: '${plan.coverageRequiredCount}',
              ),
              _CoverageStat(
                icon: Icons.event_repeat_outlined,
                label: 'Observed shifts',
                value: '${plan.observedShiftCount}',
              ),
              _CoverageStat(
                icon: Icons.tune_outlined,
                label: 'Custom',
                value: '${plan.customCount}',
              ),
            ],
          );

          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [score, const SizedBox(height: 14), stats],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              score,
              const SizedBox(width: 20),
              Expanded(child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final HolidayCoveragePlan plan;

  const _ScoreBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = _readinessColor(plan.readinessScore);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${plan.readinessScore}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.readinessLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Coverage readiness',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _CoverageStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CoverageStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 126),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: HrisColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoveragePlanTile extends StatelessWidget {
  final HolidayCoveragePlanItem item;

  const _CoveragePlanTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final holiday = item.holiday;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                holiday.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              HrisStatusPill(
                label: item.priority.label,
                color: _priorityColor(item.priority),
              ),
              HrisStatusPill(label: item.signal, color: HrisColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _CoverageMeta(
                icon: Icons.today_outlined,
                label: formatHolidayDate(holiday.effectiveDate),
              ),
              _CoverageMeta(
                icon: Icons.timelapse_outlined,
                label: _formatDaysUntil(item.daysUntil),
              ),
              _CoverageMeta(icon: Icons.groups_outlined, label: holiday.scope),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.checklist_rtl_outlined,
                color: HrisColors.muted,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.action,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoverageMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CoverageMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: HrisColors.muted, size: 16),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

Color _readinessColor(int score) {
  if (score >= 90) return Colors.green.shade700;
  if (score >= 70) return Colors.orange.shade700;
  return Colors.red.shade700;
}

Color _priorityColor(HolidayCoveragePriority priority) {
  return switch (priority) {
    HolidayCoveragePriority.urgent => Colors.red.shade700,
    HolidayCoveragePriority.planning => Colors.orange.shade700,
    HolidayCoveragePriority.monitor => Colors.blueGrey.shade700,
  };
}

String _formatDaysUntil(int daysUntil) {
  if (daysUntil == 0) return 'Today';
  if (daysUntil == 1) return 'Tomorrow';
  return '$daysUntil days';
}
