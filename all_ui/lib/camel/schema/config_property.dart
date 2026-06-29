class ConfigProperty {
  final String name;
  final String type;
  final bool required;
  final String? description;
  final List<String>? options;
  final dynamic defaultValue;

  const ConfigProperty({
    required this.name,
    required this.type,
    this.required = false,
    this.description,
    this.options,
    this.defaultValue,
  });
}
