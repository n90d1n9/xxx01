import 'package:flutter/material.dart';

class GridSettings {
  final double gridSize;
  final double opacity;
  final bool enabled;
  final bool snapToGrid;
  final Color gridColor;
  final bool showSubgrid;

  const GridSettings({
    this.gridSize = 20,
    this.opacity = 0.3,
    this.enabled = true,
    this.snapToGrid = true,
    this.gridColor = Colors.grey,
    this.showSubgrid = true,
  });

  bool get showGrid => enabled;

  double get cellSize => gridSize;

  GridSettings copyWith({
    double? gridSize,
    double? opacity,
    bool? enabled,
    bool? snapToGrid,
    bool? showGrid,
    double? cellSize,
    Color? gridColor,
    bool? showSubgrid,
  }) {
    return GridSettings(
      gridSize: cellSize ?? gridSize ?? this.gridSize,
      opacity: opacity ?? this.opacity,
      enabled: showGrid ?? enabled ?? this.enabled,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridColor: gridColor ?? this.gridColor,
      showSubgrid: showSubgrid ?? this.showSubgrid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gridSize': gridSize,
      'opacity': opacity,
      'enabled': enabled,
      'snapToGrid': snapToGrid,
      'gridColor': gridColor.toARGB32(),
      'showSubgrid': showSubgrid,
    };
  }

  factory GridSettings.fromJson(Map<String, dynamic> json) {
    return GridSettings(
      gridSize: (json['gridSize'] as num?)?.toDouble() ?? 20,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.3,
      enabled: json['enabled'] as bool? ?? true,
      snapToGrid: json['snapToGrid'] as bool? ?? true,
      gridColor: Color(json['gridColor'] as int? ?? Colors.grey.toARGB32()),
      showSubgrid: json['showSubgrid'] as bool? ?? true,
    );
  }
}
