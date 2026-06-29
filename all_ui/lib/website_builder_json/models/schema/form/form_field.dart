import '../validation_rule.dart';
import 'form_field_option.dart';

class FormField {
  final String id;
  final String name;
  final String
  type; // text, email, number, select, checkbox, radio, textarea, date, file
  final String? label;
  final String? placeholder;
  final dynamic defaultValue;
  final bool required;
  final List<ValidationRule>? validationRules;
  final List<FormFieldOption>? options; // For select, radio, checkbox
  final Map<String, dynamic>? props;

  FormField({
    required this.id,
    required this.name,
    required this.type,
    this.label,
    this.placeholder,
    this.defaultValue,
    this.required = false,
    this.validationRules,
    this.options,
    this.props,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      label: json['label'] as String?,
      placeholder: json['placeholder'] as String?,
      defaultValue: json['defaultValue'],
      required: json['required'] as bool? ?? false,
      validationRules:
          json['validationRules'] != null
              ? (json['validationRules'] as List)
                  .map(
                    (v) => ValidationRule.fromJson(v as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      options:
          json['options'] != null
              ? (json['options'] as List)
                  .map(
                    (o) => FormFieldOption.fromJson(o as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      props: json['props'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    if (label != null) 'label': label,
    if (placeholder != null) 'placeholder': placeholder,
    if (defaultValue != null) 'defaultValue': defaultValue,
    'required': required,
    if (validationRules != null)
      'validationRules': validationRules!.map((v) => v.toJson()).toList(),
    if (options != null) 'options': options!.map((o) => o.toJson()).toList(),
    if (props != null) 'props': props,
  };
}
