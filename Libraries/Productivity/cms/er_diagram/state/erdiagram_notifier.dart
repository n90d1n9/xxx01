import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../content/model/content_type_schema.dart';
import '../../models/diagram_node.dart';
import '../../schema/model/diagram_connection.dart';
import '../erdiagram_state.dart';

class ERDiagramNotifier extends StateNotifier<ERDiagramState> {
  ERDiagramNotifier(List<ContentTypeSchema> schemas)
    : super(_initializeState(schemas));
  static ERDiagramState _initializeState(List<ContentTypeSchema> schemas) {
    final nodes = <String, DiagramNode>{};
    final connections = <DiagramConnection>[];
    final cols = (sqrt(schemas.length).ceil());
    for (var i = 0; i < schemas.length; i++) {
      final schema = schemas[i];
      final row = i ~/ cols;
      final col = i % cols;
      nodes[schema.id] = DiagramNode(
        schemaId: schema.id,
        position: Offset(100.0 + col * 300, 100.0 + row * 250),
      );
      for (var rel in schema.relationships) {
        connections.add(
          DiagramConnection(
            fromSchemaId: schema.id,
            toSchemaId: rel.targetSchemaId,
            relationshipId: rel.id,
            type: rel.type,
          ),
        );
      }
    }
    return ERDiagramState(nodes: nodes, connections: connections);
  }

  void updateNodePosition(String schemaId, Offset position) {
    final node = state.nodes[schemaId];
    if (node != null) {
      final updatedNodes = Map<String, DiagramNode>.from(state.nodes);
      updatedNodes[schemaId] = node.copyWith(position: position);
      state = state.copyWith(nodes: updatedNodes);
    }
  }

  void selectNode(String schemaId) {
    final updatedNodes = state.nodes.map((key, node) {
      return MapEntry(key, node.copyWith(isSelected: key == schemaId));
    });
    state = state.copyWith(nodes: updatedNodes);
  }

  void deselectAll() {
    final updatedNodes = state.nodes.map((key, node) {
      return MapEntry(key, node.copyWith(isSelected: false));
    });
    state = state.copyWith(nodes: updatedNodes);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.5, 2.0));
  }

  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  void autoLayout() {
    final schemas = state.nodes.keys.toList();
    final newNodes = Map<String, DiagramNode>.from(state.nodes);
    final center = const Offset(400, 300);
    final radius = 250.0;
    for (var i = 0; i < schemas.length; i++) {
      final angle = (2 * pi * i) / schemas.length;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      newNodes[schemas[i]] = newNodes[schemas[i]]!.copyWith(
        position: Offset(x - 100, y - 75),
      );
    }
    state = state.copyWith(nodes: newNodes);
  }
}
