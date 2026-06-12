import 'dart:ui';

import 'builder_canvas_config.dart';
import 'builder_component_constraints.dart';

class BuilderResponsiveOverride {
  final Offset? position;
  final Size? size;
  final bool? isVisible;

  const BuilderResponsiveOverride({this.position, this.size, this.isVisible});

  Map<String, dynamic> toJson() {
    return {
      'x': position?.dx,
      'y': position?.dy,
      'width': size?.width,
      'height': size?.height,
      'isVisible': isVisible,
    };
  }

  factory BuilderResponsiveOverride.fromJson(Map<String, dynamic> json) {
    final x = (json['x'] as num?)?.toDouble();
    final y = (json['y'] as num?)?.toDouble();
    final width = (json['width'] as num?)?.toDouble();
    final height = (json['height'] as num?)?.toDouble();
    return BuilderResponsiveOverride(
      position: x == null || y == null ? null : Offset(x, y),
      size: width == null || height == null ? null : Size(width, height),
      isVisible: json['isVisible'] as bool?,
    );
  }
}

class BuilderComponentGeometry {
  final String id;
  final String kindKey;
  final Offset position;
  final Size size;
  final BuilderComponentConstraints constraints;
  final Map<String, String> properties;
  final Map<String, BuilderResponsiveOverride> responsiveOverrides;
  final int zIndex;
  final bool isLocked;
  final bool isVisible;

  const BuilderComponentGeometry({
    required this.id,
    required this.kindKey,
    required this.position,
    required this.size,
    this.constraints = const BuilderComponentConstraints(),
    this.properties = const {},
    this.responsiveOverrides = const {},
    this.zIndex = 0,
    this.isLocked = false,
    this.isVisible = true,
  });

  Rect get rect => position & size;

  BuilderComponentGeometry copyWith({
    String? id,
    String? kindKey,
    Offset? position,
    Size? size,
    BuilderComponentConstraints? constraints,
    Map<String, String>? properties,
    Map<String, BuilderResponsiveOverride>? responsiveOverrides,
    int? zIndex,
    bool? isLocked,
    bool? isVisible,
  }) {
    return BuilderComponentGeometry(
      id: id ?? this.id,
      kindKey: kindKey ?? this.kindKey,
      position: position ?? this.position,
      size: size ?? this.size,
      constraints: constraints ?? this.constraints,
      properties: properties ?? this.properties,
      responsiveOverrides: responsiveOverrides ?? this.responsiveOverrides,
      zIndex: zIndex ?? this.zIndex,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  BuilderComponentGeometry snapped(BuilderCanvasConfig config) {
    return copyWith(
      position: config.snapOffset(position),
      size: config.snapSize(size),
    );
  }

  BuilderComponentGeometry duplicate({
    required String id,
    Offset offset = const Offset(24, 24),
  }) {
    return copyWith(id: id, position: position + offset, isLocked: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kindKey': kindKey,
      'x': position.dx,
      'y': position.dy,
      'width': size.width,
      'height': size.height,
      'constraints': constraints.toJson(),
      'properties': properties,
      'responsiveOverrides': responsiveOverrides.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'zIndex': zIndex,
      'isLocked': isLocked,
      'isVisible': isVisible,
    };
  }

  factory BuilderComponentGeometry.fromJson(Map<String, dynamic> json) {
    return BuilderComponentGeometry(
      id: json['id'] as String,
      kindKey:
          json['kindKey'] as String? ?? json['type'] as String? ?? 'unknown',
      position: Offset(
        (json['x'] as num?)?.toDouble() ?? 0,
        (json['y'] as num?)?.toDouble() ?? 0,
      ),
      size: Size(
        (json['width'] as num?)?.toDouble() ?? 160,
        (json['height'] as num?)?.toDouble() ?? 120,
      ),
      constraints: BuilderComponentConstraints.fromJson(
        Map<String, dynamic>.from(json['constraints'] as Map? ?? const {}),
      ),
      properties: {
        for (final entry in (json['properties'] as Map? ?? const {}).entries)
          if (entry.value != null) '${entry.key}': '${entry.value}',
      },
      responsiveOverrides: (json['responsiveOverrides'] as Map? ?? const {})
          .map(
            (key, value) => MapEntry(
              '$key',
              BuilderResponsiveOverride.fromJson(
                Map<String, dynamic>.from(value as Map? ?? const {}),
              ),
            ),
          ),
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }
}
