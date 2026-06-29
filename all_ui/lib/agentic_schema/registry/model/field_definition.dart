import 'select_option.dart';

enum FieldType {
  string,
  number,
  boolean,
  date,
  email,
  url,
  json,
  file,
  select,
  multiSelect,
}

class FieldDefinition {
  final String id;
  final String label;
  final FieldType type;
  final bool required;
  final dynamic defaultValue;
  final String? placeholder;
  final String? description;
  final List<SelectOption>? options;
  final Map<String, dynamic>? validation;

  FieldDefinition({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.placeholder,
    this.description,
    this.options,
    this.validation,
  });
}
