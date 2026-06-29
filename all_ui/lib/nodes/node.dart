import 'package:flutter/material.dart';

class NodeData {
  final String id;
  final String label;
  final Offset position;
  final List<String> features;
  final NodeType type;
  final Map<String, dynamic> properties;
  final NodeConfig config;

  NodeData({
    required this.id,
    required this.label,
    this.position = Offset.zero,
    this.features = const [],
    this.type = NodeType.llm,
    this.properties = const {},
    NodeConfig? config,
  }) : config = config ?? NodeConfig();

  NodeData copyWith({
    String? id,
    String? label,
    Offset? position,
    List<String>? features,
    NodeType? type,
    Map<String, dynamic>? properties,
    NodeConfig? config,
  }) {
    return NodeData(
      id: id ?? this.id,
      label: label ?? this.label,
      position: position ?? this.position,
      features: features ?? this.features,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      config: config ?? this.config,
    );
  }
}

class Connection {
  final String sourceId;
  final String targetId;

  Connection({required this.sourceId, required this.targetId});
}

enum NodeType { start, llm, decision, end, agent }

class NodeConfig {
  final TextStyle? labelStyle;
  final Color fillColor;
  final Color borderColor;
  final double? width;
  final double? height;

  NodeConfig({
    this.fillColor = Colors.white,
    this.borderColor = Colors.grey,
    this.width,
    this.height,
    this.labelStyle = const TextStyle(
      fontFamily: 'Helvetica',
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: Color.fromARGB(255, 55, 55, 55),
    ),
  });
}

enum PortPosition { left, right, top, bottom }

enum PortType { input, output, feature }

class PortData {
  final String id;
  final String nodeId;
  final NodeType type;
  final Map<String, dynamic> properties;
  final PortConfig config;

  PortData({
    required this.id,
    required this.nodeId,
    this.type = NodeType.llm,
    this.properties = const {},
    PortConfig? config,
  }) : config = config ?? PortConfig(portId: DateTime.now().toIso8601String());
}

class PortConfig {
  final String portId;
  final PortPosition portPosition;
  final PortType? portType;
  final String? label;
  PortConfig({
    required this.portId,
    this.label,
    this.portPosition = PortPosition.left,
    this.portType = PortType.input,
  });
}
