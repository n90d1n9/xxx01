import 'mapping_rule.dart';

/// Represents a transformation step in the integration flow
class TransformationStep {
  final String id;
  final String name;
  final TransformationType type;
  final Map<String, dynamic> config;
  final String? script;
  final List<MappingRule>? mappingRules;

  const TransformationStep({
    required this.id,
    required this.name,
    required this.type,
    required this.config,
    this.script,
    this.mappingRules,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'config': config,
    'script': script,
    'mappingRules': mappingRules?.map((r) => r.toJson()).toList(),
  };
}

enum TransformationType {
  dataMapper,
  jsonTransform,
  xmlTransform,
  script,
  template,
  enricher,
  splitter,
  aggregator,
  filter,
  validator,
}
