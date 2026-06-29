import 'transform_operation.dart';

class FilterTransformNodeDefinition {
  final String id;
  final String name;
  final String description;
  final TransformOperation operation;
  final String? filterCondition; // CEL expression for filter
  final Map<String, String>? fieldMappings; // For map operation
  final String? aggregateField;
  final String? aggregateFunction; // sum, count, avg, min, max
  final String? groupByField;
  final String? sortField;
  final bool sortAscending;
  final Map<String, dynamic> metadata;

  FilterTransformNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.operation,
    this.filterCondition,
    this.fieldMappings,
    this.aggregateField,
    this.aggregateFunction,
    this.groupByField,
    this.sortField,
    this.sortAscending = true,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'operation': operation.name,
    'filterCondition': filterCondition,
    'fieldMappings': fieldMappings,
    'aggregateField': aggregateField,
    'aggregateFunction': aggregateFunction,
    'groupByField': groupByField,
    'sortField': sortField,
    'sortAscending': sortAscending,
    'metadata': metadata,
  };

  factory FilterTransformNodeDefinition.fromJson(Map<String, dynamic> json) =>
      FilterTransformNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        operation: TransformOperation.values.firstWhere(
          (e) => e.name == json['operation'],
          orElse: () => TransformOperation.filter,
        ),
        filterCondition: json['filterCondition'],
        fieldMappings: json['fieldMappings'] != null
            ? Map<String, String>.from(json['fieldMappings'])
            : null,
        aggregateField: json['aggregateField'],
        aggregateFunction: json['aggregateFunction'],
        groupByField: json['groupByField'],
        sortField: json['sortField'],
        sortAscending: json['sortAscending'] ?? true,
        metadata: json['metadata'] ?? {},
      );
}
