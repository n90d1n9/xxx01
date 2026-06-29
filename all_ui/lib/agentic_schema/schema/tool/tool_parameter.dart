class ToolParameter {
  final String name;
  final String type;
  final bool? required;
  final String? description;
  final dynamic defaultValue;

  ToolParameter({
    required this.name,
    required this.type,
    this.required = false,
    this.description,
    this.defaultValue,
  });

  factory ToolParameter.fromJson(Map<String, dynamic> json) {
    return ToolParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      required: json['required'] as bool?,
      description: json['description'] as String?,
      defaultValue: json['defaultValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (required != null) 'required': required,
      if (description != null) 'description': description,
      if (defaultValue != null) 'defaultValue': defaultValue,
    };
  }
}
