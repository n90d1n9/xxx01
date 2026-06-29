class CustomResourceDefinitionVersion {
  final String name;
  final bool served;
  final bool storage;
  final bool? deprecated;
  final String? deprecationWarning;
  final Map<String, dynamic>? schema;
  final Map<String, dynamic>? subresources;
  final List<Map<String, dynamic>>? additionalPrinterColumns;
  CustomResourceDefinitionVersion({
    required this.name,
    required this.served,
    required this.storage,
    this.deprecated,
    this.deprecationWarning,
    this.schema,
    this.subresources,
    this.additionalPrinterColumns,
  });
  factory CustomResourceDefinitionVersion.fromJson(Map<String, dynamic> json) {
    return CustomResourceDefinitionVersion(
      name: json['name'],
      served: json['served'],
      storage: json['storage'],
      deprecated: json['deprecated'],
      deprecationWarning: json['deprecationWarning'],
      schema: json['schema'],
      subresources: json['subresources'],
      additionalPrinterColumns:
          json['additionalPrinterColumns'] != null
              ? List<Map<String, dynamic>>.from(
                json['additionalPrinterColumns'],
              )
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'served': served,
      'storage': storage,
      if (deprecated != null) 'deprecated': deprecated,
      if (deprecationWarning != null) 'deprecationWarning': deprecationWarning,
      if (schema != null) 'schema': schema,
      if (subresources != null) 'subresources': subresources,
      if (additionalPrinterColumns != null)
        'additionalPrinterColumns': additionalPrinterColumns,
    };
  }
}
