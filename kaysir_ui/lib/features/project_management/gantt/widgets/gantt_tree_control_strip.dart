import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/gantt_tree_control_presentation_service.dart';
import '../services/gantt_tree_control_summary_service.dart';
import 'gantt_control_strip_primitives.dart';

/// Header control strip for collapsing or expanding visible Gantt branches.
class GanttTreeControlStrip extends StatelessWidget {
  const GanttTreeControlStrip({
    required this.branchCount,
    required this.collapsedCount,
    required this.onCollapseAll,
    required this.onExpandAll,
    super.key,
  });

  static const collapseAllButtonKey = ganttTreeCollapseAllButtonKey;
  static const expandAllButtonKey = ganttTreeExpandAllButtonKey;

  final int branchCount;
  final int collapsedCount;
  final VoidCallback? onCollapseAll;
  final VoidCallback? onExpandAll;

  @override
  Widget build(BuildContext context) {
    if (branchCount <= 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final summary = const GanttTreeControlSummaryService().summaryFor(
      branchCount: branchCount,
      collapsedCount: collapsedCount,
    );
    final statePresentation = ganttTreeCollapseStatePresentation(summary.state);
    final collapseAllAction = summary.canCollapseAll ? onCollapseAll : null;
    final expandAllAction = summary.canExpandAll ? onExpandAll : null;

    return GanttControlStripShell(
      title: 'Task tree',
      subtitle: summary.countLabel,
      icon: Icons.account_tree_outlined,
      accent: GanttControlAccent.primary,
      spacing: 10,
      children: [
        AppStatusPill(
          label: summary.stateLabel,
          tooltip: '${summary.tooltip} - ${summary.percentLabel}',
          icon: statePresentation.icon,
          color: _accentColor(colorScheme, statePresentation.accent),
          maxWidth: 124,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TreeActionButton(
              presentation: ganttTreeControlActionPresentation(
                GanttTreeControlAction.collapseAll,
              ),
              tooltip: summary.collapseActionTooltip,
              onPressed: collapseAllAction,
            ),
            _TreeActionButton(
              presentation: ganttTreeControlActionPresentation(
                GanttTreeControlAction.expandAll,
              ),
              tooltip: summary.expandActionTooltip,
              onPressed: expandAllAction,
            ),
          ],
        ),
      ],
    );
  }

  Color _accentColor(ColorScheme colorScheme, GanttTreeControlAccent accent) {
    switch (accent) {
      case GanttTreeControlAccent.primary:
        return colorScheme.primary;
      case GanttTreeControlAccent.secondary:
        return colorScheme.secondary;
      case GanttTreeControlAccent.tertiary:
        return colorScheme.tertiary;
    }
  }
}

class _TreeActionButton extends StatelessWidget {
  const _TreeActionButton({
    required this.presentation,
    required this.tooltip,
    required this.onPressed,
  });

  final GanttTreeControlActionPresentation presentation;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AppActionButton(
        key: presentation.key,
        label: presentation.label,
        icon: presentation.icon,
        compact: true,
        height: 34,
        variant: AppActionButtonVariant.secondary,
        onPressed: onPressed,
      ),
    );
  }
}
