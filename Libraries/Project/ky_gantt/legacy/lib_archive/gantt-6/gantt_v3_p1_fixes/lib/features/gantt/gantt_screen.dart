import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/services/notification_service.dart';
import '../../features/analytics/analytics_panel.dart';
import '../../shared/theme/gantt_theme.dart';
import 'gantt_toolbar.dart';
import 'gantt_chart_viewport.dart';
import 'task_detail_panel.dart';
import 'gantt_status_bar.dart';
import 'audit_panel.dart';
import 'snapshot_panel.dart';

class GanttScreen extends ConsumerWidget {
  const GanttScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final analyticsOpen = ref.watch(analyticsOpenProvider);
    final auditOpen = ref.watch(auditPanelOpenProvider);
    final snapshotOpen = ref.watch(snapshotPanelOpenProvider);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta):
            const _UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control):
            const _UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta,
            LogicalKeyboardKey.shift): const _RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control,
            LogicalKeyboardKey.shift): const _RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _DeselectIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): const _DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.backspace): const _DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.slash): const _SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyN): const _NewTaskIntent(),
        LogicalKeySet(LogicalKeyboardKey.home): const _JumpTodayIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.meta):
            const _SelectAllIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control):
            const _SelectAllIntent(),
      },
      child: Actions(
        actions: {
          _UndoIntent: CallbackAction<_UndoIntent>(onInvoke: (_) {
            ref.read(tasksProvider.notifier).undo();
            return null;
          }),
          _RedoIntent: CallbackAction<_RedoIntent>(onInvoke: (_) {
            ref.read(tasksProvider.notifier).redo();
            return null;
          }),
          _DeselectIntent: CallbackAction<_DeselectIntent>(onInvoke: (_) {
            ref.read(selectedTaskIdProvider.notifier).state = null;
            ref.read(multiSelectProvider.notifier).state = {};
            return null;
          }),
          _DeleteIntent: CallbackAction<_DeleteIntent>(onInvoke: (_) {
            final multi = ref.read(multiSelectProvider);
            if (multi.isNotEmpty) {
              for (final id in multi)
                ref.read(tasksProvider.notifier).deleteTask(id);
              ref.read(multiSelectProvider.notifier).state = {};
            } else {
              final id = ref.read(selectedTaskIdProvider);
              if (id != null) {
                ref.read(tasksProvider.notifier).deleteTask(id);
                ref.read(selectedTaskIdProvider.notifier).state = null;
              }
            }
            return null;
          }),
          _SearchIntent: CallbackAction<_SearchIntent>(onInvoke: (_) {
            ref.read(searchFocusRequestProvider.notifier).state++;
            return null;
          }),
          _NewTaskIntent: CallbackAction<_NewTaskIntent>(onInvoke: (_) {
            ref.read(addTaskDialogRequestProvider.notifier).state++;
            return null;
          }),
          _JumpTodayIntent: CallbackAction<_JumpTodayIntent>(onInvoke: (_) {
            ref.read(scrollToTodayProvider.notifier).state++;
            return null;
          }),
          _SelectAllIntent: CallbackAction<_SelectAllIntent>(onInvoke: (_) {
            final ids = ref.read(visibleTasksProvider).map((t) => t.id).toSet();
            ref.read(multiSelectProvider.notifier).state = ids;
            return null;
          }),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: GanttTheme.surface0,
            body: Column(children: [
              const GanttToolbar(),
              Expanded(
                child: Row(children: [
                  const Expanded(child: GanttChartViewport()),

                  // Task detail panel
                  AnimatedSize(
                    duration: GanttAnimations.normal,
                    curve: Curves.easeInOut,
                    child: selectedId != null
                        ? const TaskDetailPanel()
                        : const SizedBox.shrink(),
                  ),

                  // Analytics panel
                  AnimatedSize(
                    duration: GanttAnimations.normal,
                    curve: Curves.easeInOut,
                    child: analyticsOpen
                        ? const AnalyticsPanel()
                        : const SizedBox.shrink(),
                  ),

                  // Audit log panel
                  AnimatedSize(
                    duration: GanttAnimations.normal,
                    curve: Curves.easeInOut,
                    child: auditOpen
                        ? const AuditPanel()
                        : const SizedBox.shrink(),
                  ),

                  // Snapshot panel
                  AnimatedSize(
                    duration: GanttAnimations.normal,
                    curve: Curves.easeInOut,
                    child: snapshotOpen
                        ? const SnapshotPanel()
                        : const SizedBox.shrink(),
                  ),
                ]),
              ),
              const GanttStatusBar(),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Intent classes ────────────────────────────────────────────────────────────
class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}

class _DeselectIntent extends Intent {
  const _DeselectIntent();
}

class _DeleteIntent extends Intent {
  const _DeleteIntent();
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

class _NewTaskIntent extends Intent {
  const _NewTaskIntent();
}

class _JumpTodayIntent extends Intent {
  const _JumpTodayIntent();
}

class _SelectAllIntent extends Intent {
  const _SelectAllIntent();
}
