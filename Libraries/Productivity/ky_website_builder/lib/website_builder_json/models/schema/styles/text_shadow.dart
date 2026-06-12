class TextShadow {
  final String offsetX;
  final String offsetY;
  final String? blur;
  final String color;

  TextShadow({
    required this.offsetX,
    required this.offsetY,
    this.blur,
    required this.color,
  });

  factory TextShadow.fromJson(Map<String, dynamic> json) {
    return TextShadow(
      offsetX: json['offsetX'] as String,
      offsetY: json['offsetY'] as String,
      blur: json['blur'] as String?,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'offsetX': offsetX,
    'offsetY': offsetY,
    if (blur != null) 'blur': blur,
    'color': color,
  };
}
