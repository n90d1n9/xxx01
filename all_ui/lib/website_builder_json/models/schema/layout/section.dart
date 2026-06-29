import '../component.dart';
import '../condition.dart';
import '../styles/styles.dart';
import 'layout.dart';
import 'responsive.dart';

/// Section represents a major layout division (like header, hero, footer)
class Section {
  final String id;
  final String type; // header, hero, content, footer, custom
  final String? name;
  final Layout layout;
  final List<Component> components;
  final Styles? styles;
  final Responsive? responsive;
  final Map<String, dynamic>? data;
  final List<Condition>? conditions; // Conditional rendering

  Section({
    required this.id,
    required this.type,
    this.name,
    required this.layout,
    required this.components,
    this.styles,
    this.responsive,
    this.data,
    this.conditions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String?,
      layout: Layout.fromJson(json['layout'] as Map<String, dynamic>),
      components:
          (json['components'] as List)
              .map((c) => Component.fromJson(c as Map<String, dynamic>))
              .toList(),
      styles:
          json['styles'] != null
              ? Styles.fromJson(json['styles'] as Map<String, dynamic>)
              : null,
      responsive:
          json['responsive'] != null
              ? Responsive.fromJson(json['responsive'] as Map<String, dynamic>)
              : null,
      data: json['data'] as Map<String, dynamic>?,
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((c) => Condition.fromJson(c as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (name != null) 'name': name,
    'layout': layout.toJson(),
    'components': components.map((c) => c.toJson()).toList(),
    if (styles != null) 'styles': styles!.toJson(),
    if (responsive != null) 'responsive': responsive!.toJson(),
    if (data != null) 'data': data,
    if (conditions != null)
      'conditions': conditions!.map((c) => c.toJson()).toList(),
  };
}
