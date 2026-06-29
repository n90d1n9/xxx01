class BorderSide {
  final String? width;
  final String? style;
  final String? color;

  BorderSide({this.width, this.style, this.color});

  factory BorderSide.fromJson(Map<String, dynamic> json) {
    return BorderSide(
      width: json['width'] as String?,
      style: json['style'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (width != null) 'width': width,
    if (style != null) 'style': style,
    if (color != null) 'color': color,
  };
}
