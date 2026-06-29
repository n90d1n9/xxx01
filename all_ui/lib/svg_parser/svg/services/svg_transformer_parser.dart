import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Parse SVG transform attribute to Matrix4
class SvgTransformParser {
  /// Parse transform string to Matrix4
  static Matrix4? parseTransform(String? transform) {
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
          _applyTranslate(matrix, values);
          break;
        case 'scale':
          _applyScale(matrix, values);
          break;
        case 'rotate':
          _applyRotate(matrix, values);
          break;
        case 'skewX':
          _applySkewX(matrix, values);
          break;
        case 'skewY':
          _applySkewY(matrix, values);
          break;
        case 'matrix':
          _applyMatrix(matrix, values);
          break;
      }
    }

    return matrix;
  }

  static void _applyTranslate(Matrix4 matrix, List<double> values) {
    final tx = values[0];
    final ty = values.length > 1 ? values[1] : 0.0;
    matrix.translate(tx, ty);
  }

  static void _applyScale(Matrix4 matrix, List<double> values) {
    final sx = values[0];
    final sy = values.length > 1 ? values[1] : sx;
    matrix.scale(sx, sy);
  }

  static void _applyRotate(Matrix4 matrix, List<double> values) {
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
  }

  static void _applySkewX(Matrix4 matrix, List<double> values) {
    final angle = values[0] * math.pi / 180;
    matrix.multiply(
      Matrix4(1, math.tan(angle), 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    );
  }

  static void _applySkewY(Matrix4 matrix, List<double> values) {
    final angle = values[0] * math.pi / 180;
    matrix.multiply(
      Matrix4(1, 0, 0, 0, math.tan(angle), 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    );
  }

  static void _applyMatrix(Matrix4 matrix, List<double> values) {
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
  }

  /// Convert Matrix4 to SVG transform string
  static String matrixToTransform(Matrix4 matrix) {
    final storage = matrix.storage;

    // Extract 2D transform values
    final a = storage[0];
    final b = storage[1];
    final c = storage[4];
    final d = storage[5];
    final e = storage[12];
    final f = storage[13];

    // Check if it's an identity matrix
    if (a == 1 && b == 0 && c == 0 && d == 1 && e == 0 && f == 0) {
      return '';
    }

    return 'matrix($a,$b,$c,$d,$e,$f)';
  }
}
