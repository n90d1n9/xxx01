class BorderRadius {
  final String? topLeft;
  final String? topRight;
  final String? bottomLeft;
  final String? bottomRight;
  final String? all;

  BorderRadius({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
    this.all,
  });

  factory BorderRadius.fromJson(Map<String, dynamic> json) {
    return BorderRadius(
      topLeft: json['topLeft'] as String?,
      topRight: json['topRight'] as String?,
      bottomLeft: json['bottomLeft'] as String?,
      bottomRight: json['bottomRight'] as String?,
      all: json['all'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (topLeft != null) 'topLeft': topLeft,
    if (topRight != null) 'topRight': topRight,
    if (bottomLeft != null) 'bottomLeft': bottomLeft,
    if (bottomRight != null) 'bottomRight': bottomRight,
    if (all != null) 'all': all,
  };
}
