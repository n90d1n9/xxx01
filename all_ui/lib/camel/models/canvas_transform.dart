// Canvas Transform State (Zoom & Pan)
import 'package:flutter/material.dart';

class CanvasTransform {
  final Offset offset;
  final double scale;

  CanvasTransform({this.offset = Offset.zero, this.scale = 1.0});

  CanvasTransform copyWith({Offset? offset, double? scale}) {
    return CanvasTransform(
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
    );
  }
}
