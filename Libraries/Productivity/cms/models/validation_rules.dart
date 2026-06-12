/// Validation rules for fields
class ValidationRules {
  final int? minLength;
  final int? maxLength;
  final num? min;
  final num? max;
  final String? pattern;
  final String? customValidator;
  final String? errorMessage;
  final List<String>? allowedValues;

  const ValidationRules({
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.pattern,
    this.customValidator,
    this.errorMessage,
    this.allowedValues,
  });

  Map<String, dynamic> toJson() => {
    'minLength': minLength,
    'maxLength': maxLength,
    'min': min,
    'max': max,
    'pattern': pattern,
    'customValidator': customValidator,
    'errorMessage': errorMessage,
    'allowedValues': allowedValues,
  };

  factory ValidationRules.fromJson(Map<String, dynamic> json) =>
      ValidationRules(
        minLength: json['minLength'],
        maxLength: json['maxLength'],
        min: json['min'],
        max: json['max'],
        pattern: json['pattern'],
        customValidator: json['customValidator'],
        errorMessage: json['errorMessage'],
        allowedValues: json['allowedValues']?.cast<String>(),
      );
}
