class ConditionConfig {
  final String expression;
  final String? language;
  final String? operator;
  final dynamic value;
  final String? logic;

  ConditionConfig({
    required this.expression,
    this.language = 'javascript',
    this.operator,
    this.value,
    this.logic,
  });

  factory ConditionConfig.fromJson(Map<String, dynamic> json) {
    return ConditionConfig(
      expression: json['expression'] as String,
      language: json['language'] as String?,
      operator: json['operator'] as String?,
      value: json['value'],
      logic: json['logic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      if (language != null) 'language': language,
      if (operator != null) 'operator': operator,
      if (value != null) 'value': value,
      if (logic != null) 'logic': logic,
    };
  }
}
