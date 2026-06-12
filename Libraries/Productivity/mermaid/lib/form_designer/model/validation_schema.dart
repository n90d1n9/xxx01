import '../../spreadsheet/model/cell/cell_validation.dart';

class ValidationSchema {
  final List<ValidationRule> rules;
  final String? customValidatorCode;
  final Map<String, dynamic>? asyncValidation;

  const ValidationSchema({
    required this.rules,
    this.customValidatorCode,
    this.asyncValidation,
  });

  Map<String, dynamic> toJson() {
    return {
      'rules': rules.map((r) => r.toJson()).toList(),
      if (customValidatorCode != null) 'customValidator': customValidatorCode,
      if (asyncValidation != null) 'asyncValidation': asyncValidation,
    };
  }
}

class ValidationRule {
  final ValidationType type;
  final dynamic value;
  final String? message;
  final bool async;

  const ValidationRule({
    required this.type,
    this.value,
    this.message,
    this.async = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'value': value,
      'message': message,
      'async': async,
    };
  }
}
