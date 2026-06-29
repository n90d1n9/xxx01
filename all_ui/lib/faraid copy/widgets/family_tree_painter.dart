import 'package:flutter/material.dart';

import '../models/family_member.dart';
import '../models/relation_type.dart';

class FamilyTreePainter extends CustomPainter {
  final List<FamilyMember> members;
  final bool showGrid;

  FamilyTreePainter(this.members, this.showGrid);

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }
    _drawConnections(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    const gridSize = 100.0;

    // Draw larger grid for better orientation
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw coordinate indicators every 500 pixels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final textStyle = TextStyle(
      color: Colors.grey.withOpacity(0.5),
      fontSize: 12,
    );

    for (double x = 0; x < size.width; x += 500) {
      for (double y = 0; y < size.height; y += 500) {
        textPainter.text = TextSpan(
          text: '(${x.toInt()}, ${y.toInt()})',
          style: textStyle,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 5, y + 5));
      }
    }
  }

  void _drawConnections(Canvas canvas) {
    final deceased =
        members.where((m) => m.relation == RelationType.deceased).firstOrNull;
    if (deceased == null) return;

    final paint =
        Paint()
          ..color = Colors.teal.withOpacity(0.4)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final dashedPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final deceasedPos = deceased.position + const Offset(90, 90);

    for (var member in members) {
      if (member.id == deceased.id) continue;

      final memberPos = member.position + const Offset(90, 90);
      final path = Path();
      path.moveTo(deceasedPos.dx, deceasedPos.dy);

      Paint linePaint = member.isDeceased ? dashedPaint : paint;

      if (member.relation == RelationType.spouse ||
          member.relation == RelationType.father ||
          member.relation == RelationType.mother) {
        path.lineTo(memberPos.dx, memberPos.dy);
      } else {
        final midY = (deceasedPos.dy + memberPos.dy) / 2;
        path.cubicTo(
          deceasedPos.dx,
          midY,
          memberPos.dx,
          midY,
          memberPos.dx,
          memberPos.dy,
        );
      }

      if (member.isDeceased) {
        _drawDashedPath(canvas, path, dashedPaint);
      } else {
        canvas.drawPath(path, linePaint);
      }

      canvas.drawCircle(deceasedPos, 5, Paint()..color = Colors.teal);
      canvas.drawCircle(
        memberPos,
        5,
        Paint()..color = member.isDeceased ? Colors.grey : Colors.teal,
      );
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final nextDistance = distance + dashWidth;
        final segment = pathMetric.extractPath(distance, nextDistance);
        canvas.drawPath(segment, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(FamilyTreePainter oldDelegate) => true;
}
