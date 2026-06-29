import 'package:flutter/widgets.dart';

@immutable
class ImageData {
  final String href;
  final double x, y, width, height;
  final BoxFit fit;

  const ImageData({
    required this.href,
    this.x = 0,
    this.y = 0,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  Map<String, dynamic> toJson() => {
    'href': href,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'fit': fit.toString(),
  };

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      href: json['href'] ?? '',
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 100).toDouble(),
      height: (json['height'] ?? 100).toDouble(),
      fit: BoxFit.cover,
    );
  }
}
