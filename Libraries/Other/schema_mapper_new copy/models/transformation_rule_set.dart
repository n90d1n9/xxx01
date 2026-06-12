import 'package:flutter/foundation.dart';

import 'transformation_rule.dart';

class TransformationRuleSet {
  final List<TransformationRule> rules;
  final String? name;
  final String? description;

  TransformationRuleSet({required this.rules, this.name, this.description});

  TransformationRuleSet copyWith({
    List<TransformationRule>? rules,
    String? name,
    String? description,
  }) {
    return TransformationRuleSet(
      rules: rules ?? this.rules,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rules': rules.map((e) => e.toJson()).toList(),
      'name': name,
      'description': description,
    };
  }

  factory TransformationRuleSet.fromJson(Map<String, dynamic> json) {
    return TransformationRuleSet(
      rules:
          (json['rules'] as List)
              .map(
                (e) => TransformationRule.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  String toString() {
    return 'TransformationRuleSet(rules: $rules, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformationRuleSet &&
        listEquals(other.rules, rules) &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return rules.hashCode ^ name.hashCode ^ description.hashCode;
  }
}
