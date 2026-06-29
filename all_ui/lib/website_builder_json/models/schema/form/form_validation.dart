class FormValidation {
  final String mode; // onChange, onBlur, onSubmit
  final bool showErrorsOnSubmit;
  final Map<String, dynamic>? customValidation;

  FormValidation({
    required this.mode,
    this.showErrorsOnSubmit = true,
    this.customValidation,
  });

  factory FormValidation.fromJson(Map<String, dynamic> json) {
    return FormValidation(
      mode: json['mode'] as String,
      showErrorsOnSubmit: json['showErrorsOnSubmit'] as bool? ?? true,
      customValidation: json['customValidation'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'showErrorsOnSubmit': showErrorsOnSubmit,
    if (customValidation != null) 'customValidation': customValidation,
  };
}
