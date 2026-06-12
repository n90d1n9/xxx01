import 'package:flutter/widgets.dart';

import '../models/diagram_edge.dart';
import '../models/diagram_node.dart';
import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/node_shape.dart';
import 'base_parser.dart';

class SequenceDiagramParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    return lines[0].toLowerCase().contains('sequence');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final participants = <String, DiagramNode>{};
    final edges = <DiagramEdge>[];
    var participantIndex = 0;

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      _parseParticipant(line, participants, participantIndex);
      _parseMessage(line, participants, edges, participantIndex);
    }

    return MermaidDiagram(
      type: DiagramType.sequence,
      nodes: participants.values.toList(),
      edges: edges,
      rawCode: code,
    );
  }

  void _parseParticipant(
    String line,
    Map<String, DiagramNode> participants,
    int index,
  ) {
    final pattern = RegExp(r'(participant|actor)\s+(\w+)(?:\s+as\s+(.+))?');
    final match = pattern.firstMatch(line);
    if (match != null) {
      final id = match.group(2)!;
      final label = match.group(3) ?? id;
      final isActor = match.group(1) == 'actor';

      participants[id] = DiagramNode(
        id: id,
        label: label,
        position: Offset(index * 150.0, 0),
        shape: isActor ? NodeShape.actor : NodeShape.rectangle,
      );
    }
  }

  void _parseMessage(
    String line,
    Map<String, DiagramNode> participants,
    List<DiagramEdge> edges,
    int index,
  ) {
    final pattern = RegExp(
      r'(\w+)\s*(->>|-->>|->|-->|-x|--x)\s*(\w+)\s*:\s*(.+)',
    );
    final match = pattern.firstMatch(line);
    if (match != null) {
      final from = match.group(1)!;
      final to = match.group(3)!;
      final message = match.group(4)!;

      _ensureParticipantExists(from, participants, index);
      _ensureParticipantExists(to, participants, index + 1);

      edges.add(
        DiagramEdge(
          from: from,
          to: to,
          label: message,
          type: _getMessageType(match.group(2)!),
        ),
      );
    }
  }

  void _ensureParticipantExists(
    String id,
    Map<String, DiagramNode> participants,
    int index,
  ) {
    if (!participants.containsKey(id)) {
      participants[id] = DiagramNode(
        id: id,
        label: id,
        position: Offset(index * 150.0, 0),
      );
    }
  }

  EdgeType _getMessageType(String arrow) {
    if (arrow.contains('--')) return EdgeType.dotted;
    if (arrow.contains('x')) return EdgeType.cross;
    if (arrow.contains('>>')) return EdgeType.thick;
    return EdgeType.solid;
  }
}
