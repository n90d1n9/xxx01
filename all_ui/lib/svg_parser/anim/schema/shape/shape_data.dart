import 'package:flutter/material.dart';

enum ShapeType {
  rectangle,
  circle,
  ellipse,
  path;

  String toLottieType() {
    switch (this) {
      case ShapeType.rectangle:
        return 'rc';
      case ShapeType.circle:
        return 'el';
      case ShapeType.ellipse:
        return 'el';
      case ShapeType.path:
        return 'sh';
    }
  }
}

@immutable
class ShapeData {
  final ShapeType shapeType;
  final double x, y, width, height;
  final double cornerRadius;
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final String? pathData;

  const ShapeData({
    required this.shapeType,
    this.x = 0,
    this.y = 0,
    required this.width,
    required this.height,
    this.cornerRadius = 0,
    required this.fillColor,
    this.strokeColor,
    this.strokeWidth = 1,
    this.pathData,
  });

  Map<String, dynamic> toJson() => {
    'shapeType': shapeType.name,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'cornerRadius': cornerRadius,
    'fillColor': fillColor.value,
    'strokeColor': strokeColor?.value,
    'strokeWidth': strokeWidth,
    'pathData': pathData,
  };

  factory ShapeData.fromJson(Map<String, dynamic> json) {
    return ShapeData(
      shapeType: ShapeType.values.firstWhere(
        (t) => t.name == json['shapeType'],
        orElse: () => ShapeType.rectangle,
      ),
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 100).toDouble(),
      height: (json['height'] ?? 100).toDouble(),
      cornerRadius: (json['cornerRadius'] ?? 0).toDouble(),
      fillColor: Color(json['fillColor'] ?? 0xFF000000),
      strokeColor:
          json['strokeColor'] != null ? Color(json['strokeColor']) : null,
      strokeWidth: (json['strokeWidth'] ?? 1).toDouble(),
      pathData: json['pathData'],
    );
  }
}
