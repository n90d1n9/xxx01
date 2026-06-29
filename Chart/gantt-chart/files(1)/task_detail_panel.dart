import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class TaskDetailPanel extends ConsumerStatefulWidget {
  const TaskDetailPanel({super.key});

  @override
  ConsumerState<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends ConsumerState<TaskDetailPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _slideAnim;
  String? _prevTaskId;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: GanttAnimations.normal);
    _slideAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
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

    if (selectedId != _prevTaskId) {
      _prevTaskId = selectedId;
      if (task != null) {
        _anim.forward(from: 0);
      } else {
        _anim.reverse();
      }
    }

    if (task == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(320 * (1 - _slideAnim.value), 0),
          child: Opacity(opacity: _slideAnim.value, child: child),
        );
      },
      child: _PanelContent(task: task),
    );
  }
}

class _PanelContent extends ConsumerStatefulWidget {
  final Task task;
  const _PanelContent({required this.task});

  @override
  ConsumerState<_PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends ConsumerState<_PanelContent> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _commentCtrl;
  bool _editingTitle = false;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description ?? '');
    _commentCtrl = TextEditingController();
  }

  @override
  void didUpdateWidget(_PanelContent old) {
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
    super.dispose();
  }

  void _saveTitle() {
    if (_titleCtrl.text.trim().isNotEmpty) {
      ref.read(tasksProvider.notifier).updateTask(
            widget.task.copyWith(
              title: _titleCtrl.text.trim(),
              updatedAt: DateTime.now(),
            ),
          );
    }
    setState(() => _editingTitle = false);
  }

  void _addComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final comment = TaskComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: 'current_user',
      authorName: 'You',
      content: text,
      timestamp: DateTime.now(),
    );
    ref.read(tasksProvider.notifier).addComment(widget.task.id, comment);
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(left: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(task),
          // Tabs
          _buildTabs(),
          const Divider(height: 1),
          // Content
          Expanded(
            child: _tabIndex == 0
                ? _buildDetailsTab(task)
                : _buildActivityTab(task),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Task task) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: task.isMilestone ? task.displayColor : task.status.color,
              shape: task.isMilestone ? BoxShape.rectangle : BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _editingTitle
                ? TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GanttTheme.textPrimary,
                    ),
                    onSubmitted: (_) => _saveTitle(),
                    autofocus: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check, size: 14),
                        onPressed: _saveTitle,
                        color: GanttTheme.success,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _editingTitle = true),
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: GanttTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () =>
                ref.read(selectedTaskIdProvider.notifier).state = null,
            color: GanttTheme.textMuted,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Tab(label: 'Details', selected: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
          const SizedBox(width: 16),
          _Tab(label: 'Activity', selected: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Task task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & Priority
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: task.status.icon,
                  label: task.status.label,
                  color: task.status.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  icon: task.priority.icon,
                  label: task.priority.label,
                  color: task.priority.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress
          _SectionLabel('Progress'),
          const SizedBox(height: 8),
          _ProgressEditor(task: task),
          const SizedBox(height: 16),

          // Dates
          _SectionLabel('Timeline'),
          const SizedBox(height: 8),
          _DateRow(label: 'Start', date: task.startDate),
          const SizedBox(height: 4),
          _DateRow(label: 'End', date: task.endDate),
          _DateRow(
              label: 'Duration',
              value: GanttDateUtils.durationLabel(task)),
          const SizedBox(height: 16),

          // Description
          _SectionLabel('Description'),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: GanttTheme.textSecondary,
              height: 1.6,
            ),
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Add a description...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: GanttTheme.surface4),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: GanttTheme.surface4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: GanttTheme.accent),
              ),
              fillColor: GanttTheme.surface2,
              filled: true,
            ),
            onChanged: (v) {
              ref.read(tasksProvider.notifier).updateTask(
                    task.copyWith(description: v, updatedAt: DateTime.now()),
                  );
            },
          ),
          const SizedBox(height: 16),

          // Assignees
          if (task.assignees.isNotEmpty) ...[
            _SectionLabel('Assignees'),
            const SizedBox(height: 8),
            ...task.assignees.map((a) => _AssigneeRow(assignee: a)),
            const SizedBox(height: 16),
          ],

          // Labels
          if (task.labels.isNotEmpty) ...[
            _SectionLabel('Labels'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: task.labels
                  .map((l) => _LabelChip(label: l, color: task.displayColor))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Dependencies
          if (task.dependencyIds.isNotEmpty) ...[
            _SectionLabel('Dependencies (${task.dependencyIds.length})'),
            const SizedBox(height: 4),
            ...task.dependencyIds.map((id) => _DependencyRow(taskId: id)),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityTab(Task task) {
    return Column(
      children: [
        Expanded(
          child: task.comments.isEmpty
              ? const Center(
                  child: Text(
                    'No comments yet',
                    style: TextStyle(
                        color: GanttTheme.textMuted, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: task.comments.length,
                  itemBuilder: (context, i) {
                    return _CommentItem(comment: task.comments[i]);
                  },
                ),
        ),
        _CommentInput(
          controller: _commentCtrl,
          onSubmit: _addComment,
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: GanttAnimations.fast,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? GanttTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? GanttTheme.accent : GanttTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: GanttTheme.headerLabel,
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressEditor extends ConsumerWidget {
  final Task task;
  const _ProgressEditor({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: task.displayColor,
                  inactiveTrackColor: GanttTheme.surface3,
                  thumbColor: task.displayColor,
                  overlayColor: task.displayColor.withOpacity(0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: task.progress,
                  min: 0,
                  max: 1,
                  onChanged: (v) {
                    ref.read(tasksProvider.notifier).updateProgress(task.id, v);
                  },
                ),
              ),
            ),
            Text(
              '${(task.progress * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: GanttTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? value;

  const _DateRow({required this.label, this.date, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: GanttTheme.labelSmall),
          ),
          Text(
            value ?? GanttDateUtils.formatShortDate(date!),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: GanttTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssigneeRow extends StatelessWidget {
  final Assignee assignee;
  const _AssigneeRow({required this.assignee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: assignee.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                assignee.initials,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            assignee.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: GanttTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  final Color color;
  const _LabelChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DependencyRow extends ConsumerWidget {
  final String taskId;
  const _DependencyRow({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final depTask = tasks.where((t) => t.id == taskId).firstOrNull;
    if (depTask == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.subdirectory_arrow_right,
              size: 12, color: GanttTheme.textMuted),
          const SizedBox(width: 4),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: depTask.status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              depTask.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: GanttTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final TaskComment comment;
  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: GanttTheme.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                comment.authorName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: GanttTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      GanttDateUtils.formatRelativeDate(comment.timestamp),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: GanttTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: GanttTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CommentInput({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: GanttTheme.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onSubmitted: (_) => onSubmit(),
              maxLines: 2,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onSubmit,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GanttTheme.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.send, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
