import 'dart:convert';

import 'package:wayang_ui_core/wayang_ui_core.dart';
import 'package:yaml/yaml.dart';

import '../features/workflow/components/node/model/schema/node_template.dart';
import '../features/workflow/model/workflow_node.dart';

class WayangState {
  final WayangCore wayangConfig;
  final List<WorkflowNode> nodes;
  final List<NodeTemplate> templates;

  WayangState({
    WayangCore? wayangConfig,
    this.nodes = const [],
    this.templates = const [],
  }) : wayangConfig = wayangConfig ?? WayangCore(name: '', version: '1.0');

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'wayangConfig': wayangConfig.toMap(),
      'nodes': nodes.map((node) => node.toMap()).toList(),
      'templates': templates.map((template) => template.toMap()).toList(),
    };
  }

  // Convert to JSON
  String toJson() {
    return jsonEncode(toMap());
  }

  // Convert to YAML
  String toYaml() {
    final yamlMap = toMap();
    final yamlString = YamlMap.wrap(yamlMap).toString();
    return yamlString;
  }

  // Convert to String (for debugging)
  @override
  String toString() {
    return 'WayangState(wayangConfig: $wayangConfig, nodes: $nodes, templates: $templates)';
  }

  // Factory method to create an instance from a Map
  factory WayangState.fromMap(Map<String, dynamic> map) {
    return WayangState(
      wayangConfig: WayangCore.fromMap(map['wayangConfig']),
      nodes: List<WorkflowNode>.from(
        map['nodes'].map((x) => WorkflowNode.fromMap(x)),
      ),
      templates: List<NodeTemplate>.from(
        map['templates'].map((x) => NodeTemplate.fromMap(x)),
      ),
    );
  }

  // Factory method to create an instance from JSON
  factory WayangState.fromJson(String json) {
    return WayangState.fromMap(jsonDecode(json));
  }

  // Factory method to create an instance from YAML
  factory WayangState.fromYaml(String yaml) {
    final map = loadYaml(yaml) as Map<String, dynamic>;
    return WayangState.fromMap(map);
  }
}
