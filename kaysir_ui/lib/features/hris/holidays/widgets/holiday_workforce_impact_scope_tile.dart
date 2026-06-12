import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_workforce_impact_models.dart';
import 'holiday_formatters.dart';
import 'holiday_workforce_impact_visuals.dart';

class HolidayWorkforceScopeTile extends StatelessWidget {
  final HolidayWorkforceScopeImpact scopeImpact;

  const HolidayWorkforceScopeTile({super.key, required this.scopeImpact});

  @override
  Widget build(BuildContext context) {
    final color = workforceImpactLevelColor(scopeImpact.level);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.groups_outlined, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scopeImpact.scope,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${scopeImpact.items.length} ${pluralizeWorkforceLabel('holiday', scopeImpact.items.length)}, next in ${formatWorkforceImpactDaysUntil(scopeImpact.daysUntilNext)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final chips = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HrisStatusPill(label: scopeImpact.level.label, color: color),
                  HrisStatusPill(
                    label: '${scopeImpact.estimatedEmployees} employees',
                    color: HrisColors.primary,
                  ),
                  if (scopeImpact.coverageRoles > 0)
                    HrisStatusPill(
                      label: '${scopeImpact.coverageRoles} coverage roles',
                      color: Colors.orange.shade700,
                    ),
                  if (scopeImpact.customCount > 0)
                    HrisStatusPill(
                      label: '${scopeImpact.customCount} custom',
                      color: Colors.teal.shade700,
                    ),
                ],
              );

              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 12), chips],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  Flexible(child: chips),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          for (final item in scopeImpact.items) _HolidayImpactLine(item: item),
        ],
      ),
    );
  }
}

class _HolidayImpactLine extends StatelessWidget {
  final HolidayWorkforceImpactItem item;

  const _HolidayImpactLine({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = workforceImpactLevelColor(item.level);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final holidayDetails = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.today_outlined, size: 17, color: HrisColors.muted),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.holiday.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${formatHolidayDate(item.holiday.effectiveDate)} - ${formatWorkforceImpactDaysUntil(item.daysUntil)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          );

          final signal = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HrisStatusPill(label: item.signal, color: color),
              Text(
                item.action,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [holidayDetails, const SizedBox(height: 8), signal],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: holidayDetails),
              const SizedBox(width: 16),
              Expanded(child: signal),
            ],
          );
        },
      ),
    );
  }
}
