class FilterConfig {
  final String expression;
  final String? language;
  final String? action;

  FilterConfig({
    required this.expression,
    this.language = 'javascript',
    this.action = 'discard',
  });

  factory FilterConfig.fromJson(Map<String, dynamic> json) {
    return FilterConfig(
      expression: json['expression'] as String,
      language: json['language'] as String?,
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      if (language != null) 'language': language,
      if (action != null) 'action': action,
    };
  }
}
