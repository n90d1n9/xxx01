import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_edge.dart';
import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/state_node.dart';
import 'base_parser.dart';

class StateDiagramParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('state');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final states = <StateNode>[];
    final edges = <DiagramEdge>[];
    final stateMap = <String, StateNode>{};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      _parseLine(line, states, edges, stateMap);
    }

    _layoutStateNodes(states, edges);
    return MermaidDiagram(
      type: DiagramType.stateDiagram,
      states: states,
      edges: edges,
      rawCode: code,
    );
  }

  void _parseLine(
    String line,
    List<StateNode> states,
    List<DiagramEdge> edges,
    Map<String, StateNode> stateMap,
  ) {
    // State definitions
    if (_parseStateDefinition(line, states, stateMap)) return;

    // State transitions
    if (_parseTransition(line, edges, states, stateMap)) return;

    // State descriptions
    _parseStateDescription(line, states);
  }

  bool _parseStateDefinition(
    String line,
    List<StateNode> states,
    Map<String, StateNode> stateMap,
  ) {
    final stateMatch = RegExp(r'state\s+"?([^"\s]+)"?\s*\{?').firstMatch(line);
    if (stateMatch != null) {
      final stateName = stateMatch.group(1)!;
      if (!stateMap.containsKey(stateName)) {
        final isInitial = stateName == '[*]';
        final isFinal = stateName == '[*]';

        final state = StateNode(
          id: stateName,
          label: isInitial || isFinal ? '' : stateName,
          isInitial: isInitial,
          isFinal: isFinal,
        );
        states.add(state);
        stateMap[stateName] = state;
      }
      return true;
    }
    return false;
  }

  bool _parseTransition(
    String line,
    List<DiagramEdge> edges,
    List<StateNode> states,
    Map<String, StateNode> stateMap,
  ) {
    final transMatch = RegExp(
      r'(\w+|\[\*\])\s*-->\s*(\w+|\[\*\])(?:\s*:\s*([^:]+))?',
    ).firstMatch(line);

    if (transMatch != null) {
      final from = transMatch.group(1)!;
      final to = transMatch.group(2)!;
      final label = transMatch.group(3)?.trim();

      edges.add(DiagramEdge(from: from, to: to, label: label));

      // Create state nodes if they don't exist
      _ensureStateExists(from, states, stateMap);
      _ensureStateExists(to, states, stateMap);
      return true;
    }
    return false;
  }

  void _parseStateDescription(String line, List<StateNode> states) {
    final descMatch = RegExp(r':\s*([^:]+)\s*:').firstMatch(line);
    if (descMatch != null && states.isNotEmpty) {
      final lastState = states.last;
      states[states.length - 1] = lastState.copyWith(
        description: descMatch.group(1),
      );
    }
  }

  void _ensureStateExists(
    String stateId,
    List<StateNode> states,
    Map<String, StateNode> stateMap,
  ) {
    if (!stateMap.containsKey(stateId) && stateId != '[*]') {
      final state = StateNode(id: stateId, label: stateId);
      states.add(state);
      stateMap[stateId] = state;
    }
  }

  void _layoutStateNodes(List<StateNode> states, List<DiagramEdge> edges) {
    if (states.isEmpty) return;

    final levels = <String, int>{};
    final visited = <String>{};

    void assignLevel(String stateId, int level) {
      if (visited.contains(stateId)) return;
      visited.add(stateId);
      levels[stateId] = math.max(levels[stateId] ?? 0, level);

      for (final edge in edges.where((e) => e.from == stateId)) {
        assignLevel(edge.to, level + 1);
      }
    }

    // Find initial states
    final initialStates =
        states.where((s) => s.isInitial).map((s) => s.id).toList();
    if (initialStates.isNotEmpty) {
      for (final initial in initialStates) {
        assignLevel(initial, 0);
      }
    } else {
      // Find states with no incoming edges
      final hasIncoming = edges.map((e) => e.to).toSet();
      final roots =
          states
              .where((s) => !hasIncoming.contains(s.id))
              .map((s) => s.id)
              .toList();
      for (final root in roots) {
        assignLevel(root, 0);
      }
    }

    final byLevel = <int, List<StateNode>>{};
    for (final state in states) {
      final level = levels[state.id] ?? 0;
      byLevel.putIfAbsent(level, () => []).add(state);
    }

    for (final entry in byLevel.entries) {
      final level = entry.key;
      final levelStates = entry.value;
      final levelWidth = levelStates.length * 250.0;
      final startX = (800 - levelWidth) / 2;

      for (var i = 0; i < levelStates.length; i++) {
        final state = levelStates[i];
        final index = states.indexWhere((s) => s.id == state.id);
        if (index != -1) {
          states[index] = state.copyWith(
            position: Offset(startX + i * 250.0, level * 150.0 + 50),
          );
        }
      }
    }
  }
}
