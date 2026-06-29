class EdgeCondition {
  final String expression;
  final String? language;
  final int? priority;

  EdgeCondition({
    required this.expression,
    this.language = 'javascript',
    this.priority = 1,
  });

  factory EdgeCondition.fromJson(Map<String, dynamic> json) {
    return EdgeCondition(
      expression: json['expression'] as String,
      language: json['language'] as String?,
      priority: json['priority'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      if (language != null) 'language': language,
      if (priority != null) 'priority': priority,
    };
  }
}
