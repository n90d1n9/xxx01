import 'dart:math' as math;
import 'dart:ui';

import 'svg_element.dart';

class SvgPath extends SvgElement {
  final String d;

  SvgPath({required this.d, required super.style, super.transform});

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    applyTransform(canvas);
    final path = _parsePath(d);
    path.fillType = style.fillRule ?? PathFillType.nonZero;

    if (style.fill?.color != null && !style.fill!.isNone) {
      canvas.drawPath(path, style.createFillPaint());
    }

    if (style.stroke?.color != null && !style.stroke!.isNone) {
      canvas.drawPath(path, style.createStrokePaint());
    }
    restoreTransform(canvas);
  }

  Path _parsePath(String d) {
    final path = Path();
    final commands = _tokenizePath(d);

    double currentX = 0, currentY = 0;
    double startX = 0, startY = 0;
    double lastControlX = 0, lastControlY = 0;
    String? lastCommand;

    for (var i = 0; i < commands.length; i++) {
      var cmd = commands[i];

      // Handle implicit commands
      if (RegExp(r'^-?\d').hasMatch(cmd)) {
        if (lastCommand == 'M')
          cmd = 'L';
        else if (lastCommand == 'm')
          cmd = 'l';
        else if (lastCommand != null)
          cmd = lastCommand;
        i--; // Re-process this token
      }

      switch (cmd) {
        case 'M':
          currentX = double.parse(commands[++i]);
          currentY = double.parse(commands[++i]);
          startX = currentX;
          startY = currentY;
          path.moveTo(currentX, currentY);
          lastCommand = 'M';
          break;

        case 'm':
          currentX += double.parse(commands[++i]);
          currentY += double.parse(commands[++i]);
          startX = currentX;
          startY = currentY;
          path.moveTo(currentX, currentY);
          lastCommand = 'm';
          break;

        case 'L':
          currentX = double.parse(commands[++i]);
          currentY = double.parse(commands[++i]);
          path.lineTo(currentX, currentY);
          lastCommand = 'L';
          break;

        case 'l':
          currentX += double.parse(commands[++i]);
          currentY += double.parse(commands[++i]);
          path.lineTo(currentX, currentY);
          lastCommand = 'l';
          break;

        case 'H':
          currentX = double.parse(commands[++i]);
          path.lineTo(currentX, currentY);
          lastCommand = 'H';
          break;

        case 'h':
          currentX += double.parse(commands[++i]);
          path.lineTo(currentX, currentY);
          lastCommand = 'h';
          break;

        case 'V':
          currentY = double.parse(commands[++i]);
          path.lineTo(currentX, currentY);
          lastCommand = 'V';
          break;

        case 'v':
          currentY += double.parse(commands[++i]);
          path.lineTo(currentX, currentY);
          lastCommand = 'v';
          break;

        case 'C':
          final x1 = double.parse(commands[++i]);
          final y1 = double.parse(commands[++i]);
          final x2 = double.parse(commands[++i]);
          final y2 = double.parse(commands[++i]);
          currentX = double.parse(commands[++i]);
          currentY = double.parse(commands[++i]);
          path.cubicTo(x1, y1, x2, y2, currentX, currentY);
          lastControlX = x2;
          lastControlY = y2;
          lastCommand = 'C';
          break;

        case 'c':
          final x1 = currentX + double.parse(commands[++i]);
          final y1 = currentY + double.parse(commands[++i]);
          final x2 = currentX + double.parse(commands[++i]);
          final y2 = currentY + double.parse(commands[++i]);
          currentX += double.parse(commands[++i]);
          currentY += double.parse(commands[++i]);
          path.cubicTo(x1, y1, x2, y2, currentX, currentY);
          lastControlX = x2;
          lastControlY = y2;
          lastCommand = 'c';
          break;

        case 'S':
          final x2 = double.parse(commands[++i]);
          final y2 = double.parse(commands[++i]);
          final x1 = 2 * currentX - lastControlX;
          final y1 = 2 * currentY - lastControlY;
          currentX = double.parse(commands[++i]);
          currentY = double.parse(commands[++i]);
          path.cubicTo(x1, y1, x2, y2, currentX, currentY);
          lastControlX = x2;
          lastControlY = y2;
          lastCommand = 'S';
          break;

        case 's':
          final x2 = currentX + double.parse(commands[++i]);
          final y2 = currentY + double.parse(commands[++i]);
          final x1 = 2 * currentX - lastControlX;
          final y1 = 2 * currentY - lastControlY;
          currentX += double.parse(commands[++i]);
          currentY += double.parse(commands[++i]);
          path.cubicTo(x1, y1, x2, y2, currentX, currentY);
          lastControlX = x2;
          lastControlY = y2;
          lastCommand = 's';
          break;

        case 'Q':
          final x1 = double.parse(commands[++i]);
          final y1 = double.parse(commands[++i]);
          currentX = double.parse(commands[++i]);
          currentY = double.parse(commands[++i]);
          path.quadraticBezierTo(x1, y1, currentX, currentY);
          lastControlX = x1;
          lastControlY = y1;
          lastCommand = 'Q';
          break;

        case 'q':
          final x1 = currentX + double.parse(commands[++i]);
          final y1 = currentY + double.parse(commands[++i]);
          currentX += double.parse(commands[++i]);
          currentY += double.parse(commands[++i]);
          path.quadraticBezierTo(x1, y1, currentX, currentY);
          lastControlX = x1;
          lastControlY = y1;
          lastCommand = 'q';
          break;

        case 'T':
          final x1 = 2 * currentX - lastControlX;
          final y1 = 2 * currentY - lastControlY;
          currentX = double.parse(commands[++i]);
          currentY = double.parse(commands[++i]);
          path.quadraticBezierTo(x1, y1, currentX, currentY);
          lastControlX = x1;
          lastControlY = y1;
          lastCommand = 'T';
          break;

        case 't':
          final x1 = 2 * currentX - lastControlX;
          final y1 = 2 * currentY - lastControlY;
          currentX += double.parse(commands[++i]);
          currentY += double.parse(commands[++i]);
          path.quadraticBezierTo(x1, y1, currentX, currentY);
          lastControlX = x1;
          lastControlY = y1;
          lastCommand = 't';
          break;

        case 'A':
          final rx = double.parse(commands[++i]);
          final ry = double.parse(commands[++i]);
          final rotation = double.parse(commands[++i]);
          final largeArc = int.parse(commands[++i]) == 1;
          final sweep = int.parse(commands[++i]) == 1;
          final x = double.parse(commands[++i]);
          final y = double.parse(commands[++i]);
          _addArc(
            path,
            currentX,
            currentY,
            rx,
            ry,
            rotation,
            largeArc,
            sweep,
            x,
            y,
          );
          currentX = x;
          currentY = y;
          lastCommand = 'A';
          break;

        case 'a':
          final rx = double.parse(commands[++i]);
          final ry = double.parse(commands[++i]);
          final rotation = double.parse(commands[++i]);
          final largeArc = int.parse(commands[++i]) == 1;
          final sweep = int.parse(commands[++i]) == 1;
          final x = currentX + double.parse(commands[++i]);
          final y = currentY + double.parse(commands[++i]);
          _addArc(
            path,
            currentX,
            currentY,
            rx,
            ry,
            rotation,
            largeArc,
            sweep,
            x,
            y,
          );
          currentX = x;
          currentY = y;
          lastCommand = 'a';
          break;

        case 'Z':
        case 'z':
          path.close();
          currentX = startX;
          currentY = startY;
          lastCommand = cmd;
          break;
      }
    }

    return path;
  }

  void _addArc(
    Path path,
    double x1,
    double y1,
    double rx,
    double ry,
    double rotation,
    bool largeArc,
    bool sweep,
    double x2,
    double y2,
  ) {
    if (rx == 0 || ry == 0) {
      path.lineTo(x2, y2);
      return;
    }

    rx = rx.abs();
    ry = ry.abs();

    final phi = rotation * math.pi / 180;
    final cosPhi = math.cos(phi);
    final sinPhi = math.sin(phi);

    // Step 1: Transform to unit circle
    final dx = (x1 - x2) / 2;
    final dy = (y1 - y2) / 2;
    final x1p = cosPhi * dx + sinPhi * dy;
    final y1p = -sinPhi * dx + cosPhi * dy;

    // Step 2: Correct radii
    final lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry);
    if (lambda > 1) {
      rx *= math.sqrt(lambda);
      ry *= math.sqrt(lambda);
    }

    // Step 3: Find center
    final sq = math.max(
      0.0,
      (rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p) /
          (rx * rx * y1p * y1p + ry * ry * x1p * x1p),
    );
    final sign = largeArc != sweep ? 1 : -1;
    final coef = sign * math.sqrt(sq);
    final cxp = coef * rx * y1p / ry;
    final cyp = -coef * ry * x1p / rx;

    final cx = cosPhi * cxp - sinPhi * cyp + (x1 + x2) / 2;
    final cy = sinPhi * cxp + cosPhi * cyp + (y1 + y2) / 2;

    // Step 4: Calculate angles
    double angle(double ux, double uy, double vx, double vy) {
      final dot = ux * vx + uy * vy;
      final mod = math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
      var rad = math.acos(dot / mod);
      if (ux * vy - uy * vx < 0) rad = -rad;
      return rad;
    }

    final theta1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    var dTheta = angle(
      (x1p - cxp) / rx,
      (y1p - cyp) / ry,
      (-x1p - cxp) / rx,
      (-y1p - cyp) / ry,
    );

    if (sweep && dTheta < 0) {
      dTheta += 2 * math.pi;
    } else if (!sweep && dTheta > 0) {
      dTheta -= 2 * math.pi;
    }

    // Draw arc using bezier curves
    final segments = (dTheta.abs() / (math.pi / 2)).ceil();
    final delta = dTheta / segments;

    for (var i = 0; i < segments; i++) {
      final theta = theta1 + delta * i;
      final thetaNext = theta + delta;

      final alpha =
          math.sin(delta) *
          (math.sqrt(4 + 3 * math.tan(delta / 2) * math.tan(delta / 2)) - 1) /
          3;

      final cos1 = math.cos(theta);
      final sin1 = math.sin(theta);
      final cos2 = math.cos(thetaNext);
      final sin2 = math.sin(thetaNext);

      final q1x = cos1 - sin1 * alpha;
      final q1y = sin1 + cos1 * alpha;
      final q2x = cos2 + sin2 * alpha;
      final q2y = sin2 - cos2 * alpha;

      final cp1x = cosPhi * rx * q1x - sinPhi * ry * q1y + cx;
      final cp1y = sinPhi * rx * q1x + cosPhi * ry * q1y + cy;
      final cp2x = cosPhi * rx * q2x - sinPhi * ry * q2y + cx;
      final cp2y = sinPhi * rx * q2x + cosPhi * ry * q2y + cy;
      final ex = cosPhi * rx * cos2 - sinPhi * ry * sin2 + cx;
      final ey = sinPhi * rx * cos2 + cosPhi * ry * sin2 + cy;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, ex, ey);
    }
  }

  List<String> _tokenizePath(String d) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < d.length; i++) {
      final char = d[i];

      if (RegExp(r'[MmLlHhVvCcSsQqTtAaZz]').hasMatch(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString().trim());
          buffer.clear();
        }
        tokens.add(char);
      } else if (char == ',' ||
          char == ' ' ||
          char == '\n' ||
          char == '\r' ||
          char == '\t') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString().trim());
          buffer.clear();
        }
      } else if (char == '-' &&
          buffer.isNotEmpty &&
          !buffer.toString().endsWith('e')) {
        tokens.add(buffer.toString().trim());
        buffer.clear();
        buffer.write(char);
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString().trim());
    }

    return tokens.where((t) => t.isNotEmpty).toList();
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
