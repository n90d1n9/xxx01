import 'condition_rule.dart';

class Condition {
  final String type; // show, hide, enable, disable
  final String
  operator; // equals, notEquals, contains, greaterThan, lessThan, and, or, not
  final List<ConditionRule>? rules;
  final String? field; // For simple conditions
  final dynamic value; // For simple conditions

  Condition({
    required this.type,
    required this.operator,
    this.rules,
    this.field,
    this.value,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      type: json['type'] as String,
      operator: json['operator'] as String,
      rules:
          json['rules'] != null
              ? (json['rules'] as List)
                  .map((r) => ConditionRule.fromJson(r as Map<String, dynamic>))
                  .toList()
              : null,
      field: json['field'] as String?,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'operator': operator,
    if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
    if (field != null) 'field': field,
    if (value != null) 'value': value,
  };
}
