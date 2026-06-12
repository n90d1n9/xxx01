import '../condition.dart';
import 'navigation_link.dart';

class NavigationItem {
  final String id;
  final String label;
  final String? icon;
  final NavigationLink? link;
  final List<NavigationItem>? children;
  final bool active;
  final List<Condition>? conditions;

  NavigationItem({
    required this.id,
    required this.label,
    this.icon,
    this.link,
    this.children,
    this.active = false,
    this.conditions,
  });

  factory NavigationItem.fromJson(Map<String, dynamic> json) {
    return NavigationItem(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
      link:
          json['link'] != null
              ? NavigationLink.fromJson(json['link'] as Map<String, dynamic>)
              : null,
      children:
          json['children'] != null
              ? (json['children'] as List)
                  .map(
                    (c) => NavigationItem.fromJson(c as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      active: json['active'] as bool? ?? false,
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
    'label': label,
    if (icon != null) 'icon': icon,
    if (link != null) 'link': link!.toJson(),
    if (children != null) 'children': children!.map((c) => c.toJson()).toList(),
    'active': active,
    if (conditions != null)
      'conditions': conditions!.map((c) => c.toJson()).toList(),
  };
}
