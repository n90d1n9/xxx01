import 'package:flutter/material.dart';

enum ConnectorPosition { startNode, endNode }

enum ConnectionLineType { curve, bezier, elbow, straight }

enum ConnectorLineStyle { solid, dashed, dotted }

enum ArrowType { standard, triangle, circle, diamond }

class ConnectionData {
  final Offset start;
  final Offset end;
  final Color color;
  final ConnectorPosition position;
  final ConnectionLineType lineType;
  final ConnectorLineStyle lineStyle;
  final ArrowType arrowType;
  final double strokeWidth;

  ConnectionData({
    required this.start,
    required this.end,
    this.color = Colors.blueAccent,
    this.position = ConnectorPosition.startNode,
    this.lineType = ConnectionLineType.curve,
    this.lineStyle = ConnectorLineStyle.solid,
    this.arrowType = ArrowType.standard,
    this.strokeWidth = 2.0,
  });

  ConnectionData copyWith({
    Offset? start,
    Offset? end,
    Color? color,
    ConnectorPosition? position,
    ConnectionLineType? lineType,
    ConnectorLineStyle? lineStyle,
    ArrowType? arrowType,
    double? strokeWidth,
  }) {
    return ConnectionData(
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      position: position ?? this.position,
      lineType: lineType ?? this.lineType,
      lineStyle: lineStyle ?? this.lineStyle,
      arrowType: arrowType ?? this.arrowType,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}
