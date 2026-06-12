class LayoutItem {
  final String id;
  final String type;
  final double x;
  final double y;
  final double width;
  final double height;

  LayoutItem({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  LayoutItem copyWith({
    String? id,
    String? type,
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return LayoutItem(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
