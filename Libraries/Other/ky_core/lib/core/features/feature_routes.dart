import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Declares where a feature route should appear in the application chrome.
enum MenuPosition { node, sidebar, header, account }

/// Describes whether a route is a branch container or a directly rendered page.
enum ScreenType { branch, singlePage }

int _nextFeatureRouteId = 0;

/// Metadata and rendering hooks for a screen registered by a Kaysir feature.
class FeatureRoutes {
  FeatureRoutes({
    int? id,
    this.title,
    this.name,
    this.subtitle,
    this.description,
    this.icon,
    this.iconWidget,
    this.path,
    this.allowedRoles = const [''],
    this.redirectToIfDenied,
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
  }) : id = id ?? _nextFeatureRouteId++;

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
  final List<String?> allowedRoles;
  final String? redirectToIfDenied;
  final List<MenuPosition> position;
  final ScreenType screenType;
  final int sequence;
  final Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder;
  final Widget Function(BuildContext, GoRouterState)? builder;
  final String? initialLocation;
  final String? pathBuilder;

  FeatureRoutes copyWith({
    int? id,
    String? title,
    String? name,
    String? subtitle,
    String? description,
    String? icon,
    Widget? iconWidget,
    String? path,
    List<String?>? allowedRoles,
    String? redirectToIfDenied,
    String? basePath,
    List<FeatureRoutes>? items,
    bool? enabled,
    Widget? child,
    bool? isActive,
    bool? isEnable,
    List<MenuPosition>? position,
    ScreenType? screenType,
    int? sequence,
    Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder,
    Widget Function(BuildContext, GoRouterState)? builder,
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
      allowedRoles: allowedRoles ?? this.allowedRoles,
      redirectToIfDenied: redirectToIfDenied ?? this.redirectToIfDenied,
      basePath: basePath ?? this.basePath,
      enabled: enabled ?? this.enabled,
      child: child ?? this.child,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
      isEnable: isEnable ?? this.isEnable,
      position: position ?? this.position,
      screenType: screenType ?? this.screenType,
      sequence: sequence ?? this.sequence,
      pageBuilder: pageBuilder ?? this.pageBuilder,
      builder: builder ?? this.builder,
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
    allowedRoles:
        (json['allowedRoles'] as List<dynamic>?)
            ?.map((role) => role as String?)
            .toList() ??
        const [''],
    redirectToIfDenied: json['redirectToIfDenied'] as String?,
    basePath: json['basePath'] as String?,
    enabled: json['enabled'] as bool?,
    items:
        (json['items'] as List<dynamic>?)
            ?.map(
              (item) => FeatureRoutes.fromJson(item as Map<String, dynamic>),
            )
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
    'items': items.map((item) => item.toJson()).toList(),
    'allowedRoles': allowedRoles,
    'redirectToIfDenied': redirectToIfDenied,
    'enabled': enabled,
  };

  @override
  String toString() {
    return 'FeatureRoutes(title: $title, name: $name, path: $path, items: $items)';
  }
}
