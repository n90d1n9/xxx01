import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_edge.dart';
import '../models/mermaid_diagram.dart';
import '../models/state_node.dart';

class StateDiagramPainter extends StatelessWidget {
  final MermaidDiagram diagram;

  const StateDiagramPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(1000, 600),
      painter: _StateDiagramCustomPainter(diagram),
    );
  }
}

class _StateDiagramCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;

  _StateDiagramCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw transitions
    for (final edge in diagram.edges) {
      if (edge.from == '[*]' || edge.to == '[*]') {
        _drawInitialFinalTransition(canvas, edge);
      } else {
        final fromState = diagram.states.firstWhere((s) => s.id == edge.from);
        final toState = diagram.states.firstWhere((s) => s.id == edge.to);
        _drawTransition(canvas, fromState, toState, edge);
      }
    }

    // Draw states
    for (final state in diagram.states) {
      if (!state.isInitial && !state.isFinal) {
        _drawState(canvas, state);
      }
    }
  }

  void _drawState(Canvas canvas, StateNode state) {
    final rect = Rect.fromLTWH(state.position.dx, state.position.dy, 180, 70);

    final paint =
        Paint()
          ..color = Colors.purple[50]!
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = Colors.purple[700]!
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);

    _drawText(canvas, state.label, rect.center, 170);
  }

  void _drawInitialFinalTransition(Canvas canvas, DiagramEdge edge) {
    // Draw initial or final state markers
    if (edge.from == '[*]') {
      final toState = diagram.states.firstWhere((s) => s.id == edge.to);
      final startPos = Offset(
        toState.position.dx - 50,
        toState.position.dy + 35,
      );

      canvas.drawCircle(startPos, 10, Paint()..color = Colors.black);

      final paint =
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 2.0;
      canvas.drawLine(
        startPos,
        Offset(toState.position.dx, toState.position.dy + 35),
        paint,
      );
    }
  }

  void _drawTransition(
    Canvas canvas,
    StateNode from,
    StateNode to,
    DiagramEdge edge,
  ) {
    final fromCenter = Offset(from.position.dx + 90, from.position.dy + 35);
    final toCenter = Offset(to.position.dx + 90, to.position.dy + 35);

    final paint =
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    canvas.drawLine(fromCenter, toCenter, paint);
    _drawArrow(canvas, fromCenter, toCenter);

    if (edge.label != null) {
      final midPoint = Offset(
        (fromCenter.dx + toCenter.dx) / 2,
        (fromCenter.dy + toCenter.dy) / 2 - 15,
      );
      _drawText(
        canvas,
        edge.label!,
        midPoint,
        120,
        fontSize: 11,
        bgColor: Colors.white,
      );
    }
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
    Color? bgColor,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          backgroundColor: bgColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
