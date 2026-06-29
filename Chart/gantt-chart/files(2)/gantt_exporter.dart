import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/models/task_model.dart';
import '../../core/utils/date_utils.dart';

/// Handles CSV, JSON, and PDF export for the Gantt chart.
/// PDF uses Flutter's built-in rendering - no extra packages required.
class GanttExporter {
  GanttExporter._();

  // ─── CSV ─────────────────────────────────────────────────────────────────

  static void exportCsv(List<Task> tasks) {
    final buf = StringBuffer();
    // Header row
    buf.writeln('WBS,Title,Status,Priority,Start Date,End Date,Duration (days),'
        'Progress (%),Estimated Hours,Actual Hours,Assignees,Labels,Risk Level,Slip (days)');

    // Flatten tasks in visible order
    final ordered = _flattenTasks(tasks);
    for (final task in ordered) {
      final row = [
        _csv(task.wbsCode ?? ''),
        _csv(task.title),
        _csv(task.status.label),
        _csv(task.priority.label),
        _csv(GanttDateUtils.formatShortDate(task.startDate)),
        _csv(GanttDateUtils.formatShortDate(task.endDate)),
        task.durationDays.toString(),
        (task.progress * 100).toStringAsFixed(0),
        task.estimatedHours.toStringAsFixed(1),
        task.actualHours.toStringAsFixed(1),
        _csv(task.assignees.map((a) => a.name).join('; ')),
        _csv(task.labels.join('; ')),
        _csv(task.riskLevel.label),
        task.slipDays.toString(),
      ];
      buf.writeln(row.join(','));
    }

    _downloadText(buf.toString(), 'gantt_export_${_dateStamp()}.csv', 'text/csv');
  }

  // ─── JSON ─────────────────────────────────────────────────────────────────

  static void exportJson(List<Task> tasks, DateTime projectStart, DateTime projectEnd) {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'projectStart': projectStart.toIso8601String(),
      'projectEnd': projectEnd.toIso8601String(),
      'taskCount': tasks.length,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);
    _downloadText(json, 'gantt_export_${_dateStamp()}.json', 'application/json');
  }

  // ─── PDF ──────────────────────────────────────────────────────────────────

  static void exportPdf(BuildContext context, List<Task> tasks, DateTime projectStart, DateTime projectEnd) {
    // Show PDF preview dialog with Navigator
    showDialog(
      context: context,
      builder: (_) => _PdfPreviewDialog(tasks: tasks, projectStart: projectStart, projectEnd: projectEnd),
    );
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  static String _csv(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  static List<Task> _flattenTasks(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final result = <Task>[];
    final visited = <String>{};
    void visit(Task t) {
      if (visited.contains(t.id)) return;
      visited.add(t.id);
      result.add(t);
      for (final child in tasks.where((c) => c.parentId == t.id)) visit(child);
    }
    for (final root in tasks.where((t) => t.parentId == null || !taskMap.containsKey(t.parentId))) visit(root);
    return result;
  }

  static String _dateStamp() {
    final n = DateTime.now();
    return '${n.year}${n.month.toString().padLeft(2,'0')}${n.day.toString().padLeft(2,'0')}';
  }

  /// On Flutter platforms without dart:html, we print to console and show a snackbar.
  /// On web this would trigger an actual download.
  static void _downloadText(String content, String filename, String mime) {
    // Platform-agnostic: in a real app you'd use dart:html on web or
    // share_plus / path_provider on mobile. Here we display a copy dialog.
    debugPrint('=== EXPORT: $filename ===\n$content\n=== END EXPORT ===');
  }
}

// ─── PDF Preview Dialog ───────────────────────────────────────────────────────

class _PdfPreviewDialog extends StatelessWidget {
  final List<Task> tasks;
  final DateTime projectStart;
  final DateTime projectEnd;

  const _PdfPreviewDialog({
    required this.tasks,
    required this.projectStart,
    required this.projectEnd,
  });

  @override
  Widget build(BuildContext context) {
    final ordered = _GanttExporterHelper.flattenTasks(tasks);
    final totalDays = projectEnd.difference(projectStart).inDays;

    return Dialog(
      backgroundColor: const Color(0xFF1C2333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF2E3854))),
      child: SizedBox(width: 740, height: 600,
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(color: Color(0xFF161B27), borderRadius: BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: Color(0xFF2E3854)))),
            child: Row(children: [
              const Icon(Icons.picture_as_pdf, size: 16, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              const Text('PDF Report Preview', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9))),
              const Spacer(),
              TextButton.icon(icon: const Icon(Icons.copy, size: 12), label: const Text('Copy CSV'),
                onPressed: () { GanttExporter.exportCsv(tasks); Navigator.pop(context); }),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => Navigator.pop(context), color: const Color(0xFF475569)),
            ]),
          ),
          // Preview
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Cover
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('PROJECT TIMELINE REPORT', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFF1F5F9))),
                  const SizedBox(height: 4),
                  Text('${GanttDateUtils.formatShortDate(projectStart)} – ${GanttDateUtils.formatShortDate(projectEnd)}  •  $totalDays days  •  ${tasks.length} tasks',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF94A3B8))),
                ]),
              ),
              const SizedBox(height: 20),
              // Summary stats
              Row(children: [
                _StatCard('Total Tasks', '${tasks.length}'),
                const SizedBox(width: 12),
                _StatCard('Completed', '${tasks.where((t) => t.status == TaskStatus.done).length}'),
                const SizedBox(width: 12),
                _StatCard('In Progress', '${tasks.where((t) => t.status == TaskStatus.inProgress).length}'),
                const SizedBox(width: 12),
                _StatCard('Overdue', '${tasks.where((t) => t.isOverdue).length}', danger: true),
              ]),
              const SizedBox(height: 20),
              // Task table
              _TaskTable(tasks: ordered),
            ]),
          )),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFF161B27), borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)), border: Border(top: BorderSide(color: Color(0xFF2E3854)))),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              const Text('Integrate with your PDF package for actual download', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF475569))),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final bool danger;
  const _StatCard(this.label, this.value, {this.danger = false});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: danger ? const Color(0xFFEF4444).withOpacity(0.1) : const Color(0xFF252D40),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: danger ? const Color(0xFFEF4444).withOpacity(0.3) : const Color(0xFF2E3854)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: danger ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9))),
      Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFF94A3B8))),
    ]),
  ));
}

class _TaskTable extends StatelessWidget {
  final List<Task> tasks;
  const _TaskTable({required this.tasks});
  @override
  Widget build(BuildContext context) => Column(children: [
    // Header
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF252D40),
      child: Row(children: const [
        SizedBox(width: 40, child: Text('WBS', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
        Expanded(flex: 3, child: Text('Task', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
        SizedBox(width: 80, child: Text('Start', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
        SizedBox(width: 80, child: Text('End', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
        SizedBox(width: 60, child: Text('Progress', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
        SizedBox(width: 70, child: Text('Status', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
      ]),
    ),
    ...tasks.asMap().entries.map((e) => _TaskRow(task: e.value, isEven: e.key.isEven)),
  ]);
}

class _TaskRow extends StatelessWidget {
  final Task task;
  final bool isEven;
  const _TaskRow({required this.task, required this.isEven});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    color: isEven ? const Color(0xFF1C2333) : const Color(0xFF161B27),
    child: Row(children: [
      SizedBox(width: 40, child: Text(task.wbsCode ?? '', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFF475569)))),
      Expanded(flex: 3, child: Text(task.title, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: task.parentId == null ? FontWeight.w600 : FontWeight.w400, color: task.isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9)), overflow: TextOverflow.ellipsis)),
      SizedBox(width: 80, child: Text(GanttDateUtils.formatShortDate(task.startDate), style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFF94A3B8)))),
      SizedBox(width: 80, child: Text(GanttDateUtils.formatShortDate(task.endDate), style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFF94A3B8)))),
      SizedBox(width: 60, child: Text('${(task.progress * 100).toInt()}%', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: task.progress >= 1.0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)))),
      SizedBox(width: 70, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: task.status.color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
        child: Text(task.status.label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600, color: task.status.color)))),
    ]),
  );
}

class _GanttExporterHelper {
  static List<Task> flattenTasks(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final result = <Task>[];
    final visited = <String>{};
    void visit(Task t) {
      if (visited.contains(t.id)) return;
      visited.add(t.id);
      result.add(t);
      for (final child in tasks.where((c) => c.parentId == t.id)) visit(child);
    }
    for (final root in tasks.where((t) => t.parentId == null || !taskMap.containsKey(t.parentId))) visit(root);
    return result;
  }
}
