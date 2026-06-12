class ShadowLayer {
  final String offsetX;
  final String offsetY;
  final String? blur;
  final String? spread;
  final String color;
  final bool inset;

  ShadowLayer({
    required this.offsetX,
    required this.offsetY,
    this.blur,
    this.spread,
    required this.color,
    this.inset = false,
  });

  factory ShadowLayer.fromJson(Map<String, dynamic> json) {
    return ShadowLayer(
      offsetX: json['offsetX'] as String,
      offsetY: json['offsetY'] as String,
      blur: json['blur'] as String?,
      spread: json['spread'] as String?,
      color: json['color'] as String,
      inset: json['inset'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'offsetX': offsetX,
    'offsetY': offsetY,
    if (blur != null) 'blur': blur,
    if (spread != null) 'spread': spread,
    'color': color,
    'inset': inset,
  };
}
