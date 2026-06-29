import 'package:flutter/material.dart';

import '../../timeline/animation_keyframe.dart';
import 'layer.dart';

class DesignerLayer {
  String id;
  String name;
  LayerType type;
  Offset position;
  Size size;
  Color color;
  double rotation;
  double scale;
  double opacity;
  bool visible;
  List<AnimationKeyframe> keyframes;

  DesignerLayer({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.size,
    required this.color,
    this.rotation = 0,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.visible = true,
    this.keyframes = const [],
  });
}
