import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workflow Diagram',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('AI Workflow')),
        body: Center(child: CustomPaint(painter: WorkflowPainter())),
      ),
    );
  }
}

class WorkflowPainter extends CustomPainter {
  final Paint _gridPaint = Paint()
    ..color = const Color(0xFFE0E0E0)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  final Paint _nodeBorderPaint = Paint()
    ..color = const Color(0xFF888888)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final Paint _nodeFillPaint = Paint()
    ..color = const Color(0xFFF9F9F9)
    ..style = PaintingStyle.fill;

  final Paint _linePaint = Paint()
    ..color = const Color(0xFF888888)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final Paint _dashedLinePaint = Paint()
    ..color = const Color(0xFF888888)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _plusButtonPaint = Paint()
    ..color = const Color(0xFF888888)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final Paint _arrowHeadPaint = Paint()
    ..color = const Color(0xFF888888)
    ..style = PaintingStyle.fill;

  final TextPainter _textPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid background (dots every 20px)
    drawGrid(canvas, size);

    // Define base positions (visually measured from your image)
    final double startX = 100;
    final double startY = 300;
    final double emailNodeW = 140;
    final double emailNodeH = 100;
    final double aiAgentW = 200;
    final double aiAgentH = 120;
    final double outputNodeW = 140;
    final double outputNodeH = 100;
    final double loadNodeW = 140;
    final double loadNodeH = 100;
    final double spacingX = 250;
    final double spacingY = 150;

    // === NODE 1: Email Node ===
    final emailPos = Offset(startX, startY);
    drawRoundedRectNode(canvas, emailPos, emailNodeW, emailNodeH, "Email Node");

    // === NODE 2: AI Agent ===
    final aiAgentPos = Offset(startX + spacingX, startY);
    drawRoundedRectNode(
      canvas,
      aiAgentPos,
      aiAgentW,
      aiAgentH,
      "AI Agent\nTools Agent",
    );

    // === NODE 3: Output Formatting ===
    final outputPos = Offset(startX + 2 * spacingX, startY);
    drawRoundedRectNode(
      canvas,
      outputPos,
      outputNodeW,
      outputNodeH,
      "Output Formatting",
    );

    // === NODE 4: Load Results ===
    final loadPos = Offset(startX + 3 * spacingX, startY);
    drawRoundedRectNode(
      canvas,
      loadPos,
      loadNodeW,
      loadNodeH,
      "Load Results in a Sheet\nappend: sheet",
    );

    // === CONNECT MAIN NODES ===
    connectNodes(canvas, emailPos, aiAgentPos);
    connectNodes(canvas, aiAgentPos, outputPos);
    connectNodes(canvas, outputPos, loadPos);

    // === SUB-NODE 1: Large Language Model ===
    final llmPos = Offset(aiAgentPos.dx - 160, aiAgentPos.dy + 140);
    drawCircleNode(canvas, llmPos, 80, "Large Language\nModel");

    // === SUB-NODE 2: Output Structure ===
    final outputStructPos = Offset(aiAgentPos.dx + 160, aiAgentPos.dy + 140);
    drawCircleNode(canvas, outputStructPos, 80, "Output Structure");

    // === CONNECT SUB-NODES WITH DASHED LINES ===
    connectDashedToSubNode(canvas, aiAgentPos, llmPos, "Model");
    connectDashedToSubNode(
      canvas,
      aiAgentPos,
      outputStructPos,
      "Output Parser",
    );

    // === PLUS BUTTONS UNDER AI AGENT ===
    final plus1Pos = Offset(aiAgentPos.dx - 70, aiAgentPos.dy + 60);
    final plus2Pos = Offset(aiAgentPos.dx, aiAgentPos.dy + 60);
    final plus3Pos = Offset(aiAgentPos.dx + 70, aiAgentPos.dy + 60);
    drawPlusButton(canvas, plus1Pos);
    drawPlusButton(canvas, plus2Pos);
    drawPlusButton(canvas, plus3Pos);

    // === LABELS FOR PLUS BUTTONS ===
    drawLabel(canvas, "Chat", plus1Pos.dx, plus1Pos.dy + 30);
    drawLabel(canvas, "Memory", plus2Pos.dx, plus2Pos.dy + 30);
    drawLabel(canvas, "Tool", plus3Pos.dx, plus3Pos.dy + 30);

    // === LIGHTNING BOLT ON EMAIL NODE ===
    drawLightningBolt(canvas, emailPos.dx - 60, emailPos.dy - 10);

    // === PLUS BUTTON ON LOAD RESULTS NODE ===
    drawPlusButton(canvas, Offset(loadPos.dx + 60, loadPos.dy));
  }

  void drawGrid(Canvas canvas, Size size) {
    final step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.5, _gridPaint);
      }
    }
  }

  void drawRoundedRectNode(
    Canvas canvas,
    Offset pos,
    double width,
    double height,
    String label,
  ) {
    final rect = Rect.fromCenter(center: pos, width: width, height: height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, _nodeFillPaint);
    canvas.drawRRect(rrect, _nodeBorderPaint);

    // Connection points (small circles at left/right center)
    canvas.drawCircle(
      Offset(pos.dx - width / 2 + 10, pos.dy),
      5,
      _nodeBorderPaint,
    );
    canvas.drawCircle(
      Offset(pos.dx + width / 2 - 10, pos.dy),
      5,
      _nodeBorderPaint,
    );

    // Label below node
    drawLabel(canvas, label, pos.dx, pos.dy + height / 2 + 15);
  }

  void drawCircleNode(
    Canvas canvas,
    Offset pos,
    double diameter,
    String label,
  ) {
    canvas.drawCircle(pos, diameter / 2, _nodeFillPaint);
    canvas.drawCircle(pos, diameter / 2, _nodeBorderPaint);

    // Label below circle
    drawLabel(canvas, label, pos.dx, pos.dy + diameter / 2 + 15);
  }

  void connectNodes(Canvas canvas, Offset from, Offset to) {
    final start = Offset(from.dx + 60, from.dy);
    final end = Offset(to.dx - 60, to.dy);

    // Draw line
    canvas.drawLine(start, end, _linePaint);

    // Draw arrowhead (filled triangle, 10x10 base, pointing forward)
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final ux = dx / len;
    final uy = dy / len;

    final p1 = Offset(end.dx - ux * 10 - uy * 5, end.dy - uy * 10 + ux * 5);
    final p2 = Offset(end.dx - ux * 10 + uy * 5, end.dy - uy * 10 - ux * 5);

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, _arrowHeadPaint);
  }

  void connectDashedToSubNode(
    Canvas canvas,
    Offset from,
    Offset to,
    String label,
  ) {
    final start = Offset(from.dx, from.dy + 40);
    final end = Offset(to.dx, to.dy - 40);

    // Draw dashed line
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(path, _dashedLinePaint);

    // Draw diamond connector at start
    final diamondPath = Path()
      ..moveTo(start.dx, start.dy - 8)
      ..lineTo(start.dx + 8, start.dy)
      ..lineTo(start.dx, start.dy + 8)
      ..lineTo(start.dx - 8, start.dy)
      ..close();
    canvas.drawPath(diamondPath, _nodeBorderPaint);

    // Label above dashed line
    drawLabel(
      canvas,
      label,
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2 - 20,
    );
  }

  void drawPlusButton(Canvas canvas, Offset pos) {
    final rect = Rect.fromCenter(center: pos, width: 20, height: 20);
    canvas.drawRect(rect, _plusButtonPaint);
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 5),
      Offset(pos.dx, pos.dy + 5),
      _plusButtonPaint,
    );
    canvas.drawLine(
      Offset(pos.dx - 5, pos.dy),
      Offset(pos.dx + 5, pos.dy),
      _plusButtonPaint,
    );
  }

  void drawLightningBolt(Canvas canvas, double x, double y) {
    Path lightning = Path()
      ..moveTo(x, y)
      ..lineTo(x + 10, y - 10)
      ..lineTo(x + 20, y)
      ..lineTo(x + 10, y + 10)
      ..close();
    canvas.drawPath(lightning, Paint()..color = const Color(0xFFFF5555));
  }

  void drawLabel(Canvas canvas, String text, double x, double y) {
    _textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset(x - _textPainter.width / 2, y - _textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
