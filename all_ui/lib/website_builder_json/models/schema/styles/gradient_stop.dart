class GradientStop {
  final String color;
  final String position; // percentage or length

  GradientStop({required this.color, required this.position});

  factory GradientStop.fromJson(Map<String, dynamic> json) {
    return GradientStop(
      color: json['color'] as String,
      position: json['position'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'color': color, 'position': position};
}
