class ConditionRule {
  final String field;
  final String operator;
  final dynamic value;

  ConditionRule({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory ConditionRule.fromJson(Map<String, dynamic> json) {
    return ConditionRule(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
    'field': field,
    'operator': operator,
    'value': value,
  };
}
