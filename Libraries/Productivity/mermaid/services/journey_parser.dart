import 'package:flutter/material.dart';

import '../models/diagram_type.dart';
import '../models/journey_task.dart';
import '../models/mermaid_diagram.dart';
import 'base_parser.dart';

class JourneyParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('journey');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final tasks = <JourneyTask>[];
    var currentSection = '';

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (_parseTitle(line)) continue;
      if (_parseSection(line) != null) {
        currentSection = _parseSection(line)!;
        continue;
      }

      _parseTask(line, tasks, currentSection);
    }

    return MermaidDiagram(
      type: DiagramType.journey,
      journeyTasks: tasks,
      rawCode: code,
    );
  }

  bool _parseTitle(String line) {
    return line.startsWith('title ');
  }

  String? _parseSection(String line) {
    if (line.startsWith('section ')) {
      return line.substring(8).trim();
    }
    return null;
  }

  void _parseTask(String line, List<JourneyTask> tasks, String section) {
    // Try to parse with actors first
    final actorMatch = RegExp(
      r'(\d+)\s*:\s*([^:]+)\s*:\s*(\d+)(?:\s*:\s*([^:]+))?',
    ).firstMatch(line);

    if (actorMatch != null) {
      final score = int.parse(actorMatch.group(1)!);
      final label = actorMatch.group(2)!.trim();
      final value = int.parse(actorMatch.group(3)!);
      final actorsStr = actorMatch.group(4);

      // Parse actors if present
      final actors =
          actorsStr != null
              ? actorsStr
                  .split(',')
                  .map((a) => a.trim())
                  .where((a) => a.isNotEmpty)
                  .toList()
              : <String>[];

      tasks.add(
        JourneyTask(
          id: 'journey_${tasks.length}',
          label: label,
          score: score,
          value: value,
          section: section,
          task: label,
          actors: actors,
        ),
      );
      return;
    }

    // Fallback to simple task parsing (without actors)
    final simpleMatch = RegExp(
      r'(\d+)\s*:\s*(\w[\w\s]*)\s*:\s*(\d+)',
    ).firstMatch(line);
    if (simpleMatch != null) {
      final score = int.parse(simpleMatch.group(1)!);
      final label = simpleMatch.group(2)!.trim();
      final value = int.parse(simpleMatch.group(3)!);

      tasks.add(
        JourneyTask(
          id: 'journey_${tasks.length}',
          label: label,
          score: score,
          value: value,
          section: section,
          task: label,
          actors: const [],
        ),
      );
    }
  }

  void _drawJourneyTask(Canvas canvas, JourneyTask task, double x, double y) {
    final taskPaint =
        Paint()
          ..color = _getTaskColor(task.score)
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Draw task rectangle
    final rect = Rect.fromLTWH(x, y, 160, 80);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, taskPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Draw task label
    _drawText(
      canvas,
      task.task,
      Offset(x + 80, y + 20),
      140,
      fontSize: 12,
      textColor: Colors.black,
      fontWeight: FontWeight.bold,
    );

    // Draw score and value
    _drawText(
      canvas,
      'Score: ${task.score} | Value: ${task.value}',
      Offset(x + 80, y + 40),
      140,
      fontSize: 10,
      textColor: Colors.grey[700]!,
    );

    // Draw section
    _drawText(
      canvas,
      'Section: ${task.section}',
      Offset(x + 80, y + 55),
      140,
      fontSize: 9,
      textColor: Colors.grey[600]!,
    );

    // Draw actors if they exist
    if (task.actors.isNotEmpty) {
      _drawText(
        canvas,
        'Actors: ${task.actors.join(', ')}',
        Offset(x + 80, y + 70),
        140,
        fontSize: 8,
        textColor: Colors.grey[600]!,
      );
    }
  }

  Color _getTaskColor(int score) {
    // Color based on score
    if (score >= 8) return Colors.green[100]!;
    if (score >= 6) return Colors.blue[100]!;
    if (score >= 4) return Colors.yellow[100]!;
    return Colors.red[100]!;
  }

  // Updated text drawing helper with more parameters
  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double maxWidth, {
    double fontSize = 12,
    Color textColor = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final textStyle = TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }
}
