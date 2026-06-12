import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final bool isVisible;
  final bool isEditable;
  final List<String> allowedRoles;

  MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.isVisible = true,
    this.isEditable = true,
    this.allowedRoles = const ['admin', 'user'],
  });

  // JSON serialization methods
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'iconCodePoint': icon.codePoint,
    'route': route,
    'isVisible': isVisible,
    'isEditable': isEditable,
    'allowedRoles': allowedRoles,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'],
    title: json['title'],
    icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
    route: json['route'],
    isVisible: json['isVisible'] ?? true,
    isEditable: json['isEditable'] ?? true,
    allowedRoles: List<String>.from(json['allowedRoles'] ?? ['admin', 'user']),
  );
}
