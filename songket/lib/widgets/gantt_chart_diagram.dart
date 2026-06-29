import 'package:flutter/material.dart';

import '../models/gantt_task.dart';
import '../models/mermaid_diagram.dart';

class GanttChartPainter extends StatelessWidget {
  final MermaidDiagram diagram;

  const GanttChartPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(1200, diagram.ganttTasks.length * 50.0 + 150),
      painter: _GanttChartCustomPainter(diagram),
    );
  }
}

class _GanttChartCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;

  _GanttChartCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    if (diagram.ganttTasks.isEmpty) return;

    final tasks = diagram.ganttTasks;
    final earliestDate = tasks
        .map((t) => t.startDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final latestDate = tasks
        .map((t) => t.endDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final totalDays = latestDate.difference(earliestDate).inDays + 1;

    const leftMargin = 200.0;
    const topMargin = 80.0;
    const barHeight = 30.0;
    const rowSpacing = 50.0;
    final chartWidth = size.width - leftMargin - 50;

    // Draw title
    _drawText(
      canvas,
      'Gantt Chart',
      Offset(size.width / 2, 30),
      size.width,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    // Group by section
    final sections = <String, List<GanttTask>>{};
    for (final task in tasks) {
      sections.putIfAbsent(task.section, () => []).add(task);
    }

    var currentY = topMargin;
    String? lastSection;

    for (final task in tasks) {
      // Draw section header
      if (task.section != lastSection) {
        _drawText(
          canvas,
          task.section,
          Offset(10, currentY),
          leftMargin - 20,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          align: TextAlign.left,
        );
        currentY += 30;
        lastSection = task.section;
      }

      // Draw task name
      _drawText(
        canvas,
        task.name,
        Offset(10, currentY + barHeight / 2),
        leftMargin - 20,
        fontSize: 12,
        align: TextAlign.left,
      );

      // Calculate bar position
      final startDays = task.startDate.difference(earliestDate).inDays;
      final duration = task.endDate.difference(task.startDate).inDays;

      final barX = leftMargin + (startDays / totalDays) * chartWidth;
      final barWidth = (duration / totalDays) * chartWidth;

      // Draw bar
      Color barColor = Colors.blue[300]!;
      if (task.status == 'done') {
        barColor = Colors.green[400]!;
      } else if (task.status == 'crit') {
        barColor = Colors.red[400]!;
      } else if (task.status == 'active') {
        barColor = Colors.orange[400]!;
      }

      final barRect = Rect.fromLTWH(barX, currentY, barWidth, barHeight);
      final barPaint = Paint()..color = barColor;
      final borderPaint =
          Paint()
            ..color = barColor.withOpacity(0.7)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke;

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
        barPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
        borderPaint,
      );

      currentY += rowSpacing;
    }

    // Draw timeline
    final timelinePaint =
        Paint()
          ..color = Colors.grey[400]!
          ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(leftMargin, topMargin - 30),
      Offset(leftMargin + chartWidth, topMargin - 30),
      timelinePaint,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    double maxWidth, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign align = TextAlign.center,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final offset =
        align == TextAlign.center
            ? Offset(
              position.dx - textPainter.width / 2,
              position.dy - textPainter.height / 2,
            )
            : Offset(position.dx, position.dy - textPainter.height / 2);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
