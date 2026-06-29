class BackgroundImage {
  final String url;
  final String? size; // cover, contain, auto, or specific dimensions
  final String? position;
  final String? repeat;
  final String? attachment; // scroll, fixed, local

  BackgroundImage({
    required this.url,
    this.size,
    this.position,
    this.repeat,
    this.attachment,
  });

  factory BackgroundImage.fromJson(Map<String, dynamic> json) {
    return BackgroundImage(
      url: json['url'] as String,
      size: json['size'] as String?,
      position: json['position'] as String?,
      repeat: json['repeat'] as String?,
      attachment: json['attachment'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    if (size != null) 'size': size,
    if (position != null) 'position': position,
    if (repeat != null) 'repeat': repeat,
    if (attachment != null) 'attachment': attachment,
  };
}
