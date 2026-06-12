import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/legacy.dart';

import 'drawing_tool.dart';
import 'shape_fill_style.dart';
import 'line_style.dart';
import 'drawing_point.dart';

class DrawingPath {
  final List<DrawingPoint> points;
  final String id;
  final String userId;
  final DrawingTool tool;
  final String? text;
  final bool isLocked;
  final ShapeFillStyle fillStyle;
  final Color? fillColor;
  final LineStyle lineStyle;
  final double opacity;
  final Color? stickyNoteColor;
  DrawingPath({
    required this.points,
    required this.id,
    required this.userId,
    required this.tool,
    this.text,
    this.isLocked = false,
    this.fillStyle = ShapeFillStyle.none,
    this.fillColor,
    this.lineStyle = LineStyle.solid,
    this.opacity = 1.0,
    this.stickyNoteColor,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'tool': tool.toString(),
    'text': text,
    'isLocked': isLocked,
    'fillStyle': fillStyle.toString(),
    'fillColor': fillColor?.value,
    'lineStyle': lineStyle.toString(),
    'opacity': opacity,
    'stickyNoteColor': stickyNoteColor?.value,
    'points': points.map((p) => p.toJson()).toList(),
  };
  factory DrawingPath.fromJson(Map<String, dynamic> json) {
    return DrawingPath(
      id: json['id'],
      userId: json['userId'],
      tool: DrawingTool.values.firstWhere(
        (t) => t.toString() == json['tool'],
        orElse: () => DrawingTool.pen,
      ),
      text: json['text'],
      isLocked: json['isLocked'] ?? false,
      fillStyle: ShapeFillStyle.values.firstWhere(
        (f) => f.toString() == json['fillStyle'],
        orElse: () => ShapeFillStyle.none,
      ),
      fillColor: json['fillColor'] != null ? Color(json['fillColor']) : null,
      lineStyle: LineStyle.values.firstWhere(
        (l) => l.toString() == json['lineStyle'],
        orElse: () => LineStyle.solid,
      ),
      opacity: json['opacity'] ?? 1.0,
      stickyNoteColor: json['stickyNoteColor'] != null
          ? Color(json['stickyNoteColor'])
          : null,
      points: (json['points'] as List)
          .map((p) => DrawingPoint.fromJson(p))
          .toList(),
    );
  }
  DrawingPath copyWith({
    bool? isLocked,
    ShapeFillStyle? fillStyle,
    Color? fillColor,
    LineStyle? lineStyle,
    double? opacity,
    List<DrawingPoint>? points,
    String? text,
  }) {
    return DrawingPath(
      points: points ?? this.points,
      id: id,
      userId: userId,
      tool: tool,
      text: text ?? this.text,
      isLocked: isLocked ?? this.isLocked,
      fillStyle: fillStyle ?? this.fillStyle,
      fillColor: fillColor ?? this.fillColor,
      lineStyle: lineStyle ?? this.lineStyle,
      opacity: opacity ?? this.opacity,
      stickyNoteColor: stickyNoteColor,
    );
  }

  Rect getBounds() {
    if (points.isEmpty) return Rect.zero;
    var minX = points.first.point.dx;
    var maxX = points.first.point.dx;
    var minY = points.first.point.dy;
    var maxY = points.first.point.dy;
    for (var point in points) {
      minX = math.min(minX, point.point.dx);
      maxX = math.max(maxX, point.point.dx);
      minY = math.min(minY, point.point.dy);
      maxY = math.max(maxY, point.point.dy);
    }
    return Rect.fromLTRB(minX - 10, minY - 10, maxX + 10, maxY + 10);
  }
}
