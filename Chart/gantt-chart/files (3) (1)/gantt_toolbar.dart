import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../features/analytics/analytics_panel.dart';
import '../../features/export/gantt_exporter.dart';
import '../../shared/theme/gantt_theme.dart';

class GanttToolbar extends ConsumerStatefulWidget {
  const GanttToolbar({super.key});
  @override
  ConsumerState<GanttToolbar> createState() => _GanttToolbarState();
}

class _GanttToolbarState extends ConsumerState<GanttToolbar> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchVisible = false;
  int _lastSearchFocusRequest = 0;
  int _lastAddTaskRequest = 0;

  @override
  void dispose() { _searchCtrl.dispose(); _searchFocus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(viewSettingsProvider);
    final filter = ref.watch(filterProvider);
    final notifier = ref.watch(tasksProvider.notifier);
    final analyticsOpen = ref.watch(analyticsOpenProvider);

    // Handle keyboard-triggered search
    final focusReq = ref.watch(searchFocusRequestProvider);
    if (focusReq != _lastSearchFocusRequest) {
      _lastSearchFocusRequest = focusReq;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _searchVisible = true);
        Future.delayed(const Duration(milliseconds: 50), () => _searchFocus.requestFocus());
      });
    }

    // Handle keyboard-triggered new task
    final addReq = ref.watch(addTaskDialogRequestProvider);
    if (addReq != _lastAddTaskRequest) {
      _lastAddTaskRequest = addReq;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAddTaskDialog(context, ref));
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(bottom: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Row(
        children: [
          // Brand
          Container(width: 28, height: 28,
            decoration: BoxDecoration(color: GanttTheme.accent, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.timeline, size: 14, color: Colors.white)),
          const SizedBox(width: 10),
          const Text('Project Timeline', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: GanttTheme.textPrimary, letterSpacing: -0.3)),
          const SizedBox(width: 20),
          _ViewModeSwitcher(current: settings.viewMode),
          const Spacer(),

          // Undo/Redo
          _ToolbarButton(icon: Icons.undo, tooltip: 'Undo (⌘Z)', onTap: notifier.canUndo ? notifier.undo : null),
          _ToolbarButton(icon: Icons.redo, tooltip: 'Redo (⌘⇧Z)', onTap: notifier.canRedo ? notifier.redo : null),
          const _VDiv(),

          // Search
          AnimatedSwitcher(
            duration: GanttAnimations.fast,
            child: _searchVisible
                ? SizedBox(width: 220,
                    child: TextField(
                      controller: _searchCtrl, focusNode: _searchFocus, autofocus: true,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: GanttTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search tasks... (Esc to close)',
                        prefixIcon: const Icon(Icons.search, size: 14),
                        suffixIcon: IconButton(icon: const Icon(Icons.close, size: 14), onPressed: _closeSearch),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (v) => ref.read(filterProvider.notifier).update((s) => s.copyWith(searchQuery: v)),
                      onSubmitted: (_) => _searchFocus.unfocus(),
                    ))
                : _ToolbarButton(icon: Icons.search, tooltip: 'Search (/)', onTap: () { setState(() => _searchVisible = true); Future.delayed(const Duration(milliseconds: 50), () => _searchFocus.requestFocus()); }),
          ),

          // Filter
          Stack(clipBehavior: Clip.none, children: [
            _ToolbarButton(icon: Icons.filter_list, tooltip: 'Filter', onTap: () => _showFilterSheet(context)),
            if (filter.isActive) Positioned(top: 4, right: 4,
              child: Container(width: 14, height: 14,
                decoration: const BoxDecoration(color: GanttTheme.accent, shape: BoxShape.circle),
                child: Center(child: Text('${filter.activeCount}', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white))))),
          ]),
          const SizedBox(width: 4),

          // Zoom
          _ToolbarButton(icon: Icons.zoom_out, tooltip: 'Zoom Out', onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(dayWidth: (s.dayWidth - 4).clamp(10.0, 100.0)))),
          _ZoomDisplay(dayWidth: settings.dayWidth),
          _ToolbarButton(icon: Icons.zoom_in, tooltip: 'Zoom In', onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(dayWidth: (s.dayWidth + 4).clamp(10.0, 100.0)))),
          const _VDiv(),

          // Toggles
          _ToolbarToggle(icon: Icons.weekend_outlined, tooltip: 'Toggle Weekends', active: settings.showWeekends, onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(showWeekends: !s.showWeekends))),
          _ToolbarToggle(icon: Icons.route, tooltip: 'Critical Path', active: settings.showCriticalPath, onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(showCriticalPath: !s.showCriticalPath))),
          _ToolbarToggle(icon: Icons.account_tree_outlined, tooltip: 'Dependencies', active: settings.showDependencies, onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(showDependencies: !s.showDependencies))),
          _ToolbarToggle(icon: Icons.compare, tooltip: 'Show Baseline', active: settings.showBaseline, onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(showBaseline: !s.showBaseline))),
          _ToolbarToggle(icon: Icons.people_outline, tooltip: 'Resource Histogram', active: settings.showResourceHistogram, onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(showResourceHistogram: !s.showResourceHistogram))),
          _ToolbarToggle(icon: Icons.bar_chart, tooltip: 'Analytics', active: analyticsOpen, onTap: () => ref.read(analyticsOpenProvider.notifier).state = !analyticsOpen),
          const _VDiv(),

          // Baseline
          _ToolbarButton(icon: Icons.bookmark_add_outlined, tooltip: 'Set Baseline', onTap: () => _showBaselineDialog(context, ref)),

          // Export
          _ToolbarButton(icon: Icons.download_outlined, tooltip: 'Export', onTap: () => _showExportMenu(context, ref)),
          const _VDiv(),

          // Add task
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context, ref),
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GanttTheme.accent, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            ),
          ),
        ],
      ),
    );
  }

  void _closeSearch() {
    setState(() => _searchVisible = false);
    _searchCtrl.clear();
    ref.read(filterProvider.notifier).update((s) => s.copyWith(searchQuery: ''));
  }

  void _showFilterSheet(BuildContext ctx) => showModalBottomSheet(
    context: ctx, backgroundColor: GanttTheme.surface2, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => const _FilterSheet(),
  );

  void _showBaselineDialog(BuildContext ctx, WidgetRef ref) => showDialog(
    context: ctx,
    builder: (_) => _BaselineDialog(onSave: (label) => ref.read(tasksProvider.notifier).setBaseline(label)),
  );

  void _showExportMenu(BuildContext ctx, WidgetRef ref) {
    final tasks = ref.read(tasksProvider);
    final (start, end) = ref.read(projectDateRangeProvider);
    showModalBottomSheet(
      context: ctx, backgroundColor: GanttTheme.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _ExportSheet(tasks: tasks, projectStart: start, projectEnd: end),
    );
  }

  void _showAddTaskDialog(BuildContext ctx, WidgetRef ref) => showDialog(
    context: ctx,
    builder: (_) => _AddTaskDialog(ref: ref),
  );
}

class _ZoomDisplay extends StatelessWidget {
  final double dayWidth;
  const _ZoomDisplay({required this.dayWidth});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 36,
    child: Text('${((dayWidth / 32.0) * 100).toInt()}%',
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500, color: GanttTheme.textMuted)),
  );
}

class _ViewModeSwitcher extends ConsumerWidget {
  final GanttViewMode current;
  const _ViewModeSwitcher({required this.current});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    height: 30, padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(color: GanttTheme.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: GanttTheme.surface4)),
    child: Row(children: GanttViewMode.values.map((mode) {
      final isActive = mode == current;
      final dayWidth = switch (mode) { GanttViewMode.day => 48.0, GanttViewMode.week => 32.0, GanttViewMode.month => 20.0, GanttViewMode.quarter => 12.0 };
      return GestureDetector(
        onTap: () => ref.read(viewSettingsProvider.notifier).update((s) => s.copyWith(viewMode: mode, dayWidth: dayWidth)),
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: isActive ? GanttTheme.accent : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          child: Text(mode.name[0].toUpperCase() + mode.name.substring(1),
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: isActive ? Colors.white : GanttTheme.textMuted)),
        ),
      );
    }).toList()),
  );
}

class _ToolbarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  const _ToolbarButton({required this.icon, required this.tooltip, this.onTap});
  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}
class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: GanttAnimations.fast, width: 32, height: 32,
          decoration: BoxDecoration(
            color: _hovered && widget.onTap != null ? GanttTheme.surface3 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 16,
            color: widget.onTap == null ? GanttTheme.textDisabled : (_hovered ? GanttTheme.textPrimary : GanttTheme.textMuted)),
        ),
      ),
    ),
  );
}

class _ToolbarToggle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;
  const _ToolbarToggle({required this.icon, required this.tooltip, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: GanttAnimations.fast, width: 32, height: 32,
        decoration: BoxDecoration(
          color: active ? GanttTheme.accentDim : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: active ? Border.all(color: GanttTheme.accent.withOpacity(0.4)) : null,
        ),
        child: Icon(icon, size: 16, color: active ? GanttTheme.accentLight : GanttTheme.textMuted),
      ),
    ),
  );
}

class _VDiv extends StatelessWidget {
  const _VDiv();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 4), color: GanttTheme.surface4);
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
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _estHoursCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(data: GanttTheme.dark, child: child!),
    );
    if (picked != null) setState(() { if (isStart) _start = picked; else _end = picked; });
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final now = DateTime.now();
    final task = Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      startDate: _start, endDate: _end,
      priority: _priority, status: _status,
      isMilestone: _isMilestone,
      estimatedHours: double.tryParse(_estHoursCtrl.text) ?? 8.0,
      createdAt: now, updatedAt: now,
    );
    widget.ref.read(tasksProvider.notifier).addTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: GanttTheme.surface2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: GanttTheme.surface4)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(width: 440,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('New Task', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: GanttTheme.textPrimary)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => Navigator.pop(context), color: GanttTheme.textMuted, padding: EdgeInsets.zero),
          ]),
          const SizedBox(height: 20),
          TextField(controller: _titleCtrl, autofocus: true,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Task title...', labelText: 'Title *'),
            onSubmitted: (_) => _submit()),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, maxLines: 2,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Optional description...', labelText: 'Description')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DateField(label: 'Start Date', date: _start, onTap: () => _pickDate(true))),
            const SizedBox(width: 12),
            Expanded(child: _DateField(label: 'End Date', date: _end, onTap: () => _pickDate(false))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DropdownButtonFormField<TaskPriority>(
              value: _priority, dropdownColor: GanttTheme.surface3,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Row(children: [Icon(p.icon, size: 14, color: p.color), const SizedBox(width: 6), Text(p.label)]))).toList(),
              onChanged: (v) => setState(() => _priority = v ?? _priority),
            )),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<TaskStatus>(
              value: _status, dropdownColor: GanttTheme.surface3,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Status'),
              items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Row(children: [Icon(s.icon, size: 14, color: s.color), const SizedBox(width: 6), Text(s.label)]))).toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            SizedBox(width: 120, child: TextField(controller: _estHoursCtrl,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Est. Hours', suffixText: 'h'),
              keyboardType: TextInputType.number)),
            const SizedBox(width: 24),
            Row(children: [
              Switch(value: _isMilestone, onChanged: (v) => setState(() => _isMilestone = v), activeColor: GanttTheme.accent),
              const SizedBox(width: 8),
              const Text('Milestone', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _submit, child: const Text('Create Task')),
          ]),
        ]),
      ),
    ),
  );
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.date, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 14)),
      child: Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textPrimary)),
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
      initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.3,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: GanttTheme.surface2, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: GanttTheme.surface4, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(children: [
              const Text('Filter Tasks', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: GanttTheme.textPrimary)),
              const Spacer(),
              if (filter.isActive) TextButton(onPressed: () { ref.read(filterProvider.notifier).state = const GanttFilter(); Navigator.pop(context); }, child: const Text('Clear all')),
            ]),
          ),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
            const Text('STATUS', style: GanttTheme.headerLabel), const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: TaskStatus.values.map((s) {
              final sel = filter.statuses.contains(s);
              return FilterChip(selected: sel, label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(s.icon, size: 10, color: s.color), const SizedBox(width: 4), Text(s.label)]),
                onSelected: (v) {
                  final n = Set<TaskStatus>.from(filter.statuses);
                  v ? n.add(s) : n.remove(s);
                  ref.read(filterProvider.notifier).update((f) => f.copyWith(statuses: n));
                });
            }).toList()),
            const SizedBox(height: 16),
            const Text('PRIORITY', style: GanttTheme.headerLabel), const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: TaskPriority.values.map((p) {
              final sel = filter.priorities.contains(p);
              return FilterChip(selected: sel, label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(p.icon, size: 10, color: p.color), const SizedBox(width: 4), Text(p.label)]),
                onSelected: (v) {
                  final n = Set<TaskPriority>.from(filter.priorities);
                  v ? n.add(p) : n.remove(p);
                  ref.read(filterProvider.notifier).update((f) => f.copyWith(priorities: n));
                });
            }).toList()),
            const SizedBox(height: 16),
            const Text('RISK LEVEL', style: GanttTheme.headerLabel), const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: RiskLevel.values.map((r) {
              final sel = filter.riskLevels.contains(r);
              return FilterChip(selected: sel, label: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(r.label)]),
                onSelected: (v) {
                  final n = Set<RiskLevel>.from(filter.riskLevels);
                  v ? n.add(r) : n.remove(r);
                  ref.read(filterProvider.notifier).update((f) => f.copyWith(riskLevels: n));
                });
            }).toList()),
            const SizedBox(height: 40),
          ])),
        ]),
      ),
    );
  }
}

// ─── Baseline Dialog ─────────────────────────────────────────────────────────

class _BaselineDialog extends StatefulWidget {
  final void Function(String label) onSave;
  const _BaselineDialog({required this.onSave});
  @override
  State<_BaselineDialog> createState() => _BaselineDialogState();
}
class _BaselineDialogState extends State<_BaselineDialog> {
  final _ctrl = TextEditingController(text: 'Baseline ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: GanttTheme.surface2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: GanttTheme.surface4)),
    child: Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: 360,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Set Baseline', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: GanttTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text('Captures current dates and progress for all tasks as a reference point.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: GanttTheme.textMuted)),
        const SizedBox(height: 16),
        TextField(controller: _ctrl, autofocus: true,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: GanttTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Baseline Label')),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () { widget.onSave(_ctrl.text.trim()); Navigator.pop(context); },
            child: const Text('Set Baseline')),
        ]),
      ]),
    )),
  );
}

// ─── Export Sheet ─────────────────────────────────────────────────────────────

class _ExportSheet extends StatelessWidget {
  final List<Task> tasks;
  final DateTime projectStart;
  final DateTime projectEnd;
  const _ExportSheet({required this.tasks, required this.projectStart, required this.projectEnd});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16, left: 150),
        decoration: BoxDecoration(color: GanttTheme.surface4, borderRadius: BorderRadius.circular(2))),
      const Text('Export', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: GanttTheme.textPrimary)),
      const SizedBox(height: 16),
      _ExportOption(
        icon: Icons.table_chart_outlined, title: 'CSV / Spreadsheet',
        subtitle: 'Export task data as comma-separated values',
        onTap: () { Navigator.pop(context); GanttExporter.exportCsv(tasks); },
      ),
      _ExportOption(
        icon: Icons.code, title: 'JSON Data',
        subtitle: 'Full structured export with all task fields',
        onTap: () { Navigator.pop(context); GanttExporter.exportJson(tasks, projectStart, projectEnd); },
      ),
      _ExportOption(
        icon: Icons.picture_as_pdf_outlined, title: 'PDF Report',
        subtitle: 'Formatted project schedule report',
        onTap: () { Navigator.pop(context); GanttExporter.exportPdf(context, tasks, projectStart, projectEnd); },
      ),
      const SizedBox(height: 8),
    ]),
  );
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ExportOption({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(8),
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: GanttTheme.surface3, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: GanttTheme.textSecondary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: GanttTheme.textPrimary)),
          Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: GanttTheme.textMuted)),
        ])),
        const Icon(Icons.chevron_right, size: 16, color: GanttTheme.textMuted),
      ]),
    ),
  );
}
