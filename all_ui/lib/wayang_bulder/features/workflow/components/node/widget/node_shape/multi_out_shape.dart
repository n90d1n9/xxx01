import 'package:flutter/material.dart';

class GuardrailAgentNode extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;

  const GuardrailAgentNode({
    super.key,
    this.width = 200,
    this.height = 104,
    this.backgroundColor = const Color(0xFFFFF9F2),
    this.strokeColor = const Color(0xFF979797),
    this.circleColor = const Color(0xFFD8D8D8),
    this.textColor = const Color(0xFF5C5B5B),
    this.iconColor = const Color(0xFF5C5B5B),
    this.borderColor = const Color(0xFFE20C0C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _GuardrailAgentPainter(
          backgroundColor: backgroundColor,
          strokeColor: strokeColor,
          circleColor: circleColor,
          textColor: textColor,
          iconColor: iconColor,
          borderColor: borderColor,
        ),
      ),
    );
  }
}

class _GuardrailAgentPainter extends CustomPainter {
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;

  _GuardrailAgentPainter({
    required this.backgroundColor,
    required this.strokeColor,
    required this.circleColor,
    required this.textColor,
    required this.iconColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawMainContainer(canvas);
    _drawConditionalBoxes(canvas);
    _drawCircles(canvas);
    _drawHeaderSection(canvas);
    _drawTextElements(canvas);
  }

  void _drawMainContainer(Canvas canvas) {
    // Main container with shadow and border
    final mainRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7, 0.5, 187, 103),
      const Radius.circular(8),
    );

    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = 1.0;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = 1.0;

    canvas.drawRRect(mainRect, backgroundPaint);
    canvas.drawRRect(mainRect, borderPaint);
    canvas.drawRRect(mainRect, strokePaint);
  }

  void _drawConditionalBoxes(Canvas canvas) {
    // "If/Pass" box
    final ifBoxRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(122, 57.5, 63, 20),
      const Radius.circular(8),
    );

    final elseBoxRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(122, 79.5, 63, 20),
      const Radius.circular(8),
    );

    final boxPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final boxStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = 1.0;

    // Draw filled boxes
    canvas.drawRRect(ifBoxRect, boxPaint);
    canvas.drawRRect(elseBoxRect, boxPaint);

    // Draw strokes
    canvas.drawRRect(ifBoxRect, boxStrokePaint);
    canvas.drawRRect(elseBoxRect, boxStrokePaint);

    // Draw white background for boxes (slightly larger to cover strokes)
    final ifBoxBgRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(121.5, 57, 64, 21),
      const Radius.circular(8),
    );

    final elseBoxBgRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(121.5, 79, 64, 21),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawRRect(ifBoxBgRect, bgPaint);
    canvas.drawRRect(elseBoxBgRect, bgPaint);
  }

  void _drawCircles(Canvas canvas) {
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = circleColor;

    final circleStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = 1.0;

    // Right side circles
    final rightCircle1 = const Offset(188 + 6, 60.5 + 6);
    final rightCircle2 = const Offset(188 + 6, 83.5 + 6);

    // Left side circle
    final leftCircle = const Offset(0 + 6, 44.5 + 6);

    canvas.drawCircle(rightCircle1, 6, circlePaint);
    canvas.drawCircle(rightCircle1, 6, circleStrokePaint);

    canvas.drawCircle(rightCircle2, 6, circlePaint);
    canvas.drawCircle(rightCircle2, 6, circleStrokePaint);

    canvas.drawCircle(leftCircle, 6, circlePaint);
    canvas.drawCircle(leftCircle, 6, circleStrokePaint);
  }

  void _drawHeaderSection(Canvas canvas) {}

  void _drawTextElements(Canvas canvas) {
    // Main header texts
    _drawText(canvas, "Guardrail Agent", const Offset(50.5, -14), 12);
    _drawText(canvas, "Safety", const Offset(50.5, -3), 8);

    // Conditional box texts
    _drawText(canvas, "Pass", const Offset(131.5, 38), 8);
    _drawText(canvas, "Fail", const Offset(131.5, 62), 8);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset transformOffset,
    double fontSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, transformOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
