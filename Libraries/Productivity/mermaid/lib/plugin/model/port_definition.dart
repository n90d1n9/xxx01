class PortDefinition {
  final String id;
  final String name;
  final String description;
  final String dataType;
  final bool required;
  final dynamic defaultValue;
  final Map<String, dynamic>? validation;

  PortDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.dataType,
    this.required = true,
    this.defaultValue,
    this.validation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'dataType': dataType,
    'required': required,
    'defaultValue': defaultValue,
    'validation': validation,
  };

  factory PortDefinition.fromJson(Map<String, dynamic> json) => PortDefinition(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    dataType: json['dataType'] as String,
    required: json['required'] as bool? ?? true,
    defaultValue: json['defaultValue'],
    validation: json['validation'] as Map<String, dynamic>?,
  );
}
