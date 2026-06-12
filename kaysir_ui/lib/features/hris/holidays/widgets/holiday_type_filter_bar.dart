import 'package:flutter/material.dart';

import '../models/holiday_models.dart';

class HolidayTypeFilterBar extends StatelessWidget {
  final HolidayType? selectedType;
  final HolidaySummary summary;
  final ValueChanged<HolidayType?> onChanged;

  const HolidayTypeFilterBar({
    super.key,
    required this.selectedType,
    required this.summary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          key: const Key('holiday-filter-all'),
          avatar: const Icon(Icons.calendar_view_month_outlined, size: 18),
          label: Text('All (${summary.totalCount})'),
          selected: selectedType == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final type in HolidayType.values)
          FilterChip(
            key: Key('holiday-filter-${type.name}'),
            avatar: Icon(_typeIcon(type), size: 18),
            label: Text('${type.label} (${summary.countForType(type)})'),
            selected: selectedType == type,
            onSelected: (_) => onChanged(type),
          ),
      ],
    );
  }
}

IconData _typeIcon(HolidayType type) {
  return switch (type) {
    HolidayType.national => Icons.flag_outlined,
    HolidayType.fixed => Icons.event_repeat_outlined,
    HolidayType.anniversary => Icons.celebration_outlined,
    HolidayType.custom => Icons.tune_outlined,
  };
}
