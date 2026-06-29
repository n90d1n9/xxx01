import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../schema/common/ai_agen_builder_model.dart';
import '../schema/workflow/workflow.dart';
import '../schema/workflow/workflow_edge.dart';
import '../schema/workflow/workflow_node.dart';

class ExportImportService {
  // Export workflow to JSON
  Future<String> exportWorkflowToJson(Workflow workflow) async {
    final data = workflow.toJson();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // Export entire project
  Future<String> exportProjectToJson(AIAgentBuilderModel model) async {
    final data = model.toJson();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // Import workflow from JSON
  Workflow importWorkflowFromJson(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return Workflow.fromJson(data);
  }

  // Import project from JSON
  AIAgentBuilderModel importProjectFromJson(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return AIAgentBuilderModel.fromJson(data);
  }

  // Export to file
  Future<void> exportToFile(String content, String filename) async {
    final file = File(filename);
    await file.writeAsString(content);
  }

  // Import from file
  Future<String> importFromFile(String filename) async {
    final file = File(filename);
    return await file.readAsString();
  }

  // Export as PNG image
  Future<void> exportAsPng(
    List<WorkflowNode> nodes,
    List<WorkflowEdge> edges,
    String filename,
  ) async {
    // Implementation would use Flutter's rendering to capture canvas
    // This is a placeholder
  }

  // Export as SVG
  Future<String> exportAsSvg(
    List<WorkflowNode> nodes,
    List<WorkflowEdge> edges,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 800">',
    );

    // Draw nodes
    for (final node in nodes) {
      buffer.writeln(
        '  <rect x="${node.position.x}" y="${node.position.y}" '
        'width="200" height="100" fill="${_colorToHex(node.type.color)}" '
        'stroke="#333" stroke-width="2" rx="8"/>',
      );
      buffer.writeln(
        '  <text x="${node.position.x + 100}" y="${node.position.y + 50}" '
        'text-anchor="middle" fill="white">${node.name}</text>',
      );
    }

    // Draw edges
    for (final edge in edges) {
      final source = nodes.firstWhere((n) => n.id == edge.source);
      final target = nodes.firstWhere((n) => n.id == edge.target);
      buffer.writeln(
        '  <line x1="${source.position.x + 100}" y1="${source.position.y + 100}" '
        'x2="${target.position.x + 100}" y2="${target.position.y}" '
        'stroke="#666" stroke-width="2" marker-end="url(#arrowhead)"/>',
      );
    }

    buffer.writeln('  <defs>');
    buffer.writeln(
      '    <marker id="arrowhead" markerWidth="10" markerHeight="10" '
      'refX="9" refY="3" orient="auto">',
    );
    buffer.writeln('      <polygon points="0 0, 10 3, 0 6" fill="#666"/>');
    buffer.writeln('    </marker>');
    buffer.writeln('  </defs>');
    buffer.writeln('</svg>');

    return buffer.toString();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8)}';
  }
}
