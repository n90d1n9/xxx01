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
    final visible = ref.watch(visibleTasksProvider);
    final settings = ref.watch(viewSettingsProvider);
    final filter = ref.watch(filterProvider);

    final totalTasks = tasks.where((t) => !t.isMilestone).length;
    final doneTasks =
        tasks.where((t) => t.status == TaskStatus.done).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    final milestones = tasks.where((t) => t.isMilestone).length;
    final avgProgress = tasks.isEmpty
        ? 0.0
        : tasks.map((t) => t.progress).reduce((a, b) => a + b) / tasks.length;

    final (projectStart, projectEnd) = ref.watch(projectDateRangeProvider);
    final projectDays = GanttDateUtils.daysBetween(projectStart, projectEnd);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(top: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.check_box_outlined,
            label: '$doneTasks/$totalTasks tasks done',
            color: GanttTheme.success,
          ),
          _Separator(),
          if (overdueTasks > 0) ...[
            _StatItem(
              icon: Icons.warning_amber_outlined,
              label: '$overdueTasks overdue',
              color: GanttTheme.danger,
            ),
            _Separator(),
          ],
          _StatItem(
            icon: Icons.flag_outlined,
            label: '$milestones milestones',
            color: GanttTheme.warning,
          ),
          _Separator(),
          _StatItem(
            icon: Icons.trending_up,
            label: '${(avgProgress * 100).toInt()}% overall',
            color: GanttTheme.textSecondary,
          ),
          _Separator(),
          _StatItem(
            icon: Icons.calendar_today_outlined,
            label: '$projectDays day span',
            color: GanttTheme.textSecondary,
          ),
          const Spacer(),
          if (filter.isActive) ...[
            Text(
              'Showing ${visible.length} of ${tasks.length} tasks',
              style: GanttTheme.labelSmall.copyWith(
                color: GanttTheme.accent,
              ),
            ),
            _Separator(),
          ],
          Text(
            '${settings.dayWidth.toInt()}px/day  ·  ${settings.viewMode.name}',
            style: GanttTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: GanttTheme.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 1,
        height: 12,
        color: GanttTheme.surface4,
      );
}
