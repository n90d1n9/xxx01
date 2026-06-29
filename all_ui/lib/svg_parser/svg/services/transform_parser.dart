// parsers/transform_parser.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TransformParser {
  static Matrix4? parse(String? transform) {
    if (transform == null || transform.isEmpty) return null;

    final matrix = Matrix4.identity();
    final regex = RegExp(r'(\w+)\s*\(([^)]+)\)');
    final matches = regex.allMatches(transform);

    for (var match in matches) {
      final type = match.group(1);
      final values =
          match
              .group(2)!
              .split(RegExp(r'[\s,]+'))
              .map((v) => double.tryParse(v) ?? 0)
              .toList();

      switch (type) {
        case 'translate':
          final tx = values[0];
          final ty = values.length > 1 ? values[1] : 0.0;
          matrix.translate(tx, ty);
          break;
        case 'scale':
          final sx = values[0];
          final sy = values.length > 1 ? values[1] : sx;
          matrix.scale(sx, sy);
          break;
        case 'rotate':
          final angle = values[0] * math.pi / 180;
          if (values.length > 2) {
            final cx = values[1];
            final cy = values[2];
            matrix.translate(cx, cy);
            matrix.rotateZ(angle);
            matrix.translate(-cx, -cy);
          } else {
            matrix.rotateZ(angle);
          }
          break;
        case 'skewX':
          final angle = values[0] * math.pi / 180;
          matrix.multiply(
            Matrix4(
              1,
              math.tan(angle),
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              1,
            ),
          );
          break;
        case 'skewY':
          final angle = values[0] * math.pi / 180;
          matrix.multiply(
            Matrix4(
              1,
              0,
              0,
              0,
              math.tan(angle),
              1,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              1,
            ),
          );
          break;
        case 'matrix':
          if (values.length == 6) {
            matrix.multiply(
              Matrix4(
                values[0],
                values[2],
                0,
                values[4],
                values[1],
                values[3],
                0,
                values[5],
                0,
                0,
                1,
                0,
                0,
                0,
                0,
                1,
              ),
            );
          }
          break;
      }
    }

    return matrix;
  }
}
