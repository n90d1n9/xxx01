class ConfigFieldDefinition {
  final String key;
  final String label;
  final String description;
  final String fieldType;
  final bool required;
  final dynamic defaultValue;
  final List<dynamic>? options;
  final Map<String, dynamic>? validation;

  ConfigFieldDefinition({
    required this.key,
    required this.label,
    required this.description,
    required this.fieldType,
    this.required = false,
    this.defaultValue,
    this.options,
    this.validation,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'description': description,
    'fieldType': fieldType,
    'required': required,
    'defaultValue': defaultValue,
    'options': options,
    'validation': validation,
  };

  factory ConfigFieldDefinition.fromJson(Map<String, dynamic> json) =>
      ConfigFieldDefinition(
        key: json['key'],
        label: json['label'],
        description: json['description'],
        fieldType: json['fieldType'],
        required: json['required'] ?? false,
        defaultValue: json['defaultValue'],
        options: json['options'],
        validation: json['validation'],
      );
}
