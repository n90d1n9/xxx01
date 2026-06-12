import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_task_inspector_actions.dart';
import 'gantt_task_inspector.dart';
import 'gantt_task_inspector_header.dart';
import 'gantt_task_inspector_overlay_layout.dart';
import 'gantt_task_inspector_overlay_motion.dart';

/// Floating task inspector shell for the full-screen Gantt chart.
class GanttTaskInspectorOverlay extends StatelessWidget {
  const GanttTaskInspectorOverlay({
    required this.task,
    required this.projectName,
    required this.dependencyTitle,
    required this.dependencyTasks,
    required this.recentEdits,
    required this.actions,
    this.placement = GanttTaskInspectorPlacement.adaptive,
    this.taskPositionLabel,
    this.previousTaskTitle,
    this.nextTaskTitle,
    super.key,
  });

  static const panelKey = ValueKey('gantt-task-inspector-panel');
  static const scrimKey = ValueKey('gantt-task-inspector-scrim');
  static const previousTaskButtonKey = ValueKey(
    'gantt-task-inspector-previous-task-button',
  );
  static const nextTaskButtonKey = ValueKey(
    'gantt-task-inspector-next-task-button',
  );
  static const contentScrollViewKey = ValueKey(
    'gantt-task-inspector-content-scroll-view',
  );

  final gantt.GanttTask task;
  final String? projectName;
  final String? dependencyTitle;
  final List<gantt.GanttTask> dependencyTasks;
  final List<gantt.GanttTaskEditActivity> recentEdits;
  final GanttTaskInspectorActions actions;
  final GanttTaskInspectorPlacement placement;
  final String? taskPositionLabel;
  final String? previousTaskTitle;
  final String? nextTaskTitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = GanttTaskInspectorOverlayLayout.resolve(
          constraints: constraints,
          placement: placement,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: _GanttTaskInspectorScrim(onDismiss: actions.onDismiss),
            ),
            Align(
              alignment: layout.alignment,
              child: Padding(
                padding: EdgeInsets.all(layout.padding),
                child: GanttTaskInspectorOverlayMotion(
                  isBottomSheet: layout.isBottomSheet,
                  child: SizedBox(
                    key: panelKey,
                    width: layout.sheetWidth,
                    height: layout.sheetHeight,
                    child: AppSurface(
                      elevated: true,
                      padding: EdgeInsets.zero,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GanttTaskInspectorHeader(
                            task: task,
                            projectName: projectName,
                            dependencyTitle: dependencyTitle,
                            taskPositionLabel: taskPositionLabel,
                            previousTaskTitle: previousTaskTitle,
                            nextTaskTitle: nextTaskTitle,
                            previousTaskButtonKey:
                                GanttTaskInspectorOverlay.previousTaskButtonKey,
                            nextTaskButtonKey:
                                GanttTaskInspectorOverlay.nextTaskButtonKey,
                            onPreviousTask: actions.onPreviousTask,
                            onNextTask: actions.onNextTask,
                            onDismiss: actions.onDismiss,
                          ),
                          Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: KeyedSubtree(
                              key: ValueKey(
                                'gantt-task-inspector-content-${task.id}',
                              ),
                              child: SingleChildScrollView(
                                key: contentScrollViewKey,
                                padding: const EdgeInsets.all(16),
                                child: GanttTaskInspectorPanel(
                                  task: task,
                                  projectName: projectName,
                                  dependencyTitle: dependencyTitle,
                                  dependencyTasks: dependencyTasks,
                                  recentEdits: recentEdits,
                                  actions: actions,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animated dismiss scrim behind the task inspector panel.
class _GanttTaskInspectorScrim extends StatelessWidget {
  const _GanttTaskInspectorScrim({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return ColoredBox(
          color: colorScheme.scrim.withValues(alpha: 0.12 * value),
          child: child,
        );
      },
      child: GestureDetector(
        key: GanttTaskInspectorOverlay.scrimKey,
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: const SizedBox.expand(),
      ),
    );
  }
}
