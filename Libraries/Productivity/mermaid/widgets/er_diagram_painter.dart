import 'package:flutter/material.dart';

import '../models/er_entity.dart';
import '../models/er_relationship.dart';
import '../models/mermaid_diagram.dart';

class ERDiagramPainter extends StatelessWidget {
  final MermaidDiagram diagram;

  const ERDiagramPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diagram.entities.length * 280.0 + 100, 400),
      painter: _ERDiagramCustomPainter(diagram),
    );
  }
}

class _ERDiagramCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;

  _ERDiagramCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw relationships
    for (final rel in diagram.erRelationships) {
      final fromEntity = diagram.entities.firstWhere((e) => e.name == rel.from);
      final toEntity = diagram.entities.firstWhere((e) => e.name == rel.to);
      _drawRelationship(canvas, fromEntity, toEntity, rel);
    }

    // Draw entities
    for (final entity in diagram.entities) {
      _drawEntity(canvas, entity);
    }
  }

  void _drawEntity(Canvas canvas, EREntity entity) {
    final height = 60.0 + entity.attributes.length * 25.0;
    final rect = Rect.fromLTWH(
      entity.position.dx,
      entity.position.dy,
      250,
      height,
    );

    final paint =
        Paint()
          ..color = Colors.green[50]!
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = Colors.green[700]!
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Entity name
    final headerRect = Rect.fromLTWH(rect.left, rect.top, rect.width, 50);
    final headerPaint = Paint()..color = Colors.green[200]!;
    canvas.drawRect(headerRect, headerPaint);

    _drawText(
      canvas,
      entity.name,
      headerRect.center,
      240,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    // Attributes
    canvas.drawLine(
      Offset(rect.left, rect.top + 50),
      Offset(rect.right, rect.top + 50),
      borderPaint,
    );

    var currentY = rect.top + 65;
    for (final attr in entity.attributes) {
      _drawText(
        canvas,
        attr,
        Offset(rect.left + 10, currentY),
        230,
        fontSize: 11,
        align: TextAlign.left,
      );
      currentY += 25;
    }
  }

  void _drawRelationship(
    Canvas canvas,
    EREntity from,
    EREntity to,
    ERRelationship rel,
  ) {
    final fromCenter = Offset(from.position.dx + 125, from.position.dy + 30);
    final toCenter = Offset(to.position.dx + 125, to.position.dy + 30);

    final paint =
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    canvas.drawLine(fromCenter, toCenter, paint);

    if (rel.label.isNotEmpty) {
      final midPoint = Offset(
        (fromCenter.dx + toCenter.dx) / 2,
        (fromCenter.dy + toCenter.dy) / 2 - 15,
      );
      _drawText(
        canvas,
        rel.label,
        midPoint,
        150,
        fontSize: 11,
        bgColor: Colors.white,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    double maxWidth, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    Color? bgColor,
    TextAlign align = TextAlign.center,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: fontWeight,
          backgroundColor: bgColor,
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
