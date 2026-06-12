import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_table_models.dart';

class EmployeeDirectoryTablePresetStrip extends StatelessWidget {
  final List<EmployeeDirectoryTablePreset> presets;
  final EmployeeDirectoryTablePresetId? activePresetId;
  final int visibleCount;
  final ValueChanged<EmployeeDirectoryTablePreset> onPresetSelected;

  const EmployeeDirectoryTablePresetStrip({
    super.key,
    required this.presets,
    required this.activePresetId,
    required this.visibleCount,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activePreset =
        presets.where((preset) {
          return preset.id == activePresetId;
        }).firstOrNull;

    return HrisSectionPanel(
      icon: Icons.view_week_outlined,
      title: 'Saved table views',
      subtitle:
          activePreset == null
              ? '$visibleCount rows in a custom view'
              : '${activePreset.label} view, $visibleCount rows visible',
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              presets.map((preset) {
                final selected = preset.id == activePresetId;
                return ChoiceChip(
                  key: ValueKey(
                    'employee-directory-table-preset-${preset.id.name}',
                  ),
                  selected: selected,
                  avatar: Icon(
                    _iconFor(preset.id),
                    size: 18,
                    color: selected ? Colors.white : HrisColors.primary,
                  ),
                  label: Text(preset.label),
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedColor: HrisColors.primary,
                  backgroundColor: HrisColors.surfaceSubtle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: selected ? HrisColors.primary : HrisColors.border,
                    ),
                  ),
                  onSelected: (_) => onPresetSelected(preset),
                );
              }).toList(),
        ),
        Text(
          activePreset?.description ?? 'Manual filters are currently active.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

IconData _iconFor(EmployeeDirectoryTablePresetId id) {
  switch (id) {
    case EmployeeDirectoryTablePresetId.allEmployees:
      return Icons.groups_2_outlined;
    case EmployeeDirectoryTablePresetId.activeStaff:
      return Icons.verified_user_outlined;
    case EmployeeDirectoryTablePresetId.onboardingQueue:
      return Icons.rocket_launch_outlined;
    case EmployeeDirectoryTablePresetId.watchlistReview:
      return Icons.report_gmailerrorred_outlined;
    case EmployeeDirectoryTablePresetId.highPerformers:
      return Icons.workspace_premium_outlined;
    case EmployeeDirectoryTablePresetId.jakartaHub:
      return Icons.location_city_outlined;
  }
}
