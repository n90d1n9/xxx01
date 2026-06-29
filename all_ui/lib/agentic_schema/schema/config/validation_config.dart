class ValidationConfig {
  final Map<String, dynamic>? schema;
  final String? onFailure;
  final dynamic fallbackValue;

  ValidationConfig({this.schema, this.onFailure = 'throw', this.fallbackValue});

  factory ValidationConfig.fromJson(Map<String, dynamic> json) {
    return ValidationConfig(
      schema: json['schema'] != null
          ? Map<String, dynamic>.from(json['schema'] as Map)
          : null,
      onFailure: json['onFailure'] as String?,
      fallbackValue: json['fallbackValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (schema != null) 'schema': schema,
      if (onFailure != null) 'onFailure': onFailure,
      if (fallbackValue != null) 'fallbackValue': fallbackValue,
    };
  }
}
