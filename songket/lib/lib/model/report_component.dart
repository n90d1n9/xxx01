import 'dart:ui';

enum ComponentType {
  text,
  table,
  chart,
  image,
  divider,
  spacer,
  container,
  header,
  footer,
  pageBreak,
  qrCode,
  barcode,
  signature,
  richText,
  formula,
  metric,
  gauge,
  progress,
  timeline,
  calendar,
  map,
  custom,
}

/// Draggable report component
class ReportComponent {
  final String id;
  final ComponentType type;
  final String name;
  final Offset position;
  final Size size;
  final int zIndex;
  final bool locked;
  final bool visible;
  final double rotation;
  final double opacity;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> styling;
  final String? dataBinding; // Bind to data source
  final List<ComponentConstraint> constraints;

  ReportComponent({
    required this.id,
    required this.type,
    required this.name,
    this.position = Offset.zero,
    this.size = const Size(200, 100),
    this.zIndex = 0,
    this.locked = false,
    this.visible = true,
    this.rotation = 0,
    this.opacity = 1.0,
    this.properties = const {},
    this.styling = const {},
    this.dataBinding,
    this.constraints = const [],
  });

  ReportComponent copyWith({
    Offset? position,
    Size? size,
    int? zIndex,
    bool? locked,
    bool? visible,
    Map<String, dynamic>? properties,
  }) {
    return ReportComponent(
      id: id,
      type: type,
      name: name,
      position: position ?? this.position,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
      locked: locked ?? this.locked,
      visible: visible ?? this.visible,
      rotation: rotation,
      opacity: opacity,
      properties: properties ?? this.properties,
      styling: styling,
      dataBinding: dataBinding,
      constraints: constraints,
    );
  }
}

/// Component positioning constraints
enum ComponentConstraint {
  topAlign,
  bottomAlign,
  leftAlign,
  rightAlign,
  centerHorizontal,
  centerVertical,
  matchParentWidth,
  matchParentHeight,
  aspectRatio,
}
