import 'package:flutter/material.dart';

import '../models/diagram_node.dart';
import '../schema/model/diagram_connection.dart';

class ERDiagramState {
  final Map<String, DiagramNode> nodes;
  final List<DiagramConnection> connections;
  final double zoom;
  final Offset panOffset;
  const ERDiagramState({
    required this.nodes,
    required this.connections,
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
  });
  ERDiagramState copyWith({
    Map<String, DiagramNode>? nodes,
    List<DiagramConnection>? connections,
    double? zoom,
    Offset? panOffset,
  }) {
    return ERDiagramState(
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
    );
  }
}
