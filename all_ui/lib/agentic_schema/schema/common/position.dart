class Position {
  final double x;
  final double y;
  final double? z;

  Position({required this.x, required this.y, this.z});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: json['z'] != null ? (json['z'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, if (z != null) 'z': z};
  }

  Position copyWith({double? x, double? y, double? z}) {
    return Position(x: x ?? this.x, y: y ?? this.y, z: z ?? this.z);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Position &&
            runtimeType == other.runtimeType &&
            x == other.x &&
            y == other.y &&
            z == other.z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);
}
