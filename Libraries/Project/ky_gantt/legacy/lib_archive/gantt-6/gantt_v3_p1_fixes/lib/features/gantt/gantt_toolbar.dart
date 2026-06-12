import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/task_validator.dart';
import '../../features/analytics/analytics_panel.dart';
import '../../features/export/gantt_exporter.dart';
import '../../shared/theme/gantt_theme.dart';
import '../portfolio/portfolio_view.dart';
import '../portfolio/role_access_control.dart';

class GanttToolbar extends ConsumerStatefulWidget {
  const GanttToolbar({super.key});
  @override
  ConsumerState<GanttToolbar> createState() => _GanttToolbarState();
}

class _GanttToolbarState extends ConsumerState<GanttToolbar> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchVisible = false;
  int _lastSearchFocusReq = 0;
  int _lastAddTaskReq = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(viewSettingsProvider);
    final filter = ref.watch(filterProvider);
    final notifier = ref.watch(tasksProvider.notifier);
    final analyticsOpen = ref.watch(analyticsOpenProvider);
    final auditOpen = ref.watch(auditPanelOpenProvider);
    final snapshotOpen = ref.watch(snapshotPanelOpenProvider);
    final multiSel = ref.watch(multiSelectProvider);

    // Keyboard-triggered search
    final focusReq = ref.watch(searchFocusRequestProvider);
    if (focusReq != _lastSearchFocusReq) {
      _lastSearchFocusReq = focusReq;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _searchVisible = true);
        Future.delayed(const Duration(milliseconds: 50),
            () => _searchFocus.requestFocus());
      });
    }

    // Keyboard-triggered new task
    final addReq = ref.watch(addTaskDialogRequestProvider);
    if (addReq != _lastAddTaskReq) {
      _lastAddTaskReq = addReq;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showAddTaskDialog(context, ref));
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(bottom: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Row(children: [
        // Brand
        Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: GanttTheme.accent,
                borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.timeline, size: 14, color: Colors.white)),
        const SizedBox(width: 10),
        const Text('Project Timeline',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GanttTheme.textPrimary,
                letterSpacing: -0.3)),
        const SizedBox(width: 20),

        _ViewModeSwitcher(current: settings.viewMode),
        const Spacer(),

        // Multi-select action bar (shows when items selected)
        if (multiSel.isNotEmpty) ...[
          _MultiSelectBar(count: multiSel.length),
          const _VDiv(),
        ],

        // Undo/Redo
        _ToolbarButton(
            icon: Icons.undo,
            tooltip: 'Undo (⌘Z)',
            onTap: notifier.canUndo ? notifier.undo : null),
        _ToolbarButton(
            icon: Icons.redo,
            tooltip: 'Redo (⌘⇧Z)',
            onTap: notifier.canRedo ? notifier.redo : null),
        const _VDiv(),

        // Search
        AnimatedSwitcher(
          duration: GanttAnimations.fast,
          child: _searchVisible
              ? SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: 12, color: GanttTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search tasks… (Esc to close)',
                      prefixIcon: const Icon(Icons.search, size: 14),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          onPressed: _closeSearch),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (v) => ref
                        .read(filterProvider.notifier)
                        .update((s) => s.copyWith(searchQuery: v)),
                  ))
              : _ToolbarButton(
                  icon: Icons.search,
                  tooltip: 'Search (/)',
                  onTap: () {
                    setState(() => _searchVisible = true);
                    Future.delayed(const Duration(milliseconds: 50),
                        () => _searchFocus.requestFocus());
                  }),
        ),

        // Filter
        Stack(clipBehavior: Clip.none, children: [
          _ToolbarButton(
              icon: Icons.filter_list,
              tooltip: 'Filter',
              onTap: () => _showFilterSheet(context)),
          if (filter.isActive)
            Positioned(
                top: 4,
                right: 4,
                child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                        color: GanttTheme.accent, shape: BoxShape.circle),
                    child: Center(
                        child: Text('${filter.activeCount}',
                            style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white))))),
        ]),
        const SizedBox(width: 4),

        // Jump to today
        _ToolbarButton(
            icon: Icons.today,
            tooltip: 'Jump to Today (Home)',
            onTap: () => ref.read(scrollToTodayProvider.notifier).state++),
        const _VDiv(),

        // Zoom
        _ToolbarButton(
            icon: Icons.zoom_out,
            tooltip: 'Zoom Out (Ctrl+Scroll)',
            onTap: () => ref.read(viewSettingsProvider.notifier).update((s) =>
                s.copyWith(dayWidth: (s.dayWidth - 4).clamp(8.0, 120.0)))),
        _ZoomDisplay(dayWidth: settings.dayWidth),
        _ToolbarButton(
            icon: Icons.zoom_in,
            tooltip: 'Zoom In (Ctrl+Scroll)',
            onTap: () => ref.read(viewSettingsProvider.notifier).update((s) =>
                s.copyWith(dayWidth: (s.dayWidth + 4).clamp(8.0, 120.0)))),
        const _VDiv(),

        // View toggles
        _ToolbarToggle(
            icon: Icons.weekend_outlined,
            tooltip: 'Weekends',
            active: settings.showWeekends,
            onTap: () => ref
                .read(viewSettingsProvider.notifier)
                .update((s) => s.copyWith(showWeekends: !s.showWeekends))),
        _ToolbarToggle(
            icon: Icons.route,
            tooltip: 'Critical Path',
            active: settings.showCriticalPath,
            onTap: () => ref.read(viewSettingsProvider.notifier).update(
                (s) => s.copyWith(showCriticalPath: !s.showCriticalPath))),
        _ToolbarToggle(
            icon: Icons.account_tree_outlined,
            tooltip: 'Dependencies',
            active: settings.showDependencies,
            onTap: () => ref.read(viewSettingsProvider.notifier).update(
                (s) => s.copyWith(showDependencies: !s.showDependencies))),
        _ToolbarToggle(
            icon: Icons.compare,
            tooltip: 'Show Baseline',
            active: settings.showBaseline,
            onTap: () => ref
                .read(viewSettingsProvider.notifier)
                .update((s) => s.copyWith(showBaseline: !s.showBaseline))),
        _ToolbarToggle(
            icon: Icons.people_outline,
            tooltip: 'Resource Histogram',
            active: settings.showResourceHistogram,
            onTap: () => ref.read(viewSettingsProvider.notifier).update((s) =>
                s.copyWith(showResourceHistogram: !s.showResourceHistogram))),
        _ToolbarToggle(
            icon: Icons.auto_fix_high,
            tooltip: 'Auto-Schedule',
            active: settings.autoScheduleEnabled,
            onTap: () => ref.read(viewSettingsProvider.notifier).update((s) =>
                s.copyWith(autoScheduleEnabled: !s.autoScheduleEnabled))),
        const _VDiv(),

        // Swimlane grouping
        _SwimlaneButton(current: settings.swimlaneGroupBy),
        const _VDiv(),

        // Panels
        _ToolbarToggle(
            icon: Icons.bar_chart,
            tooltip: 'Analytics',
            active: analyticsOpen,
            onTap: () => ref.read(analyticsOpenProvider.notifier).state =
                !analyticsOpen),
        _ToolbarToggle(
            icon: Icons.history,
            tooltip: 'Audit Log',
            active: auditOpen,
            onTap: () =>
                ref.read(auditPanelOpenProvider.notifier).state = !auditOpen),
        _ToolbarToggle(
            icon: Icons.camera_alt_outlined,
            tooltip: 'Snapshots',
            active: snapshotOpen,
            onTap: () => ref.read(snapshotPanelOpenProvider.notifier).state =
                !snapshotOpen),

        // Resource leveling
        _ToolbarButton(
            icon: Icons.balance,
            tooltip: 'Level Resources',
            onTap: () => _showLevelResourcesConfirm(context, ref)),

        // Baseline
        _ToolbarButton(
            icon: Icons.bookmark_add_outlined,
            tooltip: 'Set Baseline',
            onTap: () => _showBaselineDialog(context, ref)),

        // Export
        _ToolbarButton(
            icon: Icons.download_outlined,
            tooltip: 'Export',
            onTap: () => _showExportMenu(context, ref)),
        const _VDiv(),

        // Add task
        ElevatedButton.icon(
          onPressed: () => _showAddTaskDialog(context, ref),
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Add Task'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GanttTheme.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            minimumSize: const Size(0, 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
        ),
      ]),
    );
  }

  void _closeSearch() {
    setState(() => _searchVisible = false);
    _searchCtrl.clear();
    ref
        .read(filterProvider.notifier)
        .update((s) => s.copyWith(searchQuery: ''));
  }

  void _showFilterSheet(BuildContext ctx) => showModalBottomSheet(
        context: ctx,
        backgroundColor: GanttTheme.surface2,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => const _FilterSheet(),
      );

  void _showBaselineDialog(BuildContext ctx, WidgetRef ref) => showDialog(
        context: ctx,
        builder: (_) => _BaselineDialog(
            onSave: (label) =>
                ref.read(tasksProvider.notifier).setBaseline(label)),
      );

  void _showLevelResourcesConfirm(BuildContext ctx, WidgetRef ref) =>
      showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          backgroundColor: GanttTheme.surface2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: GanttTheme.surface4)),
          title: const Row(children: [
            Icon(Icons.balance, size: 18, color: GanttTheme.accent),
            SizedBox(width: 8),
            Text('Level Resources',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
          ]),
          content: const Text(
              'This will shift lower-priority tasks to resolve resource overloads.\n\nCritical path tasks and locked tasks are preserved.\n\nThe operation can be undone with Ctrl+Z.',
              style: TextStyle(fontSize: 13, color: GanttTheme.textSecondary)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(tasksProvider.notifier).levelResources();
              },
              child: const Text('Level Resources'),
            ),
          ],
        ),
      );

  void _showExportMenu(BuildContext ctx, WidgetRef ref) {
    final tasks = ref.read(tasksProvider);
    final (start, end) = ref.read(projectDateRangeProvider);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: GanttTheme.surface2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) =>
          _ExportSheet(tasks: tasks, projectStart: start, projectEnd: end),
    );
  }

  void _showAddTaskDialog(BuildContext ctx, WidgetRef ref) => showDialog(
        context: ctx,
        builder: (_) => _AddTaskDialog(ref: ref),
      );
}

// ─── Multi-select action bar ───────────────────────────────────────────────────
class _MultiSelectBar extends ConsumerWidget {
  final int count;
  const _MultiSelectBar({required this.count});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: GanttTheme.accentDim,
              borderRadius: BorderRadius.circular(6)),
          child: Text('$count selected',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.accentLight)),
        ),
        const SizedBox(width: 4),
        _ToolbarButton(
            icon: Icons.delete_outline,
            tooltip: 'Delete selected',
            onTap: () {
              final ids = ref.read(multiSelectProvider).toList();
              for (final id in ids)
                ref.read(tasksProvider.notifier).deleteTask(id);
              ref.read(multiSelectProvider.notifier).state = {};
            }),
        _ToolbarButton(
            icon: Icons.close,
            tooltip: 'Clear selection',
            onTap: () => ref.read(multiSelectProvider.notifier).state = {}),
      ]);
}

// ─── Swimlane button ───────────────────────────────────────────────────────────
class _SwimlaneButton extends ConsumerWidget {
  final SwimlanGroupBy current;
  const _SwimlaneButton({required this.current});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = {
      SwimlanGroupBy.none: 'Group By',
      SwimlanGroupBy.assignee: 'Assignee',
      SwimlanGroupBy.status: 'Status',
      SwimlanGroupBy.priority: 'Priority',
      SwimlanGroupBy.label: 'Label',
    };
    return PopupMenuButton<SwimlanGroupBy>(
      tooltip: 'Swimlane grouping',
      color: GanttTheme.surface3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: GanttTheme.surface4)),
      initialValue: current,
      onSelected: (v) => ref
          .read(viewSettingsProvider.notifier)
          .update((s) => s.copyWith(swimlaneGroupBy: v)),
      itemBuilder: (_) => SwimlanGroupBy.values
          .map((v) => PopupMenuItem(
                value: v,
                child: Row(children: [
                  Icon(v == current ? Icons.check : Icons.circle_outlined,
                      size: 12,
                      color: v == current
                          ? GanttTheme.accent
                          : GanttTheme.textMuted),
                  const SizedBox(width: 8),
                  Text(labels[v]!,
                      style: TextStyle(
                          fontSize: 12,
                          color: v == current
                              ? GanttTheme.accent
                              : GanttTheme.textPrimary)),
                ]),
              ))
          .toList(),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: current != SwimlanGroupBy.none
              ? GanttTheme.accentDim
              : GanttTheme.surface2,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
              color: current != SwimlanGroupBy.none
                  ? GanttTheme.accent
                  : GanttTheme.surface4),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.view_column_outlined,
              size: 13,
              color: current != SwimlanGroupBy.none
                  ? GanttTheme.accentLight
                  : GanttTheme.textMuted),
          const SizedBox(width: 5),
          Text(labels[current]!,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: current != SwimlanGroupBy.none
                      ? GanttTheme.accentLight
                      : GanttTheme.textMuted)),
          const SizedBox(width: 3),
          Icon(Icons.expand_more,
              size: 12,
              color: current != SwimlanGroupBy.none
                  ? GanttTheme.accentLight
                  : GanttTheme.textMuted),
        ]),
      ),
    );
  }
}

// ─── Shared toolbar widgets ────────────────────────────────────────────────────
class _ZoomDisplay extends StatelessWidget {
  final double dayWidth;
  const _ZoomDisplay({required this.dayWidth});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 40,
        child: Text('${((dayWidth / 32.0) * 100).toInt()}%',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: GanttTheme.textMuted)),
      );
}

class _ViewModeSwitcher extends ConsumerWidget {
  final GanttViewMode current;
  const _ViewModeSwitcher({required this.current});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        height: 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: GanttTheme.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GanttTheme.surface4)),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: GanttViewMode.values.map((mode) {
              final selected = current == mode;
              final label = mode.name[0].toUpperCase() + mode.name.substring(1);
              return GestureDetector(
                onTap: () => ref
                    .read(viewSettingsProvider.notifier)
                    .update((s) => s.copyWith(viewMode: mode)),
                child: AnimatedContainer(
                  duration: GanttAnimations.fast,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? GanttTheme.surface3 : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? GanttTheme.textPrimary
                              : GanttTheme.textMuted)),
                ),
              );
            }).toList()),
      );
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  const _ToolbarButton({required this.icon, required this.tooltip, this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
            child: Icon(icon,
                size: 16,
                color: onTap == null
                    ? GanttTheme.textDisabled
                    : GanttTheme.textSecondary),
          ),
        ),
      );
}

class _ToolbarToggle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;
  const _ToolbarToggle(
      {required this.icon,
      required this.tooltip,
      required this.active,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: GanttAnimations.fast,
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: active ? GanttTheme.accentDim : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon,
                size: 16,
                color: active ? GanttTheme.accentLight : GanttTheme.textMuted),
          ),
        ),
      );
}

class _VDiv extends StatelessWidget {
  const _VDiv();
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: GanttTheme.surface4);
}

// ─── Add Task Dialog ──────────────────────────────────────────────────────────
class _AddTaskDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddTaskDialog({required this.ref});
  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _estHoursCtrl = TextEditingController(text: '8');
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 7));
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  bool _isMilestone = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _estHoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final p = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(data: GanttTheme.dark, child: child!),
    );
    if (p != null)
      setState(() {
        if (isStart)
          _start = p;
        else
          _end = p;
      });
  }

  String? _titleError;
  String? _dateError;
  String? _hoursError;

  void _submit() {
    final now = DateTime.now();
    final task = Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      startDate: _start,
      endDate: _end,
      priority: _priority,
      status: _status,
      isMilestone: _isMilestone,
      estimatedHours: double.tryParse(_estHoursCtrl.text) ?? 8.0,
      createdAt: now,
      updatedAt: now,
    );

    final result = widget.ref.read(tasksProvider.notifier).addTask(task);

    if (result.isValid) {
      Navigator.pop(context);
    } else {
      setState(() {
        _titleError = result.errorFor('title');
        _dateError = result.errorFor('endDate');
        _hoursError = result.errorFor('estimatedHours');
      });
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: GanttTheme.surface2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GanttTheme.surface4)),
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 440,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('New Task',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: GanttTheme.textPrimary)),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: GanttTheme.textMuted,
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context)),
                    ]),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _titleCtrl,
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 13, color: GanttTheme.textPrimary),
                        onChanged: (_) => setState(() => _titleError = null),
                        decoration: InputDecoration(
                          hintText: 'Task title…',
                          labelText: 'Title *',
                          errorText: _titleError,
                          errorStyle: const TextStyle(
                              fontSize: 10, color: GanttTheme.danger),
                        ),
                        onSubmitted: (_) => _submit()),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _descCtrl,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 13, color: GanttTheme.textPrimary),
                        decoration: const InputDecoration(
                            hintText: 'Optional description…',
                            labelText: 'Description')),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _DateField(
                              label: 'Start Date',
                              date: _start,
                              onTap: () => _pickDate(true))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _DateField(
                              label: 'End Date',
                              date: _end,
                              onTap: () {
                                _pickDate(false);
                                setState(() => _dateError = null);
                              })),
                    ]),
                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(_dateError!,
                            style: const TextStyle(
                                fontSize: 10, color: GanttTheme.danger)),
                      ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: DropdownButtonFormField<TaskPriority>(
                        value: _priority,
                        dropdownColor: GanttTheme.surface3,
                        style: const TextStyle(
                            fontSize: 13, color: GanttTheme.textPrimary),
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
                        items: TaskPriority.values
                            .map((p) => DropdownMenuItem(
                                value: p,
                                child: Row(children: [
                                  Icon(p.icon, size: 13, color: p.color),
                                  const SizedBox(width: 6),
                                  Text(p.label),
                                ])))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _priority = v ?? _priority),
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: DropdownButtonFormField<TaskStatus>(
                        value: _status,
                        dropdownColor: GanttTheme.surface3,
                        style: const TextStyle(
                            fontSize: 13, color: GanttTheme.textPrimary),
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: TaskStatus.values
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Row(children: [
                                  Icon(s.icon, size: 13, color: s.color),
                                  const SizedBox(width: 6),
                                  Text(s.label),
                                ])))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _status = v ?? _status),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      SizedBox(
                          width: 120,
                          child: TextField(
                              controller: _estHoursCtrl,
                              style: const TextStyle(
                                  fontSize: 13, color: GanttTheme.textPrimary),
                              onChanged: (_) =>
                                  setState(() => _hoursError = null),
                              decoration: InputDecoration(
                                labelText: 'Est. Hours',
                                suffixText: 'h',
                                errorText: _hoursError,
                                errorStyle: const TextStyle(
                                    fontSize: 10, color: GanttTheme.danger),
                              ),
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 24),
                      Row(children: [
                        Switch(
                            value: _isMilestone,
                            onChanged: (v) => setState(() => _isMilestone = v),
                            activeColor: GanttTheme.accent),
                        const SizedBox(width: 8),
                        const Text('Milestone',
                            style: TextStyle(
                                fontSize: 13, color: GanttTheme.textSecondary)),
                      ]),
                    ]),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: _submit, child: const Text('Create Task')),
                    ]),
                  ]),
            )),
      );
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateField(
      {required this.label, required this.date, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
              labelText: label,
              suffixIcon: const Icon(Icons.calendar_today, size: 14)),
          child: Text('${date.day}/${date.month}/${date.year}',
              style:
                  const TextStyle(fontSize: 13, color: GanttTheme.textPrimary)),
        ),
      );
}

// ─── Filter Sheet ─────────────────────────────────────────────────────────────
class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
            color: GanttTheme.surface2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: GanttTheme.surface4,
                  borderRadius: BorderRadius.circular(2))),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(children: [
                const Text('Filter Tasks',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: GanttTheme.textPrimary)),
                const Spacer(),
                if (filter.isActive)
                  TextButton(
                      onPressed: () {
                        ref.read(filterProvider.notifier).state =
                            const GanttFilter();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear all')),
              ])),
          Expanded(
              child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                const Text('STATUS', style: GanttTheme.headerLabel),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: TaskStatus.values.map((s) {
                      final sel = filter.statuses.contains(s);
                      return FilterChip(
                          selected: sel,
                          label: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(s.icon, size: 10, color: s.color),
                            const SizedBox(width: 4),
                            Text(s.label)
                          ]),
                          onSelected: (v) {
                            final n = Set<TaskStatus>.from(filter.statuses);
                            v ? n.add(s) : n.remove(s);
                            ref
                                .read(filterProvider.notifier)
                                .update((f) => f.copyWith(statuses: n));
                          });
                    }).toList()),
                const SizedBox(height: 16),
                const Text('PRIORITY', style: GanttTheme.headerLabel),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: TaskPriority.values.map((p) {
                      final sel = filter.priorities.contains(p);
                      return FilterChip(
                          selected: sel,
                          label: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(p.icon, size: 10, color: p.color),
                            const SizedBox(width: 4),
                            Text(p.label)
                          ]),
                          onSelected: (v) {
                            final n = Set<TaskPriority>.from(filter.priorities);
                            v ? n.add(p) : n.remove(p);
                            ref
                                .read(filterProvider.notifier)
                                .update((f) => f.copyWith(priorities: n));
                          });
                    }).toList()),
                const SizedBox(height: 16),
                const Text('RISK LEVEL', style: GanttTheme.headerLabel),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: RiskLevel.values.map((r) {
                      final sel = filter.riskLevels.contains(r);
                      return FilterChip(
                          selected: sel,
                          label: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: r.color, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(r.label)
                          ]),
                          onSelected: (v) {
                            final n = Set<RiskLevel>.from(filter.riskLevels);
                            v ? n.add(r) : n.remove(r);
                            ref
                                .read(filterProvider.notifier)
                                .update((f) => f.copyWith(riskLevels: n));
                          });
                    }).toList()),
                const SizedBox(height: 40),
              ])),
        ]),
      ),
    );
  }
}

// ─── Baseline Dialog ──────────────────────────────────────────────────────────
class _BaselineDialog extends StatefulWidget {
  final void Function(String) onSave;
  const _BaselineDialog({required this.onSave});
  @override
  State<_BaselineDialog> createState() => _BaselineDialogState();
}

class _BaselineDialogState extends State<_BaselineDialog> {
  final _ctrl = TextEditingController(
      text:
          'Baseline ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: GanttTheme.surface2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GanttTheme.surface4)),
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 360,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Set Baseline',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GanttTheme.textPrimary)),
                    const SizedBox(height: 8),
                    const Text(
                        'Captures current dates and progress for all tasks as a reference point.',
                        style: TextStyle(
                            fontSize: 12, color: GanttTheme.textMuted)),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _ctrl,
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 13, color: GanttTheme.textPrimary),
                        decoration:
                            const InputDecoration(labelText: 'Baseline Label')),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: () {
                            widget.onSave(_ctrl.text.trim());
                            Navigator.pop(context);
                          },
                          child: const Text('Set Baseline')),
                    ]),
                  ]),
            )),
      );
}

// ─── Export Sheet ─────────────────────────────────────────────────────────────
class _ExportSheet extends StatelessWidget {
  final List<Task> tasks;
  final DateTime projectStart, projectEnd;
  const _ExportSheet(
      {required this.tasks,
      required this.projectStart,
      required this.projectEnd});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: GanttTheme.surface4,
                          borderRadius: BorderRadius.circular(2)))),
              const Text('Export',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: GanttTheme.textPrimary)),
              const SizedBox(height: 16),
              _ExportOption(
                  icon: Icons.table_chart_outlined,
                  title: 'CSV / Spreadsheet',
                  subtitle: 'Export task data as comma-separated values',
                  onTap: () {
                    Navigator.pop(context);
                    GanttExporter.exportCsv(context, tasks);
                  }),
              _ExportOption(
                  icon: Icons.code,
                  title: 'JSON Data',
                  subtitle: 'Full structured export with all task fields',
                  onTap: () {
                    Navigator.pop(context);
                    GanttExporter.exportJson(
                        context, tasks, projectStart, projectEnd);
                  }),
              _ExportOption(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'PDF Report',
                  subtitle: 'Formatted project schedule report',
                  onTap: () {
                    Navigator.pop(context);
                    GanttExporter.exportPdf(
                        context, tasks, projectStart, projectEnd);
                  }),
              const SizedBox(height: 8),
            ]),
      );
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ExportOption(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: GanttTheme.surface3,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: GanttTheme.textSecondary)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: GanttTheme.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: GanttTheme.textMuted)),
                ])),
            const Icon(Icons.chevron_right,
                size: 16, color: GanttTheme.textMuted),
          ]),
        ),
      );
}

// ─── Annotations toolbar button ───────────────────────────────────────────────

class _AnnotationsToolbarButton extends ConsumerWidget {
  const _AnnotationsToolbarButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annotations = ref.watch(annotationsProvider);
    return Tooltip(
      message: 'Timeline Annotations',
      child: Badge(
        isLabelVisible: annotations.isNotEmpty,
        label: Text('${annotations.length}'),
        child: IconButton(
          icon: const Icon(Icons.flag_outlined, size: 14),
          color: GanttTheme.textMuted,
          onPressed: () => _showAnnotationsPanel(context, ref),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ),
    );
  }

  void _showAnnotationsPanel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AnnotationsDialog(),
    );
  }
}

class _AnnotationsDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annotations = ref.watch(annotationsProvider);
    return AlertDialog(
      backgroundColor: GanttTheme.surface2,
      title: Row(children: [
        const Text('Timeline Annotations',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GanttTheme.textPrimary)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add, size: 16),
          color: GanttTheme.accentLight,
          tooltip: 'Add annotation',
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const AddAnnotationDialog(),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ]),
      content: SizedBox(
        width: 380,
        height: 320,
        child: annotations.isEmpty
            ? const Center(
                child: Text(
                    'No annotations yet.\nClick + to add milestone markers.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12, color: GanttTheme.textMuted)))
            : ListView.separated(
                itemCount: annotations.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: GanttTheme.surface4),
                itemBuilder: (_, i) {
                  final a = annotations[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(a.icon, size: 16, color: a.displayColor),
                    title: Text(a.label,
                        style: const TextStyle(
                            fontSize: 12, color: GanttTheme.textPrimary)),
                    subtitle: Text(GanttDateUtils.formatShortDate(a.date),
                        style: const TextStyle(
                            fontSize: 10, color: GanttTheme.textMuted)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 13),
                        color: GanttTheme.textMuted,
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => AddAnnotationDialog(existing: a),
                        ),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 13),
                        color: GanttTheme.danger,
                        onPressed: () =>
                            ref.read(annotationsProvider.notifier).remove(a.id),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                    ]),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}
