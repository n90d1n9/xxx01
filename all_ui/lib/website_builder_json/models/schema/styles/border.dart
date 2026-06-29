import 'border_radius.dart';
import 'border_sides.dart';

class Border {
  final String? width;
  final String? style;
  final String? color;
  final BorderRadius? radius;
  final BorderSides? sides; // Individual side configurations

  Border({this.width, this.style, this.color, this.radius, this.sides});

  factory Border.fromJson(Map<String, dynamic> json) {
    return Border(
      width: json['width'] as String?,
      style: json['style'] as String?,
      color: json['color'] as String?,
      radius:
          json['radius'] != null
              ? BorderRadius.fromJson(json['radius'] as Map<String, dynamic>)
              : null,
      sides:
          json['sides'] != null
              ? BorderSides.fromJson(json['sides'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (width != null) 'width': width,
    if (style != null) 'style': style,
    if (color != null) 'color': color,
    if (radius != null) 'radius': radius!.toJson(),
    if (sides != null) 'sides': sides!.toJson(),
  };
}
