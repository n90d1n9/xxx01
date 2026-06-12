import '../models/diagram_type.dart';
import '../models/gantt_task.dart';
import '../models/mermaid_diagram.dart';
import 'base_parser.dart';

class GanttParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('gantt');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final tasks = <GanttTask>[];
    String currentSection = 'General';
    DateTime? baseDate;

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;

      if (_parseDateFormat(line)) continue;
      if (_parseStartDate(line) != null) {
        baseDate = _parseStartDate(line);
        continue;
      }
      if (_parseSection(line) != null) {
        currentSection = _parseSection(line)!;
        continue;
      }

      _parseTask(line, tasks, currentSection, baseDate);
    }

    return MermaidDiagram(
      type: DiagramType.gantt,
      ganttTasks: tasks,
      rawCode: code,
    );
  }

  bool _parseDateFormat(String line) {
    return line.toLowerCase().contains('dateformat');
  }

  DateTime? _parseStartDate(String line) {
    if (line.toLowerCase().contains('startdate')) {
      final dateMatch = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(line);
      if (dateMatch != null) {
        try {
          return DateTime.parse(dateMatch.group(0)!);
        } catch (_) {}
      }
    }
    return null;
  }

  String? _parseSection(String line) {
    if (line.startsWith('section ')) {
      return line.substring(8).trim();
    }
    return null;
  }

  void _parseTask(
    String line,
    List<GanttTask> tasks,
    String section,
    DateTime? baseDate,
  ) {
    final taskMatch = RegExp(
      r'(\w[\w\s]*)\s*:\s*(?:(crit|active|done)\s*,?\s*)?(?:(\d{4}-\d{2}-\d{2})\s*,?\s*)?(?:(\d+d)\s*,?\s*)?(?:after\s*(\w+)\s*,?\s*)?(?:(\d{4}-\d{2}-\d{2}))?',
    ).firstMatch(line);

    if (taskMatch != null) {
      final name = taskMatch.group(1)!.trim();
      final status = taskMatch.group(2) ?? '';
      final startStr = taskMatch.group(3);
      final durationStr = taskMatch.group(4);
      final afterTask = taskMatch.group(5);
      final endStr = taskMatch.group(6);

      DateTime startDate = baseDate ?? DateTime(2024, 1, 1);

      // Adjust start date based on previous task if "after" is specified
      if (afterTask != null) {
        final previousTask = tasks.lastWhere(
          (t) => t.name == afterTask,
          orElse:
              () =>
                  tasks.isNotEmpty
                      ? tasks.last
                      : GanttTask(
                        id: 'dummy',
                        name: 'dummy',
                        section: section,
                        startDate: startDate,
                        endDate: startDate,
                        status: '',
                      ),
        );
        startDate = previousTask.endDate;
      } else if (startStr != null) {
        try {
          startDate = DateTime.parse(startStr);
        } catch (_) {}
      }

      DateTime endDate;
      if (endStr != null) {
        try {
          endDate = DateTime.parse(endStr);
        } catch (_) {
          endDate = _calculateEndDate(startDate, durationStr);
        }
      } else {
        endDate = _calculateEndDate(startDate, durationStr);
      }

      tasks.add(
        GanttTask(
          id: 'task_${tasks.length}',
          name: name,
          section: section,
          startDate: startDate,
          endDate: endDate,
          status: status,
        ),
      );
    }
  }

  DateTime _calculateEndDate(DateTime startDate, String? durationStr) {
    if (durationStr != null) {
      final days = int.tryParse(durationStr.replaceAll('d', '')) ?? 5;
      return startDate.add(Duration(days: days));
    }
    return startDate.add(const Duration(days: 5));
  }
}
