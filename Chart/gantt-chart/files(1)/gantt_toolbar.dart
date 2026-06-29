import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../shared/theme/gantt_theme.dart';

class GanttToolbar extends ConsumerStatefulWidget {
  const GanttToolbar({super.key});

  @override
  ConsumerState<GanttToolbar> createState() => _GanttToolbarState();
}

class _GanttToolbarState extends ConsumerState<GanttToolbar> {
  final _searchCtrl = TextEditingController();
  bool _searchVisible = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(viewSettingsProvider);
    final filter = ref.watch(filterProvider);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(bottom: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Row(
        children: [
          // Logo / Project name
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: GanttTheme.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.timeline,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Project Timeline',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // View mode switcher
          _ViewModeSwitcher(current: settings.viewMode),

          const Spacer(),

          // Search
          AnimatedSwitcher(
            duration: GanttAnimations.fast,
            child: _searchVisible
                ? SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: GanttTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search, size: 14),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          onPressed: () {
                            setState(() => _searchVisible = false);
                            _searchCtrl.clear();
                            ref
                                .read(filterProvider.notifier)
                                .update((s) => s.copyWith(searchQuery: ''));
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        ref
                            .read(filterProvider.notifier)
                            .update((s) => s.copyWith(searchQuery: v));
                      },
                    ),
                  )
                : _ToolbarButton(
                    icon: Icons.search,
                    tooltip: 'Search',
                    onTap: () => setState(() => _searchVisible = true),
                  ),
          ),

          const SizedBox(width: 4),

          // Filter button with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _ToolbarButton(
                icon: Icons.filter_list,
                tooltip: 'Filter',
                onTap: () => _showFilterSheet(context),
              ),
              if (filter.isActive)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: GanttTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${filter.activeCount}',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 4),

          // Zoom controls
          _ToolbarButton(
            icon: Icons.zoom_out,
            tooltip: 'Zoom Out',
            onTap: () {
              ref.read(viewSettingsProvider.notifier).update(
                    (s) => s.copyWith(
                      dayWidth: (s.dayWidth - 4).clamp(16.0, 80.0),
                    ),
                  );
            },
          ),
          _ToolbarButton(
            icon: Icons.zoom_in,
            tooltip: 'Zoom In',
            onTap: () {
              ref.read(viewSettingsProvider.notifier).update(
                    (s) => s.copyWith(
                      dayWidth: (s.dayWidth + 4).clamp(16.0, 80.0),
                    ),
                  );
            },
          ),

          const SizedBox(width: 4),
          _VerticalDivider(),
          const SizedBox(width: 4),

          // Toggle weekends
          _ToolbarToggle(
            icon: Icons.weekend_outlined,
            tooltip: 'Toggle Weekends',
            active: settings.showWeekends,
            onTap: () {
              ref.read(viewSettingsProvider.notifier).update(
                    (s) => s.copyWith(showWeekends: !s.showWeekends),
                  );
            },
          ),

          // Toggle critical path
          _ToolbarToggle(
            icon: Icons.route,
            tooltip: 'Critical Path',
            active: settings.showCriticalPath,
            onTap: () {
              ref.read(viewSettingsProvider.notifier).update(
                    (s) => s.copyWith(showCriticalPath: !s.showCriticalPath),
                  );
            },
          ),

          // Toggle dependencies
          _ToolbarToggle(
            icon: Icons.account_tree_outlined,
            tooltip: 'Dependencies',
            active: settings.showDependencies,
            onTap: () {
              ref.read(viewSettingsProvider.notifier).update(
                    (s) => s.copyWith(showDependencies: !s.showDependencies),
                  );
            },
          ),

          const SizedBox(width: 4),
          _VerticalDivider(),
          const SizedBox(width: 4),

          // Add task
          _AddTaskButton(),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GanttTheme.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _ViewModeSwitcher extends ConsumerWidget {
  final GanttViewMode current;
  const _ViewModeSwitcher({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: GanttTheme.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GanttTheme.surface4),
      ),
      child: Row(
        children: GanttViewMode.values.map((mode) {
          final isActive = mode == current;
          return GestureDetector(
            onTap: () {
              double dayWidth;
              switch (mode) {
                case GanttViewMode.day:
                  dayWidth = 48;
                  break;
                case GanttViewMode.week:
                  dayWidth = 32;
                  break;
                case GanttViewMode.month:
                  dayWidth = 20;
                  break;
                case GanttViewMode.quarter:
                  dayWidth = 12;
                  break;
              }
              ref.read(viewSettingsProvider.notifier).update(
                    (s) => s.copyWith(viewMode: mode, dayWidth: dayWidth),
                  );
            },
            child: AnimatedContainer(
              duration: GanttAnimations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? GanttTheme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                mode.name[0].toUpperCase() + mode.name.substring(1),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? Colors.white
                      : GanttTheme.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: GanttAnimations.fast,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hovered ? GanttTheme.surface3 : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered ? GanttTheme.textPrimary : GanttTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarToggle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  const _ToolbarToggle({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? GanttTheme.accentDim : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: active
                ? Border.all(color: GanttTheme.accent.withOpacity(0.4))
                : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: active ? GanttTheme.accentLight : GanttTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 20,
        color: GanttTheme.surface4,
      );
}

class _AddTaskButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _showAddTaskDialog(context, ref),
      icon: const Icon(Icons.add, size: 14),
      label: const Text('Add Task'),
      style: ElevatedButton.styleFrom(
        backgroundColor: GanttTheme.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddTaskDialog(ref: ref),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddTaskDialog({required this.ref});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 7));
  TaskPriority _priority = TaskPriority.medium;
  bool _isMilestone = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final now = DateTime.now();
    final task = Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      startDate: _start,
      endDate: _end,
      priority: _priority,
      isMilestone: _isMilestone,
      status: TaskStatus.todo,
      createdAt: now,
      updatedAt: now,
    );
    widget.ref.read(tasksProvider.notifier).addTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: GanttTheme.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GanttTheme.surface4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Task',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: GanttTheme.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Task title...',
                  labelText: 'Title',
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      value: _priority,
                      dropdownColor: GanttTheme.surface3,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: GanttTheme.textPrimary,
                      ),
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: TaskPriority.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Icon(p.icon, size: 14, color: p.color),
                              const SizedBox(width: 6),
                              Text(p.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _priority = v ?? _priority),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Milestone',
                          style: TextStyle(
                            fontSize: 11,
                            color: GanttTheme.textMuted,
                          )),
                      Switch(
                        value: _isMilestone,
                        onChanged: (v) => setState(() => _isMilestone = v),
                        activeColor: GanttTheme.accent,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Create Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (filter.isActive)
                TextButton(
                  onPressed: () {
                    ref.read(filterProvider.notifier).state = const GanttFilter();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear all'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Status', style: GanttTheme.headerLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: TaskStatus.values.map((s) {
              final isSelected = filter.statuses.contains(s);
              return FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.icon, size: 10, color: s.color),
                    const SizedBox(width: 4),
                    Text(s.label),
                  ],
                ),
                onSelected: (v) {
                  final newStatuses = Set<TaskStatus>.from(filter.statuses);
                  v ? newStatuses.add(s) : newStatuses.remove(s);
                  ref.read(filterProvider.notifier).update(
                        (f) => f.copyWith(statuses: newStatuses),
                      );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Priority', style: GanttTheme.headerLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: TaskPriority.values.map((p) {
              final isSelected = filter.priorities.contains(p);
              return FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(p.icon, size: 10, color: p.color),
                    const SizedBox(width: 4),
                    Text(p.label),
                  ],
                ),
                onSelected: (v) {
                  final newP = Set<TaskPriority>.from(filter.priorities);
                  v ? newP.add(p) : newP.remove(p);
                  ref.read(filterProvider.notifier).update(
                        (f) => f.copyWith(priorities: newP),
                      );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
