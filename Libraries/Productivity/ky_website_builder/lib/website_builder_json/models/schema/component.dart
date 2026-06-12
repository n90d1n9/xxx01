import 'animation/animation.dart';
import 'condition.dart';
import 'event/event.dart';
import 'layout/responsive.dart';
import 'styles/styles.dart';

/// Base component model
class Component {
  final String id;
  final String type; // text, image, button, container, custom
  final String? name;
  final Map<String, dynamic>? props; // Component-specific properties
  final Styles? styles;
  final List<Component>? children; // Nested components
  final List<Event>? events; // Event handlers
  final Responsive? responsive;
  final Animation? animation;
  final List<Condition>? conditions;
  final Map<String, dynamic>? data; // Data binding
  final String? dataSource; // Reference to data source

  Component({
    required this.id,
    required this.type,
    this.name,
    this.props,
    this.styles,
    this.children,
    this.events,
    this.responsive,
    this.animation,
    this.conditions,
    this.data,
    this.dataSource,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String?,
      props: json['props'] as Map<String, dynamic>?,
      styles:
          json['styles'] != null
              ? Styles.fromJson(json['styles'] as Map<String, dynamic>)
              : null,
      children:
          json['children'] != null
              ? (json['children'] as List)
                  .map((c) => Component.fromJson(c as Map<String, dynamic>))
                  .toList()
              : null,
      events:
          json['events'] != null
              ? (json['events'] as List)
                  .map((e) => Event.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      responsive:
          json['responsive'] != null
              ? Responsive.fromJson(json['responsive'] as Map<String, dynamic>)
              : null,
      animation:
          json['animation'] != null
              ? Animation.fromJson(json['animation'] as Map<String, dynamic>)
              : null,
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((c) => Condition.fromJson(c as Map<String, dynamic>))
                  .toList()
              : null,
      data: json['data'] as Map<String, dynamic>?,
      dataSource: json['dataSource'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (name != null) 'name': name,
    if (props != null) 'props': props,
    if (styles != null) 'styles': styles!.toJson(),
    if (children != null) 'children': children!.map((c) => c.toJson()).toList(),
    if (events != null) 'events': events!.map((e) => e.toJson()).toList(),
    if (responsive != null) 'responsive': responsive!.toJson(),
    if (animation != null) 'animation': animation!.toJson(),
    if (conditions != null)
      'conditions': conditions!.map((c) => c.toJson()).toList(),
    if (data != null) 'data': data,
    if (dataSource != null) 'dataSource': dataSource,
  };
}
