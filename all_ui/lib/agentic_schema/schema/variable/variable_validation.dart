class VariableValidation {
  final bool? required;
  final num? min;
  final num? max;
  final String? pattern;
  final String? custom;

  VariableValidation({
    this.required,
    this.min,
    this.max,
    this.pattern,
    this.custom,
  });

  factory VariableValidation.fromJson(Map<String, dynamic> json) {
    return VariableValidation(
      required: json['required'] as bool?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      pattern: json['pattern'] as String?,
      custom: json['custom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (required != null) 'required': required,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (pattern != null) 'pattern': pattern,
      if (custom != null) 'custom': custom,
    };
  }
}
