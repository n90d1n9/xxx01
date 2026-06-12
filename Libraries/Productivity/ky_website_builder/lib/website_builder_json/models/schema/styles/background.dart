import 'background_image.dart';
import 'gradient.dart';

class Background {
  final String? color;
  final Gradient? gradient;
  final BackgroundImage? image;
  final String? blend; // blend mode

  Background({this.color, this.gradient, this.image, this.blend});

  factory Background.fromJson(Map<String, dynamic> json) {
    return Background(
      color: json['color'] as String?,
      gradient:
          json['gradient'] != null
              ? Gradient.fromJson(json['gradient'] as Map<String, dynamic>)
              : null,
      image:
          json['image'] != null
              ? BackgroundImage.fromJson(json['image'] as Map<String, dynamic>)
              : null,
      blend: json['blend'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (color != null) 'color': color,
    if (gradient != null) 'gradient': gradient!.toJson(),
    if (image != null) 'image': image!.toJson(),
    if (blend != null) 'blend': blend,
  };
}
