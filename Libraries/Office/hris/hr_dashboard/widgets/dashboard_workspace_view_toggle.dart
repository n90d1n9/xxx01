import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_view_mode.dart';

class DashboardWorkspaceViewToggle extends StatelessWidget {
  final DashboardWorkspaceViewMode selectedViewMode;
  final ValueChanged<DashboardWorkspaceViewMode> onChanged;

  const DashboardWorkspaceViewToggle({
    super.key,
    required this.selectedViewMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DashboardWorkspaceViewMode>(
      segments:
          DashboardWorkspaceViewMode.values
              .map(
                (mode) => ButtonSegment<DashboardWorkspaceViewMode>(
                  value: mode,
                  icon: Tooltip(
                    message: '${mode.label} view',
                    child: Icon(_viewModeIcon(mode), size: 18),
                  ),
                  label: Text(mode.label),
                ),
              )
              .toList(),
      selected: {selectedViewMode},
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HrisColors.ink;
          }
          return HrisColors.muted;
        }),
        textStyle: WidgetStateProperty.all(
          Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

IconData _viewModeIcon(DashboardWorkspaceViewMode mode) {
  switch (mode) {
    case DashboardWorkspaceViewMode.grid:
      return Icons.grid_view_rounded;
    case DashboardWorkspaceViewMode.list:
      return Icons.view_list_rounded;
  }
}
