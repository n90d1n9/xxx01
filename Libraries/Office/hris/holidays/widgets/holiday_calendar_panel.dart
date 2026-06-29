import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_models.dart';
import 'holiday_formatters.dart';

class HolidayCalendarPanel extends StatelessWidget {
  final List<HolidayRecord> holidays;
  final ValueChanged<HolidayRecord> onEdit;
  final ValueChanged<HolidayRecord> onDelete;

  const HolidayCalendarPanel({
    super.key,
    required this.holidays,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.calendar_month_outlined,
      title: 'Holiday calendar',
      subtitle: 'National, fixed, anniversary, and custom rules',
      emptyMessage: 'No holidays match this filter',
      children: [
        for (final holiday in holidays)
          _HolidayCalendarTile(
            holiday: holiday,
            onEdit: () => onEdit(holiday),
            onDelete: () => onDelete(holiday),
          ),
      ],
    );
  }
}

class _HolidayCalendarTile extends StatelessWidget {
  final HolidayRecord holiday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HolidayCalendarTile({
    required this.holiday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit ${holiday.name}',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Delete ${holiday.name}',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          );
          final details = Column(
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
                    label: holiday.type.label,
                    color: _typeColor(holiday.type),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HolidayMetaLabel(
                    icon: Icons.today_outlined,
                    label: formatHolidayDate(holiday.date),
                  ),
                  if (holiday.isObservedShifted)
                    _HolidayMetaLabel(
                      icon: Icons.event_repeat_outlined,
                      label:
                          'Observed ${formatHolidayDate(holiday.effectiveDate)}',
                    ),
                  _HolidayMetaLabel(
                    icon: Icons.groups_outlined,
                    label: holiday.scope,
                  ),
                  _HolidayMetaLabel(
                    icon: Icons.repeat_rounded,
                    label: formatHolidayRecurrence(holiday),
                  ),
                ],
              ),
              if (holiday.description.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  holiday.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HrisStatusPill(
                    label: holiday.isPaid ? 'Paid' : 'Unpaid',
                    color: holiday.isPaid ? Colors.green : Colors.orange,
                  ),
                  if (holiday.requiresCoveragePlan)
                    HrisStatusPill(
                      label: 'Coverage plan',
                      color: HrisColors.primary,
                    ),
                ],
              ),
            ],
          );

          if (constraints.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _HolidayMetaLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HolidayMetaLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: HrisColors.muted),
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

Color _typeColor(HolidayType type) {
  return switch (type) {
    HolidayType.national => Colors.red.shade700,
    HolidayType.fixed => HrisColors.primary,
    HolidayType.anniversary => Colors.purple.shade700,
    HolidayType.custom => Colors.teal.shade700,
  };
}
