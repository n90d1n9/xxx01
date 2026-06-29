class CanvasConfig {
  final double? zoom;
  final double? panX;
  final double? panY;
  final double? minZoom;
  final double? maxZoom;

  CanvasConfig({
    this.zoom = 1.0,
    this.panX = 0.0,
    this.panY = 0.0,
    this.minZoom = 0.1,
    this.maxZoom = 2.0,
  });

  factory CanvasConfig.fromJson(Map<String, dynamic> json) {
    return CanvasConfig(
      zoom: json['zoom'] != null ? (json['zoom'] as num).toDouble() : null,
      panX: json['panX'] != null ? (json['panX'] as num).toDouble() : null,
      panY: json['panY'] != null ? (json['panY'] as num).toDouble() : null,
      minZoom: json['minZoom'] != null
          ? (json['minZoom'] as num).toDouble()
          : null,
      maxZoom: json['maxZoom'] != null
          ? (json['maxZoom'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (zoom != null) 'zoom': zoom,
      if (panX != null) 'panX': panX,
      if (panY != null) 'panY': panY,
      if (minZoom != null) 'minZoom': minZoom,
      if (maxZoom != null) 'maxZoom': maxZoom,
    };
  }
}
