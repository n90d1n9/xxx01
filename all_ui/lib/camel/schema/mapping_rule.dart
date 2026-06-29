import 'package:collection/collection.dart';

/// Mapping rule for data transformation
class MappingRule {
  final String id;
  final String sourcePath;
  final String targetPath;
  final String? expression;
  final TransformFunction? function;
  final Map<String, dynamic>? functionParams;

  const MappingRule({
    required this.id,
    required this.sourcePath,
    required this.targetPath,
    this.expression,
    this.function,
    this.functionParams,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourcePath': sourcePath,
    'targetPath': targetPath,
    'expression': expression,
    'function': function?.name,
    'functionParams': functionParams,
  };

  factory MappingRule.fromJson(Map<String, dynamic> json) {
    final functionName = json['function'] as String?;

    TransformFunction? function;
    if (functionName != null) {
      // Find matching enum by name; return null if not found
      final function =
          functionName != null
              ? TransformFunction.values.firstWhereOrNull(
                (e) => e.name == functionName,
              )
              : null;
    }

    return MappingRule(
      id: json['id'] as String,
      sourcePath: json['sourcePath'] as String,
      targetPath: json['targetPath'] as String,
      expression: json['expression'] as String?,
      function: function, // this is now correctly TransformFunction?
      functionParams: json['functionParams'] as Map<String, dynamic>?,
    );
  }
}

enum TransformFunction {
  concat,
  substring,
  uppercase,
  lowercase,
  trim,
  replace,
  split,
  join,
  format,
  parse,
  custom,
}
