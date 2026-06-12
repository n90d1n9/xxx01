import 'package:flutter/material.dart';

import 'enums.dart';

class Menu {
  final int? id;
  final String? name;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? icon;
  final Widget? iconWidget;
  final String? path;
  final String? basePath;
  final List<Menu> items;
  final bool? enabled;
  final Widget? child;
  final bool isActive;
  final bool isEnable;
  final List<Roles> roles;
  final List<MenuPosition> position;
  final int sequence;

  const Menu({
    this.id,
    this.title,
    this.name,
    this.subtitle,
    this.description,
    this.icon,
    this.iconWidget,
    this.path,
    this.roles = const [Roles.authenticated, Roles.guest],
    this.basePath,
    this.enabled,
    this.child,
    this.items = const [],
    this.isActive = true,
    this.isEnable = true,
    this.position = const [MenuPosition.sidebar],
    this.sequence = 0,
  });
  Menu copyWith({
    int? id,
    String? title,
    String? name,
    String? subtitle,
    String? description,
    String? icon,
    Widget? iconWidget,
    String? path,
    List<String>? roles,
    String? basePath,
    List<Menu>? items,
  }) {
    return Menu(
      id: id ?? this.id,
      title: title ?? this.title,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconWidget: iconWidget ?? this.iconWidget,
      path: path ?? this.path,
      //roles: roles ?? this.roles,
      basePath: basePath ?? this.basePath,
      items: items ?? this.items,
    );
  }

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
    title: json['title'] as String?,
    name: json['name'] as String?,
    subtitle: json['subtitle'] as String?,
    description: json['description'] as String?,
    icon: json['icon'] as String?,
    path: json['path'] as String?,
    // roles: (json['roles'] as List<Roles>?)?.map((e) => e as Roles).toList(),
    basePath: json['basePath'] as String?,
    enabled: json['enabled'] as bool?,
    items:
        (json['items'] as List<dynamic>?)
            ?.map((e) => Menu.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'icon': icon,
    'path': path,
    'basePath': basePath,
    'items': items.map((e) => e.toJson()).toList(),
    'roles': roles,
    'enabled': enabled,
  };

  @override
  String toString() => 'name: $name, path: $path, items: $items';
}
