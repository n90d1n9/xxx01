class AssetMetadata {
  final int? width;
  final int? height;
  final int? size; // bytes
  final String? mimeType;
  final String? alt;
  final String? caption;
  final Map<String, dynamic>? custom;

  AssetMetadata({
    this.width,
    this.height,
    this.size,
    this.mimeType,
    this.alt,
    this.caption,
    this.custom,
  });

  factory AssetMetadata.fromJson(Map<String, dynamic> json) {
    return AssetMetadata(
      width: json['width'] as int?,
      height: json['height'] as int?,
      size: json['size'] as int?,
      mimeType: json['mimeType'] as String?,
      alt: json['alt'] as String?,
      caption: json['caption'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (size != null) 'size': size,
    if (mimeType != null) 'mimeType': mimeType,
    if (alt != null) 'alt': alt,
    if (caption != null) 'caption': caption,
    if (custom != null) 'custom': custom,
  };
}
