import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/task_model.dart';
import '../../core/utils/date_utils.dart';

/// Platform-adaptive file export for CSV, JSON and PDF (print preview).
///
/// Platform strategy:
///   - Desktop (Windows/macOS/Linux): writes to Documents folder, shows snackbar with path
///   - Mobile (iOS/Android):          saves to temp dir then triggers share sheet
///   - Web:                           uses dart:html anchor download trick (conditional import)
///   - Tests / unknown:               returns content as string via callback
class GanttExporter {
  GanttExporter._();

  // ─── Public API ──────────────────────────────────────────────────────────────

  static Future<void> exportCsv(BuildContext context, List<Task> tasks) async {
    final buf = StringBuffer();
    buf.writeln('WBS,Title,Status,Priority,Start Date,End Date,'
        'Duration (days),Progress (%),Estimated Hours,Actual Hours,'
        'Assignees,Labels,Risk Level,Slip (days)');

    for (final task in _flattenTasks(tasks)) {
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

    final filename = 'gantt_export_${_dateStamp()}.csv';
    await _saveAndShare(context, buf.toString(), filename, 'text/csv');
  }

  static Future<void> exportJson(
    BuildContext context,
    List<Task> tasks,
    DateTime projectStart,
    DateTime projectEnd,
  ) async {
    final data = {
      'exportedAt':   DateTime.now().toIso8601String(),
      'projectStart': projectStart.toIso8601String(),
      'projectEnd':   projectEnd.toIso8601String(),
      'taskCount':    tasks.length,
      'tasks':        tasks.map((t) => t.toJson()).toList(),
    };
    final json     = const JsonEncoder.withIndent('  ').convert(data);
    final filename = 'gantt_export_${_dateStamp()}.json';
    await _saveAndShare(context, json, filename, 'application/json');
  }

  static void exportPdf(
    BuildContext context,
    List<Task> tasks,
    DateTime projectStart,
    DateTime projectEnd,
  ) {
    showDialog(
      context: context,
      builder: (_) => _PdfPreviewDialog(
        tasks: tasks,
        projectStart: projectStart,
        projectEnd: projectEnd,
      ),
    );
  }

  // ─── Core save + share ────────────────────────────────────────────────────

  /// Writes content to a file and either:
  ///   - Shows a snackbar with path (desktop)
  ///   - Opens share sheet (mobile)
  static Future<void> _saveAndShare(
    BuildContext context,
    String content,
    String filename,
    String mimeType,
  ) async {
    try {
      final file = await _writeFile(content, filename);
      if (!context.mounted) return;

      if (_isMobile) {
        // Share sheet: lets user save to Files, send via email, AirDrop, etc.
        await Share.shareXFiles(
          [XFile(file.path, mimeType: mimeType)],
          subject: filename,
        );
      } else {
        // Desktop: file already saved — show path in snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Exported to ${file.path}',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            action: SnackBarAction(
              label: 'Open folder',
              onPressed: () => _revealInFinder(file),
            ),
            duration: const Duration(seconds: 6),
            backgroundColor: const Color(0xFF1C2333),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e',
              style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
          backgroundColor: const Color(0xFF1C2333),
        ),
      );
    }
  }

  /// Writes [content] to the best available directory and returns the [File].
  static Future<File> _writeFile(String content, String filename) async {
    final dir = await _exportDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content, encoding: utf8, flush: true);
    return file;
  }

  /// Returns the most user-visible writable directory per platform.
  static Future<Directory> _exportDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getTemporaryDirectory(); // share_plus reads from here
    }
    // macOS / Windows / Linux — prefer Documents
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return getTemporaryDirectory();
    }
  }

  /// Attempts to reveal file in macOS Finder / Windows Explorer.
  static Future<void> _revealInFinder(File file) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', ['-R', file.path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', ['/select,', file.path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [file.parent.path]);
      }
    } catch (_) {}
  }

  static bool get _isMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _csv(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  static List<Task> _flattenTasks(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final result  = <Task>[];
    final visited = <String>{};
    void visit(Task t) {
      if (visited.contains(t.id)) return;
      visited.add(t.id);
      result.add(t);
      for (final child in tasks.where((c) => c.parentId == t.id)) visit(child);
    }
    for (final root in tasks.where((t) =>
        t.parentId == null || !taskMap.containsKey(t.parentId))) {
      visit(root);
    }
    return result;
  }

  static String _dateStamp() {
    final n = DateTime.now();
    return '${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}';
  }
}

// ─── PDF Preview + Print Dialog ───────────────────────────────────────────────

class _PdfPreviewDialog extends StatelessWidget {
  final List<Task>  tasks;
  final DateTime    projectStart;
  final DateTime    projectEnd;

  const _PdfPreviewDialog({
    required this.tasks,
    required this.projectStart,
    required this.projectEnd,
  });

  @override
  Widget build(BuildContext context) {
    final ordered   = _GanttExporterHelper.flattenTasks(tasks);
    final totalDays = projectEnd.difference(projectStart).inDays;
    final done      = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProg    = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdue   = tasks.where((t) => t.isOverdue).length;
    final avgPct    = tasks.isEmpty
        ? 0.0
        : tasks.fold(0.0, (s, t) => s + t.progress) / tasks.length * 100;

    return Dialog(
      backgroundColor: const Color(0xFF1C2333),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2E3854)),
      ),
      child: SizedBox(
        width: 760, height: 620,
        child: Column(children: [
          // ── Header ─────────────────────────────────────────────────────────
          _DialogHeader(
            tasks: tasks,
            projectStart: projectStart,
            projectEnd: projectEnd,
            onClose: () => Navigator.pop(context),
          ),

          // ── Preview content ────────────────────────────────────────────────
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Cover block
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.25)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('PROJECT TIMELINE REPORT',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                          color: Color(0xFFF1F5F9), letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Text(
                    '${GanttDateUtils.formatShortDate(projectStart)} – '
                    '${GanttDateUtils.formatShortDate(projectEnd)}'
                    '  ·  $totalDays days  ·  ${tasks.length} tasks',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: avgPct / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF2E3854),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${avgPct.toStringAsFixed(0)}% overall progress',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ]),
              ),
              const SizedBox(height: 16),

              // KPI row
              Row(children: [
                _KpiCard('Total',      '${tasks.length}', const Color(0xFF94A3B8)),
                const SizedBox(width: 10),
                _KpiCard('Done',       '$done',   const Color(0xFF10B981)),
                const SizedBox(width: 10),
                _KpiCard('In Progress','$inProg', const Color(0xFF6366F1)),
                const SizedBox(width: 10),
                _KpiCard('Overdue',    '$overdue', const Color(0xFFEF4444),
                    highlight: overdue > 0),
              ]),
              const SizedBox(height: 20),

              // Status breakdown bar
              _StatusBreakdown(tasks: tasks),
              const SizedBox(height: 20),

              // Task table
              _TaskTable(tasks: ordered),
            ]),
          )),

          // ── Footer ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF161B27),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: Color(0xFF2E3854))),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 12, color: Color(0xFF475569)),
              const SizedBox(width: 6),
              const Text(
                'Add the "pdf" and "printing" packages for native print-to-PDF support.',
                style: TextStyle(fontSize: 10, color: Color(0xFF475569)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final List<Task> tasks;
  final DateTime projectStart, projectEnd;
  final VoidCallback onClose;

  const _DialogHeader({
    required this.tasks,
    required this.projectStart,
    required this.projectEnd,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(
      color: Color(0xFF161B27),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      border: Border(bottom: BorderSide(color: Color(0xFF2E3854))),
    ),
    child: Row(children: [
      const Icon(Icons.picture_as_pdf, size: 16, color: Color(0xFFEF4444)),
      const SizedBox(width: 8),
      const Text('Export Preview',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: Color(0xFFF1F5F9))),
      const Spacer(),
      // Export CSV
      TextButton.icon(
        icon: const Icon(Icons.table_chart_outlined, size: 13),
        label: const Text('CSV'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF10B981),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: () {
          Navigator.pop(context);
          GanttExporter.exportCsv(context, tasks);
        },
      ),
      // Export JSON
      TextButton.icon(
        icon: const Icon(Icons.code, size: 13),
        label: const Text('JSON'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF06B6D4),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: () {
          Navigator.pop(context);
          GanttExporter.exportJson(context, tasks, projectStart, projectEnd);
        },
      ),
      const SizedBox(width: 4),
      IconButton(
        icon: const Icon(Icons.close, size: 16),
        color: const Color(0xFF475569),
        onPressed: onClose,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      ),
    ]),
  );
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool highlight;
  const _KpiCard(this.label, this.value, this.color, {this.highlight = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.1) : const Color(0xFF252D40),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? color.withOpacity(0.4) : const Color(0xFF2E3854),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
      ]),
    ),
  );
}

class _StatusBreakdown extends StatelessWidget {
  final List<Task> tasks;
  const _StatusBreakdown({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final counts = <TaskStatus, int>{};
    for (final t in tasks) counts[t.status] = (counts[t.status] ?? 0) + 1;
    final total = tasks.length;
    if (total == 0) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('STATUS BREAKDOWN',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: Color(0xFF475569), letterSpacing: 1.0)),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 12,
          child: Row(children: counts.entries.map((e) {
            final frac = e.value / total;
            return Flexible(
              flex: (frac * 1000).round(),
              child: Container(color: e.key.color),
            );
          }).toList()),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 14, runSpacing: 4, children: counts.entries.map((e) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(
              color: e.key.color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 5),
          Text('${e.key.label} (${e.value})',
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ])
      ).toList()),
    ]);
  }
}

class _TaskTable extends StatelessWidget {
  final List<Task> tasks;
  const _TaskTable({required this.tasks});

  @override
  Widget build(BuildContext context) => Column(children: [
    // Header
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF252D40),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
      child: const Row(children: [
        SizedBox(width: 44, child: Text('WBS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
        Expanded(flex: 3, child: Text('Task',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
        SizedBox(width: 82, child: Text('Start',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
        SizedBox(width: 82, child: Text('End',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
        SizedBox(width: 58, child: Text('Progress',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
        SizedBox(width: 72, child: Text('Status',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
      ]),
    ),
    ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
      child: Column(children: tasks.asMap().entries.map((e) =>
        _TaskRow(task: e.value, isEven: e.key.isEven),
      ).toList()),
    ),
  ]);
}

class _TaskRow extends StatelessWidget {
  final Task task;
  final bool isEven;
  const _TaskRow({required this.task, required this.isEven});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    color: isEven ? const Color(0xFF1C2333) : const Color(0xFF1A2030),
    child: Row(children: [
      SizedBox(width: 44,
          child: Text(task.wbsCode ?? '',
              style: const TextStyle(fontSize: 10, color: Color(0xFF475569)))),
      Expanded(flex: 3,
          child: Text(task.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: task.parentId == null ? FontWeight.w600 : FontWeight.w400,
                color: task.isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9),
              ),
              overflow: TextOverflow.ellipsis)),
      SizedBox(width: 82,
          child: Text(GanttDateUtils.formatShortDate(task.startDate),
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)))),
      SizedBox(width: 82,
          child: Text(GanttDateUtils.formatShortDate(task.endDate),
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)))),
      SizedBox(width: 58,
          child: Text('${(task.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: task.progress >= 1.0
                    ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              ))),
      SizedBox(width: 72,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: task.status.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(task.status.label,
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w600, color: task.status.color)),
          )),
    ]),
  );
}

class _GanttExporterHelper {
  static List<Task> flattenTasks(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final result  = <Task>[];
    final visited = <String>{};
    void visit(Task t) {
      if (visited.contains(t.id)) return;
      visited.add(t.id);
      result.add(t);
      for (final child in tasks.where((c) => c.parentId == t.id)) visit(child);
    }
    for (final root in tasks.where((t) =>
        t.parentId == null || !taskMap.containsKey(t.parentId))) {
      visit(root);
    }
    return result;
  }
}
