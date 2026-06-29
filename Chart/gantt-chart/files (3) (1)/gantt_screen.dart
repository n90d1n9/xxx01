import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/gantt_providers.dart';
import '../../features/analytics/analytics_panel.dart';
import '../../shared/theme/gantt_theme.dart';
import 'gantt_toolbar.dart';
import 'gantt_chart_viewport.dart';
import 'task_detail_panel.dart';
import 'gantt_status_bar.dart';

class GanttScreen extends ConsumerWidget {
  const GanttScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final analyticsOpen = ref.watch(analyticsOpenProvider);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta): const _UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control): const _UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta, LogicalKeyboardKey.shift): const _RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control, LogicalKeyboardKey.shift): const _RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _DeselectIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): const _DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.backspace): const _DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.slash): const _SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyN): const _NewTaskIntent(),
      },
      child: Actions(
        actions: {
          _UndoIntent: CallbackAction<_UndoIntent>(onInvoke: (_) { ref.read(tasksProvider.notifier).undo(); return null; }),
          _RedoIntent: CallbackAction<_RedoIntent>(onInvoke: (_) { ref.read(tasksProvider.notifier).redo(); return null; }),
          _DeselectIntent: CallbackAction<_DeselectIntent>(onInvoke: (_) { ref.read(selectedTaskIdProvider.notifier).state = null; return null; }),
          _DeleteIntent: CallbackAction<_DeleteIntent>(onInvoke: (_) {
            final id = ref.read(selectedTaskIdProvider);
            if (id != null) {
              ref.read(tasksProvider.notifier).deleteTask(id);
              ref.read(selectedTaskIdProvider.notifier).state = null;
            }
            return null;
          }),
          _SearchIntent: CallbackAction<_SearchIntent>(onInvoke: (_) {
            // Toolbar handles search focus via searchFocusProvider
            ref.read(searchFocusRequestProvider.notifier).state++;
            return null;
          }),
          _NewTaskIntent: CallbackAction<_NewTaskIntent>(onInvoke: (_) {
            ref.read(addTaskDialogRequestProvider.notifier).state++;
            return null;
          }),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: GanttTheme.surface0,
            body: Column(
              children: [
                const GanttToolbar(),
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(child: GanttChartViewport()),
                      AnimatedSize(
                        duration: GanttAnimations.normal,
                        curve: Curves.easeInOut,
                        child: selectedId != null ? const TaskDetailPanel() : const SizedBox.shrink(),
                      ),
                      AnimatedSize(
                        duration: GanttAnimations.normal,
                        curve: Curves.easeInOut,
                        child: analyticsOpen ? const AnalyticsPanel() : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const GanttStatusBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Intent classes for keyboard shortcuts
class _UndoIntent extends Intent { const _UndoIntent(); }
class _RedoIntent extends Intent { const _RedoIntent(); }
class _DeselectIntent extends Intent { const _DeselectIntent(); }
class _DeleteIntent extends Intent { const _DeleteIntent(); }
class _SearchIntent extends Intent { const _SearchIntent(); }
class _NewTaskIntent extends Intent { const _NewTaskIntent(); }
