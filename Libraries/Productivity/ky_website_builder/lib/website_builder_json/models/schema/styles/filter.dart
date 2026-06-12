class Filter {
  final String? blur;
  final String? brightness;
  final String? contrast;
  final String? grayscale;
  final String? hueRotate;
  final String? invert;
  final String? saturate;
  final String? sepia;
  final String? dropShadow;

  Filter({
    this.blur,
    this.brightness,
    this.contrast,
    this.grayscale,
    this.hueRotate,
    this.invert,
    this.saturate,
    this.sepia,
    this.dropShadow,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      blur: json['blur'] as String?,
      brightness: json['brightness'] as String?,
      contrast: json['contrast'] as String?,
      grayscale: json['grayscale'] as String?,
      hueRotate: json['hueRotate'] as String?,
      invert: json['invert'] as String?,
      saturate: json['saturate'] as String?,
      sepia: json['sepia'] as String?,
      dropShadow: json['dropShadow'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (blur != null) 'blur': blur,
    if (brightness != null) 'brightness': brightness,
    if (contrast != null) 'contrast': contrast,
    if (grayscale != null) 'grayscale': grayscale,
    if (hueRotate != null) 'hueRotate': hueRotate,
    if (invert != null) 'invert': invert,
    if (saturate != null) 'saturate': saturate,
    if (sepia != null) 'sepia': sepia,
    if (dropShadow != null) 'dropShadow': dropShadow,
  };
}
