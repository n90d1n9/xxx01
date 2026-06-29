import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/legacy.dart';

class DrawingPoint {
  final Offset point;
  final Paint paint;
  final String userId;
  final DateTime timestamp;
  final double pressure;
  final double tiltX;
  final double tiltY;
  DrawingPoint({
    required this.point,
    required this.paint,
    required this.userId,
    required this.timestamp,
    this.pressure = 1.0,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
  });
  Map<String, dynamic> toJson() => {
    'x': point.dx,
    'y': point.dy,
    'userId': userId,
    'timestamp': timestamp.toIso8601String(),
    'pressure': pressure,
    'tiltX': tiltX,
    'tiltY': tiltY,
    'color': paint.color.value,
    'strokeWidth': paint.strokeWidth,
  };
  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    final paint =
        Paint()
          ..color = Color(json['color'])
          ..strokeWidth = json['strokeWidth']
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    return DrawingPoint(
      point: Offset(json['x'], json['y']),
      paint: paint,
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      pressure: json['pressure'] ?? 1.0,
      tiltX: json['tiltX'] ?? 0.0,
      tiltY: json['tiltY'] ?? 0.0,
    );
  }
}
