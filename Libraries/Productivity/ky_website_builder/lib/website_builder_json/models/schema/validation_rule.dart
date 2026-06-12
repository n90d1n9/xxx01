class ValidationRule {
  final String
  type; // required, email, url, minLength, maxLength, pattern, custom
  final dynamic value; // Value for minLength, maxLength, pattern
  final String? message; // Custom error message

  ValidationRule({required this.type, this.value, this.message});

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      type: json['type'] as String,
      value: json['value'],
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (value != null) 'value': value,
    if (message != null) 'message': message,
  };
}
