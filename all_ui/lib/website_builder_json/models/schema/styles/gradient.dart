import 'gradient_stop.dart';

class Gradient {
  final String type; // linear, radial, conic
  final List<GradientStop> stops;
  final String? angle;
  final String? position;

  Gradient({
    required this.type,
    required this.stops,
    this.angle,
    this.position,
  });

  factory Gradient.fromJson(Map<String, dynamic> json) {
    return Gradient(
      type: json['type'] as String,
      stops:
          (json['stops'] as List)
              .map((s) => GradientStop.fromJson(s as Map<String, dynamic>))
              .toList(),
      angle: json['angle'] as String?,
      position: json['position'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'stops': stops.map((s) => s.toJson()).toList(),
    if (angle != null) 'angle': angle,
    if (position != null) 'position': position,
  };
}
