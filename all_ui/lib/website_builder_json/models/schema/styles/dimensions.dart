class Dimensions {
  final String? width;
  final String? height;
  final String? minWidth;
  final String? minHeight;
  final String? maxWidth;
  final String? maxHeight;
  final String? aspectRatio;

  Dimensions({
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.aspectRatio,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: json['width'] as String?,
      height: json['height'] as String?,
      minWidth: json['minWidth'] as String?,
      minHeight: json['minHeight'] as String?,
      maxWidth: json['maxWidth'] as String?,
      maxHeight: json['maxHeight'] as String?,
      aspectRatio: json['aspectRatio'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (minWidth != null) 'minWidth': minWidth,
    if (minHeight != null) 'minHeight': minHeight,
    if (maxWidth != null) 'maxWidth': maxWidth,
    if (maxHeight != null) 'maxHeight': maxHeight,
    if (aspectRatio != null) 'aspectRatio': aspectRatio,
  };
}
