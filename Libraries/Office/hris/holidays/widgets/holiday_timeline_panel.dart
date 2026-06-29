import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_models.dart';
import '../models/holiday_timeline_models.dart';
import 'holiday_formatters.dart';

class HolidayTimelinePanel extends StatelessWidget {
  final HolidayTimeline timeline;

  const HolidayTimelinePanel({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.view_timeline_outlined,
      title: 'Holiday timeline',
      subtitle: '${timeline.horizonDays}-day month impact map',
      emptyMessage: 'No upcoming holidays in the timeline',
      children: [
        _TimelineSummarySurface(timeline: timeline),
        for (final bucket in timeline.buckets)
          _TimelineMonthTile(bucket: bucket),
      ],
    );
  }
}

class _TimelineSummarySurface extends StatelessWidget {
  final HolidayTimeline timeline;

  const _TimelineSummarySurface({required this.timeline});

  @override
  Widget build(BuildContext context) {
    final busiest = timeline.busiestBucket;

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
                    '${timeline.totalUpcomingCount}',
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
                    busiest == null ? 'No upcoming months' : busiest.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    busiest == null ? 'Timeline is clear' : 'Busiest month',
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
              _TimelineStat(
                icon: Icons.calendar_month_outlined,
                label: 'Months',
                value: '${timeline.buckets.length}',
              ),
              _TimelineStat(
                icon: Icons.health_and_safety_outlined,
                label: 'Coverage',
                value: '${timeline.coverageHolidayCount}',
              ),
              _TimelineStat(
                icon: Icons.tune_outlined,
                label: 'Custom',
                value: '${timeline.customHolidayCount}',
              ),
              _TimelineStat(
                icon: Icons.event_repeat_outlined,
                label: 'Shifted',
                value: '${timeline.observedShiftCount}',
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [headline, const SizedBox(height: 14), stats],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              headline,
              const SizedBox(width: 20),
              Expanded(child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TimelineStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
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

class _TimelineMonthTile extends StatelessWidget {
  final HolidayTimelineBucket bucket;

  const _TimelineMonthTile({required this.bucket});

  @override
  Widget build(BuildContext context) {
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
                      color: _impactColor(bucket).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _impactIcon(bucket),
                      color: _impactColor(bucket),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bucket.label,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${bucket.holidayCount} holidays, first in ${_formatDays(bucket.daysUntilFirstHoliday)}',
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
                  HrisStatusPill(
                    label: bucket.impactLabel,
                    color: _impactColor(bucket),
                  ),
                  if (bucket.coverageCount > 0)
                    HrisStatusPill(
                      label: '${bucket.coverageCount} coverage',
                      color: HrisColors.primary,
                    ),
                  if (bucket.customCount > 0)
                    HrisStatusPill(
                      label: '${bucket.customCount} custom',
                      color: Colors.teal.shade700,
                    ),
                  if (bucket.observedShiftCount > 0)
                    HrisStatusPill(
                      label: '${bucket.observedShiftCount} shifted',
                      color: Colors.purple.shade700,
                    ),
                ],
              );

              if (constraints.maxWidth < 680) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), chips],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  Expanded(child: chips),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          for (final holiday in bucket.holidays)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _TimelineHolidayRow(holiday: holiday),
            ),
        ],
      ),
    );
  }
}

class _TimelineHolidayRow extends StatelessWidget {
  final HolidayRecord holiday;

  const _TimelineHolidayRow({required this.holiday});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_holidayIcon(holiday), size: 17, color: HrisColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                holiday.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                formatHolidayDate(holiday.effectiveDate),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              Text(
                holiday.scope,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color _impactColor(HolidayTimelineBucket bucket) {
  if (bucket.coverageCount > 0) return Colors.orange.shade700;
  if (bucket.customCount > 0) return Colors.teal.shade700;
  if (bucket.observedShiftCount > 0) return Colors.purple.shade700;
  return Colors.green.shade700;
}

IconData _impactIcon(HolidayTimelineBucket bucket) {
  if (bucket.coverageCount > 0) return Icons.health_and_safety_outlined;
  if (bucket.customCount > 0) return Icons.tune_outlined;
  if (bucket.observedShiftCount > 0) return Icons.event_repeat_outlined;
  return Icons.event_available_outlined;
}

IconData _holidayIcon(HolidayRecord holiday) {
  return switch (holiday.type) {
    HolidayType.national => Icons.flag_outlined,
    HolidayType.fixed => Icons.event_repeat_outlined,
    HolidayType.anniversary => Icons.celebration_outlined,
    HolidayType.custom => Icons.tune_outlined,
  };
}

String _formatDays(int days) {
  if (days == 0) return 'today';
  if (days == 1) return '1 day';
  return '$days days';
}
