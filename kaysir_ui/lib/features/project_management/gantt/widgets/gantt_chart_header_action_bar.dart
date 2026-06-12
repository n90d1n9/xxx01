import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

import '../services/gantt_chart_header_action_presentation_service.dart';

/// Header action cluster for full-screen Gantt chart commands.
class GanttChartHeaderActionBar extends StatelessWidget {
  const GanttChartHeaderActionBar({
    required this.controlsExpanded,
    required this.canUndoLastEdit,
    required this.onToggleControls,
    required this.onUndoLastEdit,
    required this.onOpenViewSettings,
    required this.onOpenDashboard,
    this.compact = false,
    super.key,
  });

  static const toggleControlsButtonKey = ganttHeaderToggleControlsButtonKey;
  static const undoEditButtonKey = ganttHeaderUndoEditButtonKey;
  static const viewSettingsButtonKey = ganttHeaderViewSettingsButtonKey;
  static const dashboardButtonKey = ganttHeaderDashboardButtonKey;

  final bool controlsExpanded;
  final bool canUndoLastEdit;
  final VoidCallback onToggleControls;
  final VoidCallback onUndoLastEdit;
  final VoidCallback onOpenViewSettings;
  final VoidCallback onOpenDashboard;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = ganttChartHeaderActionPresentations(
      controlsExpanded: controlsExpanded,
      canUndoLastEdit: canUndoLastEdit,
    );

    return Wrap(
      spacing: compact ? 8 : 10,
      runSpacing: 10,
      children: [
        for (final action in actions)
          compact
              ? _CompactHeaderActionButton(
                action: action,
                onPressed: _onPressedFor(action),
              )
              : AppActionButton(
                key: action.key,
                label: action.label,
                icon: action.icon,
                variant: AppActionButtonVariant.secondary,
                onPressed: _onPressedFor(action),
              ),
      ],
    );
  }

  VoidCallback? _onPressedFor(GanttChartHeaderActionPresentation action) {
    if (!action.enabled) return null;

    switch (action.role) {
      case GanttChartHeaderActionRole.toggleControls:
        return onToggleControls;
      case GanttChartHeaderActionRole.undoEdit:
        return onUndoLastEdit;
      case GanttChartHeaderActionRole.viewSettings:
        return onOpenViewSettings;
      case GanttChartHeaderActionRole.dashboard:
        return onOpenDashboard;
    }
  }
}

class _CompactHeaderActionButton extends StatelessWidget {
  const _CompactHeaderActionButton({
    required this.action,
    required this.onPressed,
  });

  final GanttChartHeaderActionPresentation action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      key: action.key,
      tooltip: action.tooltip,
      onPressed: onPressed,
      icon: Icon(action.icon),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(38),
        minimumSize: const Size.square(38),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colorScheme.onSurfaceVariant,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        backgroundColor: colorScheme.surfaceContainerLow,
        disabledBackgroundColor: colorScheme.surfaceContainerLow,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
