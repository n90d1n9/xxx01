import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_workforce_impact_models.dart';
import 'holiday_workforce_impact_visuals.dart';

class HolidayWorkforceImpactSummary extends StatelessWidget {
  final HolidayWorkforceImpact impact;

  const HolidayWorkforceImpactSummary({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    final nextScope = impact.nextScope;

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headline = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${impact.totalEstimatedEmployees}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HrisColors.primary,
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
                    'Estimated employees',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    nextScope == null
                        ? 'Scope pressure is clear'
                        : '${nextScope.scope} needs first action',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                  ),
                ],
              ),
            ],
          );

          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _WorkforceStat(
                icon: Icons.event_outlined,
                label: 'Holidays',
                value: '${impact.totalHolidayCount}',
              ),
              _WorkforceStat(
                icon: Icons.priority_high_outlined,
                label: 'High impact',
                value: '${impact.highImpactCount}',
              ),
              _WorkforceStat(
                icon: Icons.health_and_safety_outlined,
                label: 'Coverage roles',
                value: '${impact.totalCoverageRoles}',
              ),
              _WorkforceStat(
                icon: Icons.map_outlined,
                label: 'Scopes',
                value: '${impact.scopes.length}',
              ),
            ],
          );

          final content =
              constraints.maxWidth < 780
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [headline, const SizedBox(height: 14), stats],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      headline,
                      const SizedBox(width: 20),
                      Expanded(child: stats),
                    ],
                  );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              if (nextScope != null) ...[
                const SizedBox(height: 12),
                _PriorityAction(scopeImpact: nextScope),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PriorityAction extends StatelessWidget {
  final HolidayWorkforceScopeImpact scopeImpact;

  const _PriorityAction({required this.scopeImpact});

  @override
  Widget build(BuildContext context) {
    final firstItem = scopeImpact.items.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.checklist_rtl_outlined,
            size: 18,
            color: workforceImpactLevelColor(firstItem.level),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${scopeImpact.scope}: ${firstItem.action}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkforceStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WorkforceStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
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
