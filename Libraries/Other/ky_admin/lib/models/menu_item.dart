import 'package:flutter/material.dart';


class MenuItem {
  final String id;
  final String title;
  final IconData? icon;
  final String? route;
  final Widget? widget;
  final Widget? widgetOnSelected;
  final Color color;
  final List<MenuItem> children;
  final bool isExpanded;
  final String category;

  const MenuItem({
    required this.id,
    required this.title,
    this.icon,
    this.widget,
    this.color = Colors.blueAccent,
    this.route,
    this.children = const [],
    this.isExpanded = false,
    this.widgetOnSelected,
    this.category = 'Tsaqofah',
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: _getIconFromString(json['icon']),
      route: json['route'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => MenuItem.fromJson(child))
              .toList()
          : const [],
    );
  }

  static IconData? _getIconFromString(String? iconName) {
    if (iconName == null) return null;

    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'list':
        return Icons.list;
      case 'home':
        return Icons.home;
      default:
        return Icons.list;
    }
  }

  MenuItem copyWith({
    String? id,
    String? title,
    IconData? icon,
    String? route,
    List<MenuItem>? children,
    bool? isExpanded,
  }) {
    return MenuItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
