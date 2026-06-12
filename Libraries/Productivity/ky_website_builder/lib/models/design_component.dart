import 'package:flutter/widgets.dart';

import 'component_animation.dart';
import 'component_style.dart';
import 'component_type.dart';
import 'responsive_layout.dart';

class DesignComponent {
  final String id;
  final ComponentType type;
  final Offset position;
  final Size size;
  final Map<String, dynamic> properties;
  final List<String> childrenIds;
  final String? parentId;
  final int zIndex;
  final ComponentAnimation animation;
  final bool locked;
  final String? groupId;
  final DateTime lastModified;
  final String? modifiedBy;
  List<DesignComponent> children;
  ResponsiveLayout? responsiveLayout;
  final String? name;
  final double rotation;
  final ComponentStyle style;
  final bool visible;

  DesignComponent({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    this.name,
    this.rotation = 0.0,
    Map<String, dynamic>? properties,
    List<DesignComponent>? children,
    ComponentAnimation? animation,
    this.responsiveLayout,
    this.childrenIds = const [],
    this.parentId,
    this.zIndex = 0,
    this.locked = false,
    ComponentStyle? style,
    this.visible = true,
    this.groupId,
    required this.lastModified,
    this.modifiedBy,
  }) : properties = properties ?? {},
       children = children ?? [],
       animation = animation ?? ComponentAnimation(),
       style = style ?? ComponentStyle();

  DesignComponent copyWith({
    String? id,
    ComponentType? type,
    Offset? position,
    Size? size,
    ComponentStyle? style,
    Map<String, dynamic>? properties,
    List<String>? childrenIds,
    String? parentId,
    int? zIndex,
    ComponentAnimation? animation,
    bool? locked,
    String? groupId,
    DateTime? lastModified,
    String? modifiedBy,
    bool? visible,
  }) {
    return DesignComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      properties: properties ?? Map.from(this.properties),
      childrenIds: childrenIds ?? List.from(this.childrenIds),
      parentId: parentId ?? this.parentId,
      zIndex: zIndex ?? this.zIndex,
      animation: animation ?? this.animation,
      style: style ?? this.style,
      rotation: rotation,
      locked: locked ?? this.locked,
      groupId: groupId ?? this.groupId,
      lastModified: lastModified ?? this.lastModified,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'position': {'dx': position.dx, 'dy': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'properties': properties,
    'childrenIds': childrenIds,
    'parentId': parentId,
    'zIndex': zIndex,
    'animation': animation.toJson(),
    'locked': locked,
    'groupId': groupId,
    'lastModified': lastModified.toIso8601String(),
    'modifiedBy': modifiedBy,
  };

  factory DesignComponent.fromJson(Map<String, dynamic> json) {
    return DesignComponent(
      id: json['id'],
      type: ComponentType.values.byName(json['type']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      properties: Map<String, dynamic>.from(json['properties']),
      childrenIds: List<String>.from(json['childrenIds'] ?? []),
      parentId: json['parentId'],
      zIndex: json['zIndex'] ?? 0,
      animation: ComponentAnimation.fromJson(json['animation'] ?? {}),
      locked: json['locked'] ?? false,
      groupId: json['groupId'],
      lastModified: DateTime.parse(
        json['lastModified'] ?? DateTime.now().toIso8601String(),
      ),
      modifiedBy: json['modifiedBy'],
    );
  }
}
