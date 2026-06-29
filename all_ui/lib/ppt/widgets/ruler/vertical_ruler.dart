import 'package:flutter/material.dart';

class VerticalRuler extends StatelessWidget {
  final double height;
  final double cursorY;

  const VerticalRuler({super.key, required this.height, this.cursorY = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Color(0xFF334155))),
      ),
      child: CustomPaint(
        size: Size(30, height),
        painter: VerticalRulerPainter(pageHeight: height, cursorY: cursorY),
      ),
    );
  }
}

class VerticalRulerPainter extends CustomPainter {
  final double pageHeight;
  final double cursorY;

  VerticalRulerPainter({required this.pageHeight, required this.cursorY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    const pixelsPerInch = 96.0;
    final totalInches = (size.height / pixelsPerInch).ceil();

    for (int i = 0; i <= totalInches * 8; i++) {
      final inches = i / 8.0;
      final y = inches * pixelsPerInch;

      if (y > size.height) break;

      final isInch = i % 8 == 0;
      final isHalfInch = i % 4 == 0;
      final isQuarterInch = i % 2 == 0;

      double lineWidth;
      if (isInch) {
        lineWidth = 20;
        if (i > 0) {
          canvas.save();
          canvas.translate(15, y);
          canvas.rotate(-1.5708);
          textPainter.text = TextSpan(
            text: '${i ~/ 8}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(-textPainter.width / 2, -4));
          canvas.restore();
        }
      } else if (isHalfInch) {
        lineWidth = 14;
      } else if (isQuarterInch) {
        lineWidth = 10;
      } else {
        lineWidth = 6;
      }

      canvas.drawLine(
        Offset(size.width - lineWidth, y),
        Offset(size.width, y),
        paint,
      );
    }

    if (cursorY > 0 && cursorY < size.height) {
      final cursorPaint =
          Paint()
            ..color = const Color(0xFF6366F1)
            ..strokeWidth = 2;

      canvas.drawLine(
        Offset(0, cursorY),
        Offset(size.width, cursorY),
        cursorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(VerticalRulerPainter oldDelegate) {
    return oldDelegate.cursorY != cursorY;
  }
}
