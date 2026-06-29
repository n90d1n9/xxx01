class CustomNodeType {
  final String type;
  final String label;
  final String? icon;
  final String? color;
  final String? category;
  final Map<String, dynamic>? configSchema;

  CustomNodeType({
    required this.type,
    required this.label,
    this.icon,
    this.color,
    this.category,
    this.configSchema,
  });

  factory CustomNodeType.fromJson(Map<String, dynamic> json) {
    return CustomNodeType(
      type: json['type'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      category: json['category'] as String?,
      configSchema: json['configSchema'] != null
          ? Map<String, dynamic>.from(json['configSchema'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (category != null) 'category': category,
      if (configSchema != null) 'configSchema': configSchema,
    };
  }
}
