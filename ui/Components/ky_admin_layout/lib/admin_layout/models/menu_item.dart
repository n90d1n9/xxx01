import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String title;
  final String? titleKey; // Localization key for title
  final IconData? icon;
  final String? route;
  final Widget? widget;
  final Widget? widgetOnSelected;
  final Color color;
  final List<MenuItem> children;
  final bool isExpanded;
  final String category;
  final String? categoryKey; // Localization key for category

  const MenuItem({
    required this.id,
    required this.title,
    this.titleKey,
    this.icon,
    this.widget,
    this.color = Colors.blueAccent,
    this.route,
    this.children = const [],
    this.isExpanded = false,
    this.widgetOnSelected,
    this.category = 'Tsaqofah',
    this.categoryKey,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleKey: json['titleKey'],
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
    String? titleKey,
    IconData? icon,
    String? route,
    List<MenuItem>? children,
    bool? isExpanded,
    String? category,
    String? categoryKey,
  }) {
    return MenuItem(
      id: id ?? this.id,
      title: title ?? this.title,
      titleKey: titleKey ?? this.titleKey,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      category: category ?? this.category,
      categoryKey: categoryKey ?? this.categoryKey,
    );
  }
}
