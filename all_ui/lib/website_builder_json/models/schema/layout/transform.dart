class Transform {
  final String? translate;
  final String? translateX;
  final String? translateY;
  final String? scale;
  final String? scaleX;
  final String? scaleY;
  final String? rotate;
  final String? skew;
  final String? skewX;
  final String? skewY;
  final String? origin;
  final String? perspective;

  Transform({
    this.translate,
    this.translateX,
    this.translateY,
    this.scale,
    this.scaleX,
    this.scaleY,
    this.rotate,
    this.skew,
    this.skewX,
    this.skewY,
    this.origin,
    this.perspective,
  });

  factory Transform.fromJson(Map<String, dynamic> json) {
    return Transform(
      translate: json['translate'] as String?,
      translateX: json['translateX'] as String?,
      translateY: json['translateY'] as String?,
      scale: json['scale'] as String?,
      scaleX: json['scaleX'] as String?,
      scaleY: json['scaleY'] as String?,
      rotate: json['rotate'] as String?,
      skew: json['skew'] as String?,
      skewX: json['skewX'] as String?,
      skewY: json['skewY'] as String?,
      origin: json['origin'] as String?,
      perspective: json['perspective'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (translate != null) 'translate': translate,
    if (translateX != null) 'translateX': translateX,
    if (translateY != null) 'translateY': translateY,
    if (scale != null) 'scale': scale,
    if (scaleX != null) 'scaleX': scaleX,
    if (scaleY != null) 'scaleY': scaleY,
    if (rotate != null) 'rotate': rotate,
    if (skew != null) 'skew': skew,
    if (skewX != null) 'skewX': skewX,
    if (skewY != null) 'skewY': skewY,
    if (origin != null) 'origin': origin,
    if (perspective != null) 'perspective': perspective,
  };
}
