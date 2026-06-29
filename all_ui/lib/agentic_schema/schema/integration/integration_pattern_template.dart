import '../camel/camel_implementation.dart';
import '../common/metadata.dart';
import '../pattern/pattern_example.dart';
import '../pattern/pattern_template.dart';

class IntegrationPatternTemplate {
  final String id;
  final String name;
  final String category;
  final String pattern;
  final String? description;
  final String? icon;
  final String? color;
  final PatternTemplate? template;
  final CamelImplementation? camelImplementation;
  final List<PatternExample>? examples;
  final Metadata? metadata;

  IntegrationPatternTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.pattern,
    this.description,
    this.icon,
    this.color,
    this.template,
    this.camelImplementation,
    this.examples,
    this.metadata,
  });

  factory IntegrationPatternTemplate.fromJson(Map<String, dynamic> json) {
    return IntegrationPatternTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      pattern: json['pattern'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      template: json['template'] != null
          ? PatternTemplate.fromJson(json['template'] as Map<String, dynamic>)
          : null,
      camelImplementation: json['camelImplementation'] != null
          ? CamelImplementation.fromJson(
              json['camelImplementation'] as Map<String, dynamic>,
            )
          : null,
      examples: json['examples'] != null
          ? (json['examples'] as List)
                .map((e) => PatternExample.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'pattern': pattern,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (template != null) 'template': template!.toJson(),
      if (camelImplementation != null)
        'camelImplementation': camelImplementation!.toJson(),
      if (examples != null)
        'examples': examples!.map((e) => e.toJson()).toList(),
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }
}
