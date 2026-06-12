import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/task_validator.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';
import '../../core/services/notification_service.dart';
import 'dart:math' as math;

class TaskDetailPanel extends ConsumerStatefulWidget {
  const TaskDetailPanel({super.key});
  @override
  ConsumerState<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends ConsumerState<TaskDetailPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _slide;
  String? _prevId;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: GanttAnimations.normal);
    _slide = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final task = ref.watch(selectedTaskProvider);
    if (selectedId != _prevId) {
      _prevId = selectedId;
      task != null ? _anim.forward(from: 0) : _anim.reverse();
    }
    if (task == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _slide,
      builder: (_, child) => Transform.translate(
          offset: Offset(320 * (1 - _slide.value), 0),
          child: Opacity(opacity: _slide.value, child: child)),
      child: _DetailContent(task: task),
    );
  }
}

class _DetailContent extends ConsumerStatefulWidget {
  final Task task;
  const _DetailContent({required this.task});
  @override
  ConsumerState<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends ConsumerState<_DetailContent> {
  late TextEditingController _titleCtrl, _descCtrl, _commentCtrl, _hoursCtrl;
  bool _editingTitle = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description ?? '');
    _commentCtrl = TextEditingController();
    _hoursCtrl = TextEditingController(text: '1.0');
  }

  @override
  void didUpdateWidget(_DetailContent old) {
    super.didUpdateWidget(old);
    if (old.task.id != widget.task.id) {
      _titleCtrl.text = widget.task.title;
      _descCtrl.text = widget.task.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _commentCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _saveTitle() {
    final t = _titleCtrl.text.trim();
    final titleErr = TaskValidator.validateTitle(t);
    if (titleErr == null) {
      ref.read(tasksProvider.notifier).updateTask(
          widget.task.copyWith(title: t, updatedAt: DateTime.now()));
    }
    setState(() => _editingTitle = false);
  }

  void _addComment() {
    final t = _commentCtrl.text.trim();
    if (t.isEmpty) return;
    ref.read(tasksProvider.notifier).addComment(
        widget.task.id,
        TaskComment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: 'current_user',
          authorName: 'You',
          content: t,
          timestamp: DateTime.now(),
        ));
    _commentCtrl.clear();
  }

  void _logTime() {
    final h = double.tryParse(_hoursCtrl.text);
    if (h == null || h <= 0) return;
    ref.read(tasksProvider.notifier).addTimeEntry(
        widget.task.id,
        TimeEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user',
          userName: 'You',
          date: DateTime.now(),
          hours: h,
        ));
    _hoursCtrl.text = '1.0';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Logged ${h}h'),
        duration: const Duration(seconds: 2),
        backgroundColor: GanttTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Container(
      width: 320,
      decoration: const BoxDecoration(
          color: GanttTheme.surface1,
          border: Border(left: BorderSide(color: GanttTheme.surface4))),
      child: Column(children: [
        _buildHeader(task),
        _buildProgressBar(task),
        // Tab strip
        Container(
            height: 36,
            color: GanttTheme.surface1,
            child: Row(children: [
              for (int i = 0; i < 3; i++)
                _TabBtn(
                    label: ['Details', 'Activity', 'Time'][i],
                    active: _tab == i,
                    onTap: () => setState(() => _tab = i)),
            ])),
        const Divider(height: 1, color: GanttTheme.surface4),
        Expanded(
            child: _tab == 0
                ? _buildDetails(task)
                : _tab == 1
                    ? _buildActivity(task)
                    : _buildTime(task)),
      ]),
    );
  }

  Widget _buildHeader(Task task) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: task.status.color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(task.status.label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: task.status.color)),
            const Spacer(),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: task.priority.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(task.priority.icon,
                      size: 10, color: task.priority.color),
                  const SizedBox(width: 3),
                  Text(task.priority.label,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: task.priority.color)),
                ])),
            IconButton(
                icon: const Icon(Icons.close, size: 14),
                color: GanttTheme.textMuted,
                padding: EdgeInsets.zero,
                onPressed: () =>
                    ref.read(selectedTaskIdProvider.notifier).state = null),
          ]),
          const SizedBox(height: 6),
          _editingTitle
              ? Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _titleCtrl,
                          autofocus: true,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: GanttTheme.textPrimary),
                          decoration: const InputDecoration.collapsed(
                              hintText: 'Task title'),
                          onSubmitted: (_) => _saveTitle())),
                  IconButton(
                      icon: const Icon(Icons.check, size: 14),
                      onPressed: _saveTitle,
                      color: GanttTheme.success,
                      padding: EdgeInsets.zero),
                ])
              : GestureDetector(
                  onTap: () => setState(() => _editingTitle = true),
                  child: Text(task.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: GanttTheme.textPrimary))),
        ]),
      );

  Widget _buildProgressBar(Task task) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Progress',
                style: TextStyle(fontSize: 10, color: GanttTheme.textMuted)),
            const Spacer(),
            Text('${(task.progress * 100).toInt()}%',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
          ]),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: task.status.color,
              inactiveTrackColor: GanttTheme.surface4,
              thumbColor: task.status.color,
              overlayColor: task.status.color.withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 4,
            ),
            child: Slider(
              value: task.progress.clamp(0.0, 1.0),
              onChanged: (v) => ref.read(tasksProvider.notifier).updateTask(
                  task.copyWith(progress: v, updatedAt: DateTime.now())),
              min: 0,
              max: 1,
            ),
          ),
        ]),
      );

  Widget _buildDetails(Task task) => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Dates
          _Section(title: 'SCHEDULE', children: [
            _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Start',
                value: GanttDateUtils.formatShortDate(task.startDate)),
            _DetailRow(
                icon: Icons.event_outlined,
                label: 'End',
                value: GanttDateUtils.formatShortDate(task.endDate)),
            _DetailRow(
                icon: Icons.timelapse,
                label: 'Duration',
                value: GanttDateUtils.durationLabel(task)),
            if (task.slipDays != 0)
              _DetailRow(
                  icon: Icons.trending_up,
                  label: 'Slip',
                  value: '${task.slipDays > 0 ? "+" : ""}${task.slipDays} days',
                  valueColor: task.slipDays > 0
                      ? GanttTheme.danger
                      : GanttTheme.success),
            if (task.baseline != null)
              _DetailRow(
                  icon: Icons.compare,
                  label: 'Baseline',
                  value:
                      '${GanttDateUtils.formatShortDate(task.baseline!.startDate)} – ${GanttDateUtils.formatShortDate(task.baseline!.endDate)}',
                  valueColor: GanttTheme.textMuted),
          ]),
          const SizedBox(height: 12),
          // Hours
          _Section(title: 'EFFORT', children: [
            _DetailRow(
                icon: Icons.schedule_outlined,
                label: 'Estimated',
                value: '${task.estimatedHours.toStringAsFixed(1)}h'),
            _DetailRow(
                icon: Icons.timer_outlined,
                label: 'Actual',
                value: '${task.actualHours.toStringAsFixed(1)}h',
                valueColor: task.actualHours > task.estimatedHours
                    ? GanttTheme.danger
                    : GanttTheme.success),
            if (task.estimatedHours > 0)
              _DetailRow(
                  icon: Icons.percent,
                  label: 'Efficiency',
                  value:
                      '${((task.estimatedHours / math.max(task.actualHours, 0.01)) * 100).toInt()}%'),
          ]),
          const SizedBox(height: 12),
          // Description
          if ((task.description?.isNotEmpty) == true) ...[
            _Section(title: 'DESCRIPTION', children: [
              Text(task.description!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: GanttTheme.textSecondary,
                      height: 1.5)),
            ]),
            const SizedBox(height: 12),
          ],
          // Assignees
          if (task.assignees.isNotEmpty) ...[
            _Section(title: 'ASSIGNEES', children: [
              Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: task.assignees
                      .map((a) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: a.avatarColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: a.avatarColor.withOpacity(0.3))),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                      color: a.avatarColor,
                                      shape: BoxShape.circle),
                                  child: Center(
                                      child: Text(a.initials[0],
                                          style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)))),
                              const SizedBox(width: 5),
                              Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: GanttTheme.textPrimary)),
                            ]),
                          ))
                      .toList()),
            ]),
            const SizedBox(height: 12),
          ],
          // Labels
          if (task.labels.isNotEmpty) ...[
            _Section(title: 'LABELS', children: [
              Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: task.labels
                      .map((l) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                                color: GanttTheme.surface3,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: GanttTheme.surface4)),
                            child: Text(l,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: GanttTheme.textSecondary)),
                          ))
                      .toList()),
            ]),
            const SizedBox(height: 12),
          ],
          // Checklist
          if (task.checklist.isNotEmpty) ...[
            _Section(
                title:
                    'CHECKLIST  ${task.checklist.where((c) => c.isCompleted).length}/${task.checklist.length}',
                children: [
                  LinearProgressIndicator(
                      value: task.checklistProgress,
                      backgroundColor: GanttTheme.surface4,
                      color: GanttTheme.success,
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(2)),
                  const SizedBox(height: 8),
                  for (final item in task.checklist)
                    Row(children: [
                      SizedBox(
                          width: 24,
                          child: Checkbox(
                              value: item.isCompleted,
                              onChanged: (v) => ref
                                  .read(tasksProvider.notifier)
                                  .toggleChecklistItem(task.id, item.id),
                              activeColor: GanttTheme.success,
                              side:
                                  const BorderSide(color: GanttTheme.surface4),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap)),
                      Expanded(
                          child: Text(item.text,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: item.isCompleted
                                      ? GanttTheme.textMuted
                                      : GanttTheme.textPrimary,
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null))),
                    ]),
                ]),
            const SizedBox(height: 12),
          ],
          // Risk
          if (task.riskLevel != RiskLevel.none)
            _Section(title: 'RISK', children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: task.riskLevel.color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(task.riskLevel.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: task.riskLevel.color)),
              ]),
            ]),
          const SizedBox(height: 12),
          // Actions
          Row(children: [
            Expanded(
                child: _ActionBtn(
                    icon: Icons.copy_outlined,
                    label: 'Duplicate',
                    onTap: () {
                      ref.read(tasksProvider.notifier).duplicateTask(task.id);
                      ref.read(selectedTaskIdProvider.notifier).state = null;
                    })),
            const SizedBox(width: 6),
            Expanded(
                child: _ActionBtn(
                    icon: Icons.delete_outlined,
                    label: 'Delete',
                    color: GanttTheme.danger,
                    onTap: () {
                      ref.read(tasksProvider.notifier).deleteTask(task.id);
                      ref.read(selectedTaskIdProvider.notifier).state = null;
                    })),
          ]),
        ]),
      );

  Widget _buildActivity(Task task) => Column(children: [
        Expanded(
            child: task.comments.isEmpty
                ? const Center(
                    child: Text('No comments yet',
                        style: TextStyle(
                            fontSize: 12, color: GanttTheme.textMuted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: task.comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = task.comments[task.comments.length - 1 - i];
                      return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                    color: GanttTheme.accent,
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Text(c.authorName[0],
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(children: [
                                    Text(c.authorName,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: GanttTheme.textPrimary)),
                                    const SizedBox(width: 6),
                                    Text(
                                        GanttDateUtils.formatRelativeDate(
                                            c.timestamp),
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: GanttTheme.textMuted)),
                                  ]),
                                  const SizedBox(height: 3),
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: GanttTheme.surface2,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(c.content,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: GanttTheme.textSecondary,
                                              height: 1.4))),
                                ])),
                          ]);
                    })),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
                child: TextField(
                    controller: _commentCtrl,
                    maxLines: 2,
                    minLines: 1,
                    style: const TextStyle(
                        fontSize: 12, color: GanttTheme.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true),
                    onSubmitted: (_) => _addComment())),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.send, size: 16),
                color: GanttTheme.accent,
                onPressed: _addComment,
                tooltip: 'Send comment'),
          ]),
        ),
      ]);

  Widget _buildTime(Task task) => Column(children: [
        // Log time row
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            SizedBox(
                width: 80,
                child: TextField(
                    controller: _hoursCtrl,
                    style: const TextStyle(
                        fontSize: 13, color: GanttTheme.textPrimary),
                    decoration: const InputDecoration(
                        labelText: 'Hours',
                        suffixText: 'h',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        isDense: true),
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(
                child: ElevatedButton.icon(
              onPressed: _logTime,
              icon: const Icon(Icons.add, size: 12),
              label: const Text('Log Time'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 34)),
            )),
          ]),
        ),
        // Summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            _TimeStatBox('Estimated',
                '${task.estimatedHours.toStringAsFixed(1)}h', GanttTheme.info),
            const SizedBox(width: 8),
            _TimeStatBox(
                'Logged',
                '${task.actualHours.toStringAsFixed(1)}h',
                task.actualHours > task.estimatedHours
                    ? GanttTheme.danger
                    : GanttTheme.success),
            const SizedBox(width: 8),
            _TimeStatBox(
                'Remaining',
                '${math.max(0, task.estimatedHours - task.actualHours).toStringAsFixed(1)}h',
                GanttTheme.warning),
          ]),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        // Log entries
        Expanded(
            child: task.timeEntries.isEmpty
                ? const Center(
                    child: Text('No time logged yet',
                        style: TextStyle(
                            fontSize: 12, color: GanttTheme.textMuted)))
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: task.timeEntries.length,
                    itemBuilder: (_, i) {
                      final e =
                          task.timeEntries[task.timeEntries.length - 1 - i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          const Icon(Icons.timer_outlined,
                              size: 12, color: GanttTheme.textMuted),
                          const SizedBox(width: 6),
                          Text(GanttDateUtils.formatShortDate(e.date),
                              style: const TextStyle(
                                  fontSize: 11, color: GanttTheme.textMuted)),
                          const SizedBox(width: 6),
                          Text(e.userName,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: GanttTheme.textSecondary)),
                          const Spacer(),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: GanttTheme.surface3,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('${e.hours.toStringAsFixed(1)}h',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: GanttTheme.textPrimary))),
                        ]),
                      );
                    })),
      ]);
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GanttTheme.headerLabel),
        const SizedBox(height: 8),
        ...children,
      ]);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _DetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          Icon(icon, size: 12, color: GanttTheme.textMuted),
          const SizedBox(width: 6),
          SizedBox(
              width: 68,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: GanttTheme.textMuted))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? GanttTheme.textPrimary))),
        ]),
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: GanttTheme.surface2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: (color ?? GanttTheme.surface4).withOpacity(0.4))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 13, color: color ?? GanttTheme.textMuted),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color ?? GanttTheme.textSecondary)),
            ])),
      );
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
          child: InkWell(
        onTap: onTap,
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: active ? GanttTheme.accent : Colors.transparent,
                        width: 2))),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? GanttTheme.accent : GanttTheme.textMuted))),
      ));
}

class _TimeStatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _TimeStatBox(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 9, color: GanttTheme.textMuted)),
        ]),
      ));
}

// ─── Mention-aware text field ─────────────────────────────────────────────────

class _MentionTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int? maxLines;
  final VoidCallback? onSubmitted;

  const _MentionTextField({
    required this.controller,
    this.hintText,
    this.maxLines = 3,
    this.onSubmitted,
  });

  @override
  State<_MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<_MentionTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final mentions = parseMentions(text);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: widget.controller,
        maxLines: widget.maxLines,
        style: const TextStyle(fontSize: 12, color: GanttTheme.textPrimary),
        decoration: InputDecoration(
            hintText:
                widget.hintText ?? 'Add a comment... Use @name to mention'),
        onSubmitted: (_) => widget.onSubmitted?.call(),
      ),
      // Mention preview chips
      if (mentions.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
              spacing: 4,
              children: mentions
                  .map((m) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: GanttTheme.accentDim,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.alternate_email,
                              size: 10, color: GanttTheme.accentLight),
                          const SizedBox(width: 3),
                          Text(m.name,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: GanttTheme.accentLight,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ))
                  .toList()),
        ),
    ]);
  }
}
