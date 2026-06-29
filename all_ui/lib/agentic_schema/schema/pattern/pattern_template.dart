import '../workflow/workflow_edge.dart';
import '../workflow/workflow_node.dart';

class PatternTemplate {
  final List<WorkflowNode>? nodes;
  final List<WorkflowEdge>? edges;
  final Map<String, dynamic>? configSchema;

  PatternTemplate({this.nodes, this.edges, this.configSchema});

  factory PatternTemplate.fromJson(Map<String, dynamic> json) {
    return PatternTemplate(
      nodes: json['nodes'] != null
          ? (json['nodes'] as List)
                .map((e) => WorkflowNode.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      edges: json['edges'] != null
          ? (json['edges'] as List)
                .map((e) => WorkflowEdge.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      configSchema: json['configSchema'] != null
          ? Map<String, dynamic>.from(json['configSchema'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (nodes != null) 'nodes': nodes!.map((e) => e.toJson()).toList(),
      if (edges != null) 'edges': edges!.map((e) => e.toJson()).toList(),
      if (configSchema != null) 'configSchema': configSchema,
    };
  }
}
