class Positioning {
  final String? top;
  final String? right;
  final String? bottom;
  final String? left;

  Positioning({this.top, this.right, this.bottom, this.left});

  factory Positioning.fromJson(Map<String, dynamic> json) {
    return Positioning(
      top: json['top'] as String?,
      right: json['right'] as String?,
      bottom: json['bottom'] as String?,
      left: json['left'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (top != null) 'top': top,
    if (right != null) 'right': right,
    if (bottom != null) 'bottom': bottom,
    if (left != null) 'left': left,
  };
}
