import 'package:flutter/material.dart';

class EndArchiveIconWithPhysicalModel extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;

  const EndArchiveIconWithPhysicalModel({
    super.key,
    this.width = 106,
    this.height = 59,
    this.backgroundColor = const Color(0xFFFFB8A9),
    this.strokeColor = const Color(0xFF979797),
    this.circleColor = const Color(0xFFD8D8D8),
    this.textColor = Colors.black,
    this.iconColor = const Color(0xFF191919),
  });

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.25),
      borderRadius: _getBorderRadius(),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        size: Size(width, height),
        painter: _EndArchiveShapePainter(
          backgroundColor: backgroundColor,
          strokeColor: strokeColor,
          circleColor: circleColor,
          textColor: textColor,
          iconColor: iconColor,
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    // Create a BorderRadius that approximates the curved shape (now on right side)
    return const BorderRadius.only(
      topRight: Radius.circular(30),
      bottomRight: Radius.circular(30),
      topLeft: Radius.zero,
      bottomLeft: Radius.zero,
    );
  }
}

class _EndArchiveShapePainter extends CustomPainter {
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;

  _EndArchiveShapePainter({
    required this.backgroundColor,
    required this.strokeColor,
    required this.circleColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw non-mirrored version with curved side on right
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, 58);
    path.lineTo(67.0454545, 58);

    path.cubicTo(76.145601, 58, 84.3842374, 54.7540644, 90.3478371, 49.5060967);
    path.cubicTo(96.3114369, 44.2581289, 100, 37.0081289, 100, 29);
    path.cubicTo(
      100,
      20.9918711,
      96.3114369,
      13.7418711,
      90.3478371,
      8.49390335,
    );
    path.cubicTo(84.3842374, 3.24593556, 76.145601, 0, 67.0454545, 0);
    path.lineTo(0, 0);
    path.close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);

    // Draw circle on left side
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = circleColor;

    final circleCenter = const Offset(
      12,
      29,
    ); // Adjusted position for left side
    canvas.drawCircle(circleCenter, 6, circlePaint);
    canvas.drawCircle(circleCenter, 6, strokePaint);

    // Draw archive icon and text (same as before)
    _drawArchiveIcon(canvas);
    _drawText(canvas);
  }

  void _drawArchiveIcon(Canvas canvas) {
    // Same archive icon implementation as above
    final iconPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = iconColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = iconColor;

    canvas.save();
    canvas.translate(24.5, 20);

    // ... rest of archive icon drawing code
    canvas.restore();
  }

  void _drawText(Canvas canvas) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'End',
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(44.5, 21));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
