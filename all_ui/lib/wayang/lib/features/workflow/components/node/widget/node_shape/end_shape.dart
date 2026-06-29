import 'package:flutter/material.dart';

class EndArchiveIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;

  const EndArchiveIcon({
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
        painter: _EndArchivePainter(
          backgroundColor: backgroundColor,
          strokeColor: strokeColor,
          circleColor: circleColor,
          textColor: textColor,
          iconColor: iconColor,
        ),
      ),
    );
  }
}

class _EndArchivePainter extends CustomPainter {
  final Color backgroundColor;
  final Color strokeColor;
  final Color circleColor;
  final Color textColor;
  final Color iconColor;

  _EndArchivePainter({
    required this.backgroundColor,
    required this.strokeColor,
    required this.circleColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Apply the scale transformation (mirror horizontally)
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2); // Move to center
    canvas.scale(-1, 1); // Mirror horizontally
    canvas.translate(-size.width / 2, -size.height / 2); // Move back

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = 1.0;

    // Draw the main rounded shape (now reversed)
    final path = Path();
    path.moveTo(100, 0);
    path.lineTo(100, 58);
    path.lineTo(32.9545455, 58);

    // Draw the curved side (now on the right due to mirroring)
    path.cubicTo(23.854399, 58, 15.6157626, 54.7540644, 9.6521629, 49.5060967);
    path.cubicTo(3.68856314, 44.2581289, 0, 37.0081289, 0, 29);
    path.cubicTo(0, 20.9918711, 3.68856314, 13.7418711, 9.6521629, 8.49390335);
    path.cubicTo(15.6157626, 3.24593556, 23.854399, 0, 32.9545455, 0);
    path.lineTo(100, 0);
    path.close();

    // Fill the shape
    canvas.drawPath(path, paint);
    // Stroke the shape
    canvas.drawPath(path, strokePaint);

    // Draw the circle (position will be mirrored)
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = circleColor;

    // Calculate mirrored circle position
    final circleCenterX = size.width - (94 + 6); // Mirror the x position
    final circleCenter = Offset(circleCenterX, 23 + 6);

    canvas.drawCircle(circleCenter, 6, circlePaint);
    canvas.drawCircle(circleCenter, 6, strokePaint);

    canvas.restore(); // Restore from mirror transformation

    // Draw the archive icon (not mirrored, positioned normally)
    _drawArchiveIcon(canvas);

    // Draw the text (not mirrored, positioned normally)
    _drawText(canvas);
  }

  void _drawArchiveIcon(Canvas canvas) {
    final iconPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = iconColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = iconColor;

    // Transform for the icon group - adjusted position
    canvas.save();
    canvas.translate(24.5, 20);

    // Draw the top curved path
    final topPath = Path();
    topPath.moveTo(10, 0);
    topPath.lineTo(9.44349322, 7.15508717);
    topPath.cubicTo(9.3625052, 8.19636165, 8.49393456, 9, 7.44951529, 9);
    topPath.lineTo(2.55048471, 9);
    topPath.cubicTo(
      1.50606544,
      9,
      0.637494795,
      8.19636165,
      0.55650678,
      7.15508717,
    );
    topPath.lineTo(0, 0);

    canvas.drawPath(topPath, iconPaint);

    // Draw the rectangle (archive top)
    final rectPath = Path();
    rectPath.moveTo(3.15797572, 2.5);
    rectPath.lineTo(12.8420243, 2.5);
    rectPath.cubicTo(
      13.1390234,
      2.5,
      13.3254599,
      2.54641281,
      13.4884229,
      2.63356635,
    );
    rectPath.cubicTo(
      13.6513858,
      2.7207199,
      13.7792801,
      2.84861419,
      13.8664336,
      3.01157715,
    );
    rectPath.cubicTo(13.9535872, 3.17454011, 14, 3.36097661, 14, 3.65797572);
    rectPath.lineTo(14, 3.84202428);
    rectPath.cubicTo(
      14,
      4.13902339,
      13.9535872,
      4.32545989,
      13.8664336,
      4.48842285,
    );
    rectPath.cubicTo(
      13.7792801,
      4.65138581,
      13.6513858,
      4.7792801,
      13.4884229,
      4.86643365,
    );
    rectPath.cubicTo(13.3254599, 4.95358719, 13.1390234, 5, 12.8420243, 5);
    rectPath.lineTo(3.15797572, 5);
    rectPath.cubicTo(
      2.86097661,
      5,
      2.67454011,
      4.95358719,
      2.51157715,
      4.86643365,
    );
    rectPath.cubicTo(
      2.34861419,
      4.7792801,
      2.2207199,
      4.65138581,
      2.13356635,
      4.48842285,
    );
    rectPath.cubicTo(2.04641281, 4.32545989, 2, 4.13902339, 2, 3.84202428);
    rectPath.lineTo(2, 3.65797572);
    rectPath.cubicTo(
      2,
      3.36097661,
      2.04641281,
      3.17454011,
      2.13356635,
      3.01157715,
    );
    rectPath.cubicTo(
      2.2207199,
      2.84861419,
      2.34861419,
      2.7207199,
      2.51157715,
      2.63356635,
    );
    rectPath.cubicTo(2.67454011, 2.54641281, 2.86097661, 2.5, 3.15797572, 2.5);
    rectPath.close();

    canvas.drawPath(rectPath, iconPaint);

    // Draw the small rectangle at the bottom
    final smallRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 7, 4, 1.5),
      const Radius.circular(0.75),
    );
    canvas.drawRRect(smallRect, fillPaint);

    canvas.restore();
  }

  void _drawText(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'End',
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      const Offset(44.5, 21),
    ); // Adjusted position for "End" text
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
