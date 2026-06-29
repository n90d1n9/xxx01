class TransformRule {
  final String sourceField;
  final String targetField;
  final String? transformType;
  final Map<String, dynamic>? transformConfig;

  TransformRule({
    required this.sourceField,
    required this.targetField,
    this.transformType,
    this.transformConfig,
  });

  Map<String, dynamic> toJson() => {
    'sourceField': sourceField,
    'targetField': targetField,
    'transformType': transformType,
    'transformConfig': transformConfig,
  };

  factory TransformRule.fromJson(Map<String, dynamic> json) => TransformRule(
    sourceField: json['sourceField'],
    targetField: json['targetField'],
    transformType: json['transformType'],
    transformConfig: json['transformConfig'],
  );
}
