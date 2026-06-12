import 'component.dart';
import 'prop_definition.dart';

/// Custom component definition for reusable components
class ComponentDefinition {
  final String id;
  final String name;
  final String? description;
  final List<PropDefinition>? props;
  final Component template;
  final Map<String, dynamic>? defaultProps;

  ComponentDefinition({
    required this.id,
    required this.name,
    this.description,
    this.props,
    required this.template,
    this.defaultProps,
  });

  factory ComponentDefinition.fromJson(Map<String, dynamic> json) {
    return ComponentDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      props:
          json['props'] != null
              ? (json['props'] as List)
                  .map(
                    (p) => PropDefinition.fromJson(p as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      template: Component.fromJson(json['template'] as Map<String, dynamic>),
      defaultProps: json['defaultProps'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (props != null) 'props': props!.map((p) => p.toJson()).toList(),
    'template': template.toJson(),
    if (defaultProps != null) 'defaultProps': defaultProps,
  };
}
