import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/class_node.dart';
import '../models/diagram_edge.dart';
import '../models/mermaid_diagram.dart';

class ClassDiagramPainter extends StatelessWidget {
  final MermaidDiagram diagram;

  const ClassDiagramPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diagram.classes.length * 280.0 + 100, 600),
      painter: _ClassDiagramCustomPainter(diagram),
    );
  }
}

class _ClassDiagramCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;

  _ClassDiagramCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw relationships
    for (final edge in diagram.edges) {
      final fromClass = diagram.classes.firstWhere(
        (c) => c.id == edge.from,
        orElse: () => diagram.classes.first,
      );
      final toClass = diagram.classes.firstWhere(
        (c) => c.id == edge.to,
        orElse: () => diagram.classes.first,
      );

      _drawRelationship(canvas, fromClass, toClass, edge);
    }

    // Draw classes
    for (final classNode in diagram.classes) {
      _drawClass(canvas, classNode);
    }
  }

  void _drawClass(Canvas canvas, ClassNode classNode) {
    final headerHeight = 50.0;
    final attrHeight = classNode.attributes.length * 25.0 + 20;
    final methodHeight = classNode.methods.length * 25.0 + 20;
    final totalHeight = headerHeight + attrHeight + methodHeight;

    final rect = Rect.fromLTWH(
      classNode.position.dx,
      classNode.position.dy,
      250,
      totalHeight,
    );

    // Background
    final paint =
        Paint()
          ..color = Colors.amber[50]!
          ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    // Border
    final borderPaint =
        Paint()
          ..color = Colors.orange[700]!
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);

    // Header section
    final headerRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width,
      headerHeight,
    );
    final headerPaint = Paint()..color = Colors.orange[200]!;
    canvas.drawRect(headerRect, headerPaint);

    // Class name
    _drawText(
      canvas,
      classNode.label,
      Offset(rect.center.dx, rect.top + headerHeight / 2),
      240,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    // Divider after header
    canvas.drawLine(
      Offset(rect.left, rect.top + headerHeight),
      Offset(rect.right, rect.top + headerHeight),
      borderPaint,
    );

    // Attributes
    var currentY = rect.top + headerHeight + 15;
    for (final attr in classNode.attributes) {
      final text = '${attr.visibility} ${attr.name}: ${attr.type}';
      _drawText(
        canvas,
        text,
        Offset(rect.left + 10, currentY),
        230,
        fontSize: 11,
        align: TextAlign.left,
      );
      currentY += 25;
    }

    // Divider after attributes
    if (classNode.attributes.isNotEmpty) {
      canvas.drawLine(
        Offset(rect.left, rect.top + headerHeight + attrHeight),
        Offset(rect.right, rect.top + headerHeight + attrHeight),
        borderPaint,
      );
    }

    // Methods
    currentY = rect.top + headerHeight + attrHeight + 15;
    for (final method in classNode.methods) {
      final text = '${method.visibility} ${method.name}(${method.type})';
      _drawText(
        canvas,
        text,
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
    ClassNode from,
    ClassNode to,
    DiagramEdge edge,
  ) {
    final fromCenter = Offset(from.position.dx + 125, from.position.dy + 100);
    final toCenter = Offset(to.position.dx + 125, to.position.dy + 100);

    final paint =
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    canvas.drawLine(fromCenter, toCenter, paint);
    _drawArrow(canvas, fromCenter, toCenter);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    final paint =
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;

    const arrowSize = 10.0;
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);

    final path =
        Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(
            to.dx - arrowSize * math.cos(angle - math.pi / 6),
            to.dy - arrowSize * math.sin(angle - math.pi / 6),
          )
          ..lineTo(
            to.dx - arrowSize * math.cos(angle + math.pi / 6),
            to.dy - arrowSize * math.sin(angle + math.pi / 6),
          )
          ..close();

    canvas.drawPath(path, paint);
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
