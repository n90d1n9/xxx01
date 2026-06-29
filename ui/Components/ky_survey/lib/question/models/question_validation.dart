class QuestionValidation {
  final String? regex;
  final num? minValue;
  final num? maxValue;
  final int? minLength;
  final int? maxLength;
  final List<String>? allowedFileTypes;
  final int? maxFileSize;
  final String? customValidation;
  final String? errorMessage;

  

  QuestionValidation({
    this.regex,
    this.minValue,
    this.maxValue,
    this.minLength,
    this.maxLength,
    this.allowedFileTypes,
    this.maxFileSize,
    this.customValidation,
    this.errorMessage,
  });

  factory QuestionValidation.fromJson(Map<String, dynamic> json) {
    return QuestionValidation(
      regex: json['regex'] as String?,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      allowedFileTypes: (json['allowedFileTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxFileSize: json['maxFileSize'] as int?,
      customValidation: json['customValidation'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regex': regex,
      'minValue': minValue,
      'maxValue': maxValue,
      'minLength': minLength,
      'maxLength': maxLength,
      'allowedFileTypes': allowedFileTypes,
      'maxFileSize': maxFileSize,
      'customValidation': customValidation,
      'errorMessage': errorMessage,
    };
  }
}
