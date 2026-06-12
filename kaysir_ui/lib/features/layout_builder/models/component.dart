import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'component_properties.dart';

const Object _unsetStyleValue = Object();
const Object _unsetConstraintValue = Object();

enum ComponentAnchorMode { free, start, center, end, stretch }

extension ComponentAnchorModeX on ComponentAnchorMode {
  String get key {
    switch (this) {
      case ComponentAnchorMode.free:
        return 'free';
      case ComponentAnchorMode.start:
        return 'start';
      case ComponentAnchorMode.center:
        return 'center';
      case ComponentAnchorMode.end:
        return 'end';
      case ComponentAnchorMode.stretch:
        return 'stretch';
    }
  }

  String get label {
    switch (this) {
      case ComponentAnchorMode.free:
        return 'Free';
      case ComponentAnchorMode.start:
        return 'Start';
      case ComponentAnchorMode.center:
        return 'Center';
      case ComponentAnchorMode.end:
        return 'End';
      case ComponentAnchorMode.stretch:
        return 'Stretch';
    }
  }

  static ComponentAnchorMode fromKey(String? key) {
    return ComponentAnchorMode.values.firstWhere(
      (mode) => mode.key == key || mode.name == key,
      orElse: () => ComponentAnchorMode.free,
    );
  }
}

class ComponentConstraints {
  final ComponentAnchorMode horizontalAnchor;
  final ComponentAnchorMode verticalAnchor;
  final bool maintainAspectRatio;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;

  const ComponentConstraints({
    this.horizontalAnchor = ComponentAnchorMode.free,
    this.verticalAnchor = ComponentAnchorMode.free,
    this.maintainAspectRatio = false,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });

  bool get hasCustomRules =>
      horizontalAnchor != ComponentAnchorMode.free ||
      verticalAnchor != ComponentAnchorMode.free ||
      maintainAspectRatio ||
      minWidth != null ||
      minHeight != null ||
      maxWidth != null ||
      maxHeight != null;

  ComponentConstraints copyWith({
    ComponentAnchorMode? horizontalAnchor,
    ComponentAnchorMode? verticalAnchor,
    bool? maintainAspectRatio,
    Object? minWidth = _unsetConstraintValue,
    Object? minHeight = _unsetConstraintValue,
    Object? maxWidth = _unsetConstraintValue,
    Object? maxHeight = _unsetConstraintValue,
  }) {
    return ComponentConstraints(
      horizontalAnchor: horizontalAnchor ?? this.horizontalAnchor,
      verticalAnchor: verticalAnchor ?? this.verticalAnchor,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      minWidth:
          identical(minWidth, _unsetConstraintValue)
              ? this.minWidth
              : minWidth as double?,
      minHeight:
          identical(minHeight, _unsetConstraintValue)
              ? this.minHeight
              : minHeight as double?,
      maxWidth:
          identical(maxWidth, _unsetConstraintValue)
              ? this.maxWidth
              : maxWidth as double?,
      maxHeight:
          identical(maxHeight, _unsetConstraintValue)
              ? this.maxHeight
              : maxHeight as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horizontalAnchor': horizontalAnchor.key,
      'verticalAnchor': verticalAnchor.key,
      'maintainAspectRatio': maintainAspectRatio,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
    };
  }

  factory ComponentConstraints.fromJson(Map<String, dynamic> json) {
    return ComponentConstraints(
      horizontalAnchor: ComponentAnchorModeX.fromKey(
        json['horizontalAnchor'] as String?,
      ),
      verticalAnchor: ComponentAnchorModeX.fromKey(
        json['verticalAnchor'] as String?,
      ),
      maintainAspectRatio: json['maintainAspectRatio'] as bool? ?? false,
      minWidth: _positiveDoubleOrNull(json['minWidth']),
      minHeight: _positiveDoubleOrNull(json['minHeight']),
      maxWidth: _positiveDoubleOrNull(json['maxWidth']),
      maxHeight: _positiveDoubleOrNull(json['maxHeight']),
    );
  }

  static double? _positiveDoubleOrNull(Object? value) {
    final parsed = switch (value) {
      num() => value.toDouble(),
      String() => double.tryParse(value),
      _ => null,
    };

    if (parsed == null || parsed <= 0 || !parsed.isFinite) return null;
    return parsed;
  }
}

class ComponentResponsiveProperties {
  final Offset? position;
  final Size? size;
  final bool? isVisible;

  const ComponentResponsiveProperties({
    this.position,
    this.size,
    this.isVisible,
  });

  ComponentResponsiveProperties copyWith({
    Offset? position,
    Size? size,
    bool? isVisible,
  }) {
    return ComponentResponsiveProperties(
      position: position ?? this.position,
      size: size ?? this.size,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': position?.dx,
      'y': position?.dy,
      'width': size?.width,
      'height': size?.height,
      'isVisible': isVisible,
    };
  }

  factory ComponentResponsiveProperties.fromJson(Map<String, dynamic> json) {
    final x = (json['x'] as num?)?.toDouble();
    final y = (json['y'] as num?)?.toDouble();
    final width = (json['width'] as num?)?.toDouble();
    final height = (json['height'] as num?)?.toDouble();

    return ComponentResponsiveProperties(
      position: x == null || y == null ? null : Offset(x, y),
      size: width == null || height == null ? null : Size(width, height),
      isVisible: json['isVisible'] as bool?,
    );
  }
}

class ComponentData {
  final String id;
  final Offset position;
  final Size size;
  final ComponentStyle style;
  final ComponentProperties properties;
  final Map<String, ComponentResponsiveProperties> responsiveProperties;
  final ComponentConstraints constraints;
  final ComponentType type;
  final Rect? bounds;
  final bool isLocked;
  final bool isVisible;

  const ComponentData({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.style,
    required this.properties,
    this.responsiveProperties = const {},
    this.constraints = const ComponentConstraints(),
    this.bounds,
    this.isLocked = false,
    this.isVisible = true,
  });

  factory ComponentData.create({
    required ComponentType type,
    required Offset position,
    Size? size,
    String? id,
  }) {
    return ComponentData(
      id: id ?? const Uuid().v4(),
      type: type,
      position: position,
      size: size ?? type.defaultSize,
      properties: ComponentProperties(attributes: {'label': type.label}),
      style: const ComponentStyle(),
    );
  }

  factory ComponentData.fromTypeKey({
    required String type,
    required Offset position,
    Size? size,
  }) {
    return ComponentData.create(
      type: ComponentTypeX.fromKey(type),
      position: position,
      size: size,
    );
  }

  ComponentData copyWith({
    String? id,
    Offset? position,
    Size? size,
    ComponentStyle? style,
    ComponentProperties? properties,
    Map<String, ComponentResponsiveProperties>? responsiveProperties,
    ComponentConstraints? constraints,
    ComponentType? type,
    Rect? bounds,
    bool? isLocked,
    bool? isVisible,
  }) {
    return ComponentData(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      style: style ?? this.style,
      properties: properties ?? this.properties,
      responsiveProperties: responsiveProperties ?? this.responsiveProperties,
      constraints: constraints ?? this.constraints,
      bounds: bounds ?? this.bounds,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  ComponentData duplicate({Offset offset = const Offset(24, 24)}) {
    return copyWith(
      id: const Uuid().v4(),
      position: position + offset,
      isLocked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.key,
      'x': position.dx,
      'y': position.dy,
      'width': size.width,
      'height': size.height,
      'style': style.toJson(),
      'properties': properties.toJson(),
      'responsiveProperties': responsiveProperties.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'constraints': constraints.toJson(),
      'isLocked': isLocked,
      'isVisible': isVisible,
    };
  }

  factory ComponentData.fromJson(Map<String, dynamic> json) {
    return ComponentData(
      id: json['id'] as String? ?? const Uuid().v4(),
      type: ComponentTypeX.fromKey(json['type'] as String?),
      position: Offset(
        (json['x'] as num?)?.toDouble() ?? 0,
        (json['y'] as num?)?.toDouble() ?? 0,
      ),
      size: Size(
        (json['width'] as num?)?.toDouble() ?? 160,
        (json['height'] as num?)?.toDouble() ?? 120,
      ),
      style: ComponentStyle.fromJson(
        Map<String, dynamic>.from(json['style'] as Map? ?? const {}),
      ),
      properties: ComponentProperties.fromJson(
        Map<String, dynamic>.from(json['properties'] as Map? ?? const {}),
      ),
      responsiveProperties: (json['responsiveProperties'] as Map? ?? const {})
          .map(
            (key, value) => MapEntry(
              '$key',
              ComponentResponsiveProperties.fromJson(
                Map<String, dynamic>.from(value as Map? ?? const {}),
              ),
            ),
          ),
      constraints: ComponentConstraints.fromJson(
        Map<String, dynamic>.from(json['constraints'] as Map? ?? const {}),
      ),
      isLocked: json['isLocked'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }
}

class ComponentStyle {
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Border? border;
  final List<BoxShadow>? shadows;
  final EdgeInsets padding;
  final bool isResizable;
  final bool isDraggable;

  const ComponentStyle({
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.border,
    this.shadows,
    this.padding = const EdgeInsets.all(8),
    this.isResizable = true,
    this.isDraggable = true,
  });

  ComponentStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Object? border = _unsetStyleValue,
    List<BoxShadow>? shadows,
    EdgeInsets? padding,
    bool? isResizable,
    bool? isDraggable,
  }) {
    return ComponentStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border:
          identical(border, _unsetStyleValue) ? this.border : border as Border?,
      shadows: shadows ?? this.shadows,
      padding: padding ?? this.padding,
      isResizable: isResizable ?? this.isResizable,
      isDraggable: isDraggable ?? this.isDraggable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor.toARGB32(),
      'borderRadius': _radiusValue(borderRadius),
      'borderWidth': border?.top.width ?? 0,
      'borderColor': border?.top.color.toARGB32(),
      'padding': padding.left,
      'isResizable': isResizable,
      'isDraggable': isDraggable,
    };
  }

  factory ComponentStyle.fromJson(Map<String, dynamic> json) {
    final borderWidth = (json['borderWidth'] as num?)?.toDouble() ?? 0;
    final borderColor = json['borderColor'] as int?;
    final radius = (json['borderRadius'] as num?)?.toDouble() ?? 8;
    final padding = (json['padding'] as num?)?.toDouble() ?? 8;

    return ComponentStyle(
      backgroundColor: Color(
        json['backgroundColor'] as int? ?? Colors.white.toARGB32(),
      ),
      borderRadius: BorderRadius.circular(radius),
      border:
          borderWidth <= 0
              ? null
              : Border.all(
                width: borderWidth,
                color: Color(borderColor ?? Colors.grey.toARGB32()),
              ),
      padding: EdgeInsets.all(padding),
      isResizable: json['isResizable'] as bool? ?? true,
      isDraggable: json['isDraggable'] as bool? ?? true,
    );
  }

  static double _radiusValue(BorderRadius radius) {
    return radius.topLeft.x;
  }
}

enum ComponentType {
  buttonGrid,
  cartPanel,
  numpad,
  functionPanel,
  customButton,
  textLabel,
  imageHolder,
  separator,
}

extension ComponentTypeX on ComponentType {
  String get key {
    switch (this) {
      case ComponentType.buttonGrid:
        return 'button_grid';
      case ComponentType.cartPanel:
        return 'cart_panel';
      case ComponentType.numpad:
        return 'numpad';
      case ComponentType.functionPanel:
        return 'function_panel';
      case ComponentType.customButton:
        return 'custom_button';
      case ComponentType.textLabel:
        return 'text_label';
      case ComponentType.imageHolder:
        return 'image_holder';
      case ComponentType.separator:
        return 'separator';
    }
  }

  String get label {
    switch (this) {
      case ComponentType.buttonGrid:
        return 'Button Grid';
      case ComponentType.cartPanel:
        return 'Cart Panel';
      case ComponentType.numpad:
        return 'Numpad';
      case ComponentType.functionPanel:
        return 'Function Panel';
      case ComponentType.customButton:
        return 'Action Button';
      case ComponentType.textLabel:
        return 'Text Label';
      case ComponentType.imageHolder:
        return 'Image Holder';
      case ComponentType.separator:
        return 'Separator';
    }
  }

  IconData get icon {
    switch (this) {
      case ComponentType.buttonGrid:
        return Icons.grid_view;
      case ComponentType.cartPanel:
        return Icons.shopping_cart_outlined;
      case ComponentType.numpad:
        return Icons.pin_outlined;
      case ComponentType.functionPanel:
        return Icons.dashboard_customize_outlined;
      case ComponentType.customButton:
        return Icons.smart_button_outlined;
      case ComponentType.textLabel:
        return Icons.text_fields;
      case ComponentType.imageHolder:
        return Icons.image_outlined;
      case ComponentType.separator:
        return Icons.horizontal_rule;
    }
  }

  Size get defaultSize {
    switch (this) {
      case ComponentType.buttonGrid:
        return const Size(360, 280);
      case ComponentType.cartPanel:
        return const Size(280, 360);
      case ComponentType.numpad:
        return const Size(220, 300);
      case ComponentType.functionPanel:
        return const Size(220, 260);
      case ComponentType.customButton:
        return const Size(160, 56);
      case ComponentType.textLabel:
        return const Size(180, 48);
      case ComponentType.imageHolder:
        return const Size(220, 160);
      case ComponentType.separator:
        return const Size(240, 24);
    }
  }

  static ComponentType fromKey(String? key) {
    return ComponentType.values.firstWhere(
      (type) => type.key == key || type.name == key,
      orElse: () => ComponentType.customButton,
    );
  }
}
