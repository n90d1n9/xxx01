import 'navigation/navigation_item.dart';
import 'navigation/navigation_style.dart';

class Navigation {
  final String id;
  final String type; // header, footer, sidebar, breadcrumb
  final List<NavigationItem> items;
  final NavigationStyle? style;
  final bool sticky;
  final String? position;

  Navigation({
    required this.id,
    required this.type,
    required this.items,
    this.style,
    this.sticky = false,
    this.position,
  });

  factory Navigation.fromJson(Map<String, dynamic> json) {
    return Navigation(
      id: json['id'] as String,
      type: json['type'] as String,
      items:
          (json['items'] as List)
              .map((i) => NavigationItem.fromJson(i as Map<String, dynamic>))
              .toList(),
      style:
          json['style'] != null
              ? NavigationStyle.fromJson(json['style'] as Map<String, dynamic>)
              : null,
      sticky: json['sticky'] as bool? ?? false,
      position: json['position'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'items': items.map((i) => i.toJson()).toList(),
    if (style != null) 'style': style!.toJson(),
    'sticky': sticky,
    if (position != null) 'position': position,
  };
}
