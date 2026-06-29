import '../../form_designer/model/field_type.dart';

class ConfigFieldSchema {
  final String key;
  final String label;
  final String description;
  final FieldType type;
  final bool required;
  final dynamic defaultValue;
  final List<dynamic>? options;
  final Map<String, dynamic>? validation;

  ConfigFieldSchema({
    required this.key,
    required this.label,
    required this.description,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.options,
    this.validation,
  });
}
