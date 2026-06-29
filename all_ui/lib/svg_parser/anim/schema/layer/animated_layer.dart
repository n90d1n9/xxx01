import 'package:flutter/material.dart';

import '../../model/anim/animated_property.dart';
import '../image/image_data.dart';
import '../shape/shape_data.dart';
import '../text/text_data.dart';
import 'layer.dart';

@immutable
class AnimatedLayer {
  final String id;
  final String name;
  final LayerType type;
  final bool visible;
  final double opacity;
  final List<AnimatedProperty> properties;
  final List<AnimatedLayer> children;
  final ShapeData? shapeData;
  final ImageData? imageData;
  final TextData? textData;

  // Performance cache
  late final Map<String, AnimatedProperty> _propertyMap = {
    for (var prop in properties) prop.property: prop,
  };

  AnimatedLayer({
    required this.id,
    required this.name,
    required this.type,
    this.visible = true,
    this.opacity = 1.0,
    this.properties = const [],
    this.children = const [],
    this.shapeData,
    this.imageData,
    this.textData,
  });

  AnimatedProperty? getProperty(String name) => _propertyMap[name];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'visible': visible,
    'opacity': opacity,
    'properties': properties.map((p) => p.toJson()).toList(),
    'children': children.map((c) => c.toJson()).toList(),
    'shapeData': shapeData?.toJson(),
    'imageData': imageData?.toJson(),
    'textData': textData?.toJson(),
  };

  factory AnimatedLayer.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] ?? 'shape';
    final type = LayerType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => LayerType.shape,
    );

    return AnimatedLayer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: type,
      visible: json['visible'] ?? true,
      opacity: (json['opacity'] ?? 1.0).toDouble(),
      properties:
          (json['properties'] as List?)
              ?.map((p) => AnimatedProperty.fromJson(p))
              .toList() ??
          [],
      children:
          (json['children'] as List?)
              ?.map((c) => AnimatedLayer.fromJson(c))
              .toList() ??
          [],
      shapeData:
          json['shapeData'] != null
              ? ShapeData.fromJson(json['shapeData'])
              : null,
      imageData:
          json['imageData'] != null
              ? ImageData.fromJson(json['imageData'])
              : null,
      textData:
          json['textData'] != null ? TextData.fromJson(json['textData']) : null,
    );
  }

  Map<String, dynamic> toLottie(int index, int totalFrames) {
    final transform = _buildLottieTransform(totalFrames);

    return {
      'ddd': 0,
      'ind': index,
      'ty': type.toLottieType(),
      'nm': name,
      'sr': 1,
      'ks': transform,
      'ao': 0,
      'shapes': type == LayerType.shape ? _buildLottieShapes() : [],
      'ip': 0,
      'op': totalFrames,
      'st': 0,
      'bm': 0,
    };
  }

  Map<String, dynamic> toRive() {
    return {
      'name': name,
      'type': type.name,
      'keyframes': properties.map((p) => p.toRive()).toList(),
    };
  }

  Map<String, dynamic> _buildLottieTransform(int totalFrames) {
    final positionProp = getProperty('transform.position');
    final rotationProp = getProperty('transform.rotation');
    final scaleProp = getProperty('transform.scale');
    final opacityProp = getProperty('opacity');

    return {
      'o':
          opacityProp?.toLottieProperty(totalFrames) ??
          {'a': 0, 'k': opacity * 100},
      'r': rotationProp?.toLottieProperty(totalFrames) ?? {'a': 0, 'k': 0},
      'p':
          positionProp?.toLottieProperty(totalFrames) ??
          {
            'a': 0,
            'k': [0, 0, 0],
          },
      'a': {
        'a': 0,
        'k': [0, 0, 0],
      },
      's':
          scaleProp?.toLottieProperty(totalFrames) ??
          {
            'a': 0,
            'k': [100, 100, 100],
          },
    };
  }

  List<Map<String, dynamic>> _buildLottieShapes() {
    if (shapeData == null) return [];

    return [
      {
        'ty': shapeData!.shapeType.toLottieType(),
        'nm': name,
        's': {
          'a': 0,
          'k': [shapeData!.width, shapeData!.height],
        },
        'p': {
          'a': 0,
          'k': [shapeData!.x, shapeData!.y],
        },
        'r': {'a': 0, 'k': shapeData!.cornerRadius},
      },
      {
        'ty': 'fl',
        'c': _colorToLottie(shapeData!.fillColor),
        'o': {'a': 0, 'k': 100},
      },
      if (shapeData!.strokeColor != null)
        {
          'ty': 'st',
          'c': _colorToLottie(shapeData!.strokeColor!),
          'o': {'a': 0, 'k': 100},
          'w': {'a': 0, 'k': shapeData!.strokeWidth},
        },
    ];
  }

  Map<String, dynamic> _colorToLottie(Color color) {
    return {
      'a': 0,
      'k': [
        color.red / 255,
        color.green / 255,
        color.blue / 255,
        color.alpha / 255,
      ],
    };
  }
}
