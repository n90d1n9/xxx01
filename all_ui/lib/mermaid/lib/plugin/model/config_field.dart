enum ConfigFieldType {
  text,
  number,
  boolean,
  select,
  multiline,
  password,
  json,
}

class ConfigField {
  final String key;
  final String label;
  final ConfigFieldType type;
  final dynamic defaultValue;
  final bool required;
  final List<String>? options;
  final String? placeholder;
  final int? maxLength;
  final double? min;
  final double? max;

  ConfigField({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.options,
    this.placeholder,
    this.maxLength,
    this.min,
    this.max,
  });
}
