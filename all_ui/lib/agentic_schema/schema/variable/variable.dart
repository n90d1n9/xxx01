import 'variable_scope.dart';
import 'variable_validation.dart';

class Variable {
  final String id;
  final String name;
  final VariableType type;
  final dynamic defaultValue;
  final VariableScope? scope;
  final bool? persistent;
  final bool? encrypted;
  final VariableValidation? validation;

  Variable({
    required this.id,
    required this.name,
    required this.type,
    this.defaultValue,
    this.scope,
    this.persistent,
    this.encrypted,
    this.validation,
  });

  factory Variable.fromJson(Map<String, dynamic> json) {
    return Variable(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseVariableType(json['type']),
      defaultValue: json['defaultValue'],
      scope: json['scope'] != null ? _parseVariableScope(json['scope']) : null,
      persistent: json['persistent'] as bool?,
      encrypted: json['encrypted'] as bool?,
      validation: json['validation'] != null
          ? VariableValidation.fromJson(
              json['validation'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (scope != null) 'scope': scope!.name,
      if (persistent != null) 'persistent': persistent,
      if (encrypted != null) 'encrypted': encrypted,
      if (validation != null) 'validation': validation!.toJson(),
    };
  }

  static VariableType _parseVariableType(dynamic value) {
    if (value is VariableType) return value;
    final stringValue = value.toString();
    return VariableType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => VariableType.any,
    );
  }

  static VariableScope _parseVariableScope(dynamic value) {
    if (value is VariableScope) return value;
    final stringValue = value.toString();
    return VariableScope.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => VariableScope.local,
    );
  }
}
