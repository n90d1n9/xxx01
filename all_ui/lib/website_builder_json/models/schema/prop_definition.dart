/// Property definition for custom components
class PropDefinition {
  final String name;
  final String type; // string, number, boolean, object, array
  final dynamic defaultValue;
  final bool required;
  final String? description;

  PropDefinition({
    required this.name,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.description,
  });

  factory PropDefinition.fromJson(Map<String, dynamic> json) {
    return PropDefinition(
      name: json['name'] as String,
      type: json['type'] as String,
      defaultValue: json['defaultValue'],
      required: json['required'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    if (defaultValue != null) 'defaultValue': defaultValue,
    'required': required,
    if (description != null) 'description': description,
  };
}
