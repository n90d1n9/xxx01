import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/id_generator.dart';

enum MenuPosition { node, sidebar, header, account }

enum Roles { guest, authenticated, user, member, manager, unknown }

enum ScreenType { branch, singlePage }

class FeatureRoutes {
  final int id;
  final String? name;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? icon;
  final Widget? iconWidget;
  final String? path;
  final String? basePath;
  final List<FeatureRoutes> items;
  final bool? enabled;
  final Widget? child;
  final bool isActive;
  final bool isEnable;
  final List<Roles> roles;
  final List<MenuPosition> position;
  final ScreenType screenType;
  final int sequence;
  final Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder;
  final Widget Function(BuildContext, GoRouterState)? builder;
  final String? initialLocation;
  final String? pathBuilder;

  FeatureRoutes({
    int? id,
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
    this.pageBuilder,
    this.builder,
    this.screenType = ScreenType.branch,
    this.initialLocation,
    this.pathBuilder,
  }) : id = id ?? SnowflakeIdGenerator(0).next();
  FeatureRoutes copyWith({
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
    List<FeatureRoutes>? items,
    String? initialLocation,
    String? pathBuilder,
  }) {
    return FeatureRoutes(
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
      initialLocation: initialLocation ?? this.initialLocation,
      pathBuilder: pathBuilder ?? this.pathBuilder,
    );
  }

  factory FeatureRoutes.fromJson(Map<String, dynamic> json) => FeatureRoutes(
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
            ?.map((e) => FeatureRoutes.fromJson(e as Map<String, dynamic>))
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
  String toString() => 'title: $title, name: $name, path: $path, items: $items';
}
