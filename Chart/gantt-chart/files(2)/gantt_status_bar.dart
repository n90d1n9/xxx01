import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class GanttStatusBar extends ConsumerWidget {
  const GanttStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final visibleTasks = ref.watch(visibleTasksProvider);
    final filter = ref.watch(filterProvider);
    final notifier = ref.watch(tasksProvider.notifier);
    final (start, end) = ref.watch(projectDateRangeProvider);

    final total = tasks.length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProg = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdue = tasks.where((t) => t.isOverdue).length;
    final totalDays = GanttDateUtils.daysBetween(start, end) + 1;
    final overallProgress = total == 0 ? 0.0 : tasks.map((t) => t.progress).reduce((a, b) => a + b) / total;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(top: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Row(
        children: [
          // Task count
          _StatusChip(icon: Icons.task_alt, label: '$total tasks', color: GanttTheme.textMuted),
          _dot(),
          _StatusChip(icon: Icons.check_circle_outline, label: '$done done', color: GanttTheme.success),
          _dot(),
          _StatusChip(icon: Icons.pending_outlined, label: '$inProg active', color: GanttTheme.warning),
          if (overdue > 0) ...[
            _dot(),
            _StatusChip(icon: Icons.warning_outlined, label: '$overdue overdue', color: GanttTheme.danger),
          ],
          _dot(),
          _StatusChip(icon: Icons.date_range_outlined, label: '$totalDays days', color: GanttTheme.textMuted),
          _dot(),
          // Overall progress bar
          Row(children: [
            const Text('Overall:', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: GanttTheme.textMuted)),
            const SizedBox(width: 5),
            SizedBox(width: 80, child: LinearProgressIndicator(
              value: overallProgress, backgroundColor: GanttTheme.surface4,
              color: overallProgress >= 1.0 ? GanttTheme.success : GanttTheme.accent,
              minHeight: 4, borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(width: 5),
            Text('${(overallProgress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: GanttTheme.textSecondary)),
          ]),

          if (filter.isActive) ...[
            _dot(),
            _StatusChip(icon: Icons.filter_list, label: '${visibleTasks.length}/${total} shown', color: GanttTheme.info),
          ],

          const Spacer(),

          // Undo/redo shortcut hint
          if (notifier.canUndo)
            const Text('⌘Z to undo', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: GanttTheme.textDisabled)),

          const SizedBox(width: 8),
          Text('${GanttDateUtils.formatShortDate(start)} – ${GanttDateUtils.formatShortDate(end)}',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: GanttTheme.textDisabled)),
        ],
      ),
    );
  }

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Container(width: 2, height: 2, decoration: const BoxDecoration(color: GanttTheme.surface4, shape: BoxShape.circle)),
  );
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: color),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500, color: color)),
  ]);
}
