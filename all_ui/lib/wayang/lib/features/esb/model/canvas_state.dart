import 'package:flutter/widgets.dart';

class CanvasState {
  final double scale;
  final Offset offset;
  final bool gridVisible;
  final bool snapToGrid;
  final bool minimapVisible;
  final double gridSize;

  CanvasState({
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.gridVisible = true,
    this.snapToGrid = false,
    this.minimapVisible = true,
    this.gridSize = 20.0,
  });

  CanvasState copyWith({
    double? scale,
    Offset? offset,
    bool? gridVisible,
    bool? snapToGrid,
    bool? minimapVisible,
    double? gridSize,
  }) {
    return CanvasState(
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      gridVisible: gridVisible ?? this.gridVisible,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      minimapVisible: minimapVisible ?? this.minimapVisible,
      gridSize: gridSize ?? this.gridSize,
    );
  }
}
