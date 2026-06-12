import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

class GanttTaskInspectorActionBar extends StatelessWidget {
  const GanttTaskInspectorActionBar({
    required this.onClearSelection,
    this.projectName,
    this.onOpenProject,
    this.onUndoLastEdit,
    super.key,
  });

  static const undoLastEditButtonKey = ValueKey(
    'gantt-task-inspector-undo-last-edit-button',
  );
  static const openProjectButtonKey = ValueKey(
    'gantt-task-inspector-open-project-button',
  );
  static const clearSelectionButtonKey = ValueKey(
    'gantt-task-inspector-clear-selection-button',
  );

  final String? projectName;
  final VoidCallback? onOpenProject;
  final VoidCallback? onUndoLastEdit;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (onUndoLastEdit != null)
        _InspectorAction(
          key: undoLastEditButtonKey,
          label: 'Undo Last Edit',
          icon: Icons.undo_rounded,
          variant: AppActionButtonVariant.secondary,
          onPressed: onUndoLastEdit!,
        ),
      if (projectName != null && onOpenProject != null)
        _InspectorAction(
          key: openProjectButtonKey,
          label: 'Open Project',
          icon: Icons.open_in_new_rounded,
          variant: AppActionButtonVariant.primary,
          onPressed: onOpenProject!,
        ),
      _InspectorAction(
        key: clearSelectionButtonKey,
        label: 'Clear Selection',
        icon: Icons.close_rounded,
        variant: AppActionButtonVariant.secondary,
        onPressed: onClearSelection,
      ),
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final action in actions)
            AppActionButton(
              key: action.key,
              label: action.label,
              icon: action.icon,
              compact: true,
              variant: action.variant,
              onPressed: action.onPressed,
            ),
        ],
      ),
    );
  }
}

class _InspectorAction {
  const _InspectorAction({
    required this.key,
    required this.label,
    required this.icon,
    required this.variant,
    required this.onPressed,
  });

  final Key key;
  final String label;
  final IconData icon;
  final AppActionButtonVariant variant;
  final VoidCallback onPressed;
}
