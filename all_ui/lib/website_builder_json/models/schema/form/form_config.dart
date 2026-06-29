import 'form_field.dart';
import 'form_submission.dart';
import 'form_validation.dart';

class FormConfig {
  final String id;
  final String? name;
  final List<FormField> fields;
  final FormValidation? validation;
  final FormSubmission? submission;
  final Map<String, dynamic>? initialValues;

  FormConfig({
    required this.id,
    this.name,
    required this.fields,
    this.validation,
    this.submission,
    this.initialValues,
  });

  factory FormConfig.fromJson(Map<String, dynamic> json) {
    return FormConfig(
      id: json['id'] as String,
      name: json['name'] as String?,
      fields:
          (json['fields'] as List)
              .map((f) => FormField.fromJson(f as Map<String, dynamic>))
              .toList(),
      validation:
          json['validation'] != null
              ? FormValidation.fromJson(
                json['validation'] as Map<String, dynamic>,
              )
              : null,
      submission:
          json['submission'] != null
              ? FormSubmission.fromJson(
                json['submission'] as Map<String, dynamic>,
              )
              : null,
      initialValues: json['initialValues'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null) 'name': name,
    'fields': fields.map((f) => f.toJson()).toList(),
    if (validation != null) 'validation': validation!.toJson(),
    if (submission != null) 'submission': submission!.toJson(),
    if (initialValues != null) 'initialValues': initialValues,
  };
}
