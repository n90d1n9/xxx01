import 'package:flutter/material.dart';

import 'layer/animated_layer.dart';

@immutable
class SvgAnimationDefinition {
  final String id;
  final String name;
  final double duration;
  final bool loop;
  final double fps;
  final Size artboardSize;
  final List<AnimatedLayer> layers;
  final Map<String, dynamic> metadata;

  // Cached values for performance
  late final int totalFrames = (duration * fps).round();
  late final double frameDuration = 1.0 / fps;

  SvgAnimationDefinition({
    required this.id,
    required this.name,
    required this.duration,
    this.loop = false,
    this.fps = 60,
    required this.artboardSize,
    required this.layers,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'schema_version': '1.0.0',
    'id': id,
    'name': name,
    'duration': duration,
    'loop': loop,
    'fps': fps,
    'artboard': {'width': artboardSize.width, 'height': artboardSize.height},
    'layers': layers.map((l) => l.toJson()).toList(),
    'metadata': metadata,
  };

  factory SvgAnimationDefinition.fromJson(Map<String, dynamic> json) {
    return SvgAnimationDefinition(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      duration: (json['duration'] ?? 1.0).toDouble(),
      loop: json['loop'] ?? false,
      fps: (json['fps'] ?? 60).toDouble(),
      artboardSize: Size(
        (json['artboard']?['width'] ?? 100).toDouble(),
        (json['artboard']?['height'] ?? 100).toDouble(),
      ),
      layers:
          (json['layers'] as List?)
              ?.map((l) => AnimatedLayer.fromJson(l))
              .toList() ??
          [],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toLottie() {
    return {
      'v': '5.9.0',
      'fr': fps,
      'ip': 0,
      'op': totalFrames,
      'w': artboardSize.width.toInt(),
      'h': artboardSize.height.toInt(),
      'nm': name,
      'ddd': 0,
      'assets': [],
      'layers':
          layers
              .asMap()
              .entries
              .map((e) => e.value.toLottie(e.key, totalFrames))
              .toList(),
    };
  }

  Map<String, dynamic> toRive() {
    return {
      'version': 7,
      'artboards': [
        {
          'name': name,
          'width': artboardSize.width,
          'height': artboardSize.height,
          'animations': [
            {
              'name': name,
              'fps': fps.toInt(),
              'duration': totalFrames,
              'loop': loop ? 1 : 0,
              'keyed_objects': layers.map((l) => l.toRive()).toList(),
            },
          ],
        },
      ],
    };
  }
}
