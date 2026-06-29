import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

import '../widget/connection_painter.dart';
import 'connection_state.dart';

class ConnectionData {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final String sourcePortId;
  final String targetPortId;
  final Offset start;
  final Offset end;
  final Color color;
  final ConnectorPosition position;
  final ConnectionLineType lineType;
  final ConnectorLineStyle lineStyle;
  final ArrowType arrowType;
  final double strokeWidth;

  ConnectionData({
    String? id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.sourcePortId,
    required this.targetPortId,
    required this.start,
    required this.end,
    this.color = Colors.blueAccent,
    this.position = ConnectorPosition.startNode,
    this.lineType = ConnectionLineType.curved,
    this.lineStyle = ConnectorLineStyle.solid,
    this.arrowType = ArrowType.standard,
    this.strokeWidth = 2.0,
  }) : id = id ?? UuidV4().generate();

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
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      sourcePortId: sourcePortId,
      targetPortId: targetPortId,
      id: id,
    );
  }
}
