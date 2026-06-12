class Spacing {
  final String? top;
  final String? right;
  final String? bottom;
  final String? left;
  final String? all; // Shorthand for all sides

  Spacing({this.top, this.right, this.bottom, this.left, this.all});

  factory Spacing.fromJson(Map<String, dynamic> json) {
    return Spacing(
      top: json['top'] as String?,
      right: json['right'] as String?,
      bottom: json['bottom'] as String?,
      left: json['left'] as String?,
      all: json['all'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (top != null) 'top': top,
    if (right != null) 'right': right,
    if (bottom != null) 'bottom': bottom,
    if (left != null) 'left': left,
    if (all != null) 'all': all,
  };
}
