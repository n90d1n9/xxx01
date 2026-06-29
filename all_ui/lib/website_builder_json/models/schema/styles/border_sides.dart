import 'border_side.dart';

class BorderSides {
  final BorderSide? top;
  final BorderSide? right;
  final BorderSide? bottom;
  final BorderSide? left;

  BorderSides({this.top, this.right, this.bottom, this.left});

  factory BorderSides.fromJson(Map<String, dynamic> json) {
    return BorderSides(
      top:
          json['top'] != null
              ? BorderSide.fromJson(json['top'] as Map<String, dynamic>)
              : null,
      right:
          json['right'] != null
              ? BorderSide.fromJson(json['right'] as Map<String, dynamic>)
              : null,
      bottom:
          json['bottom'] != null
              ? BorderSide.fromJson(json['bottom'] as Map<String, dynamic>)
              : null,
      left:
          json['left'] != null
              ? BorderSide.fromJson(json['left'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (top != null) 'top': top!.toJson(),
    if (right != null) 'right': right!.toJson(),
    if (bottom != null) 'bottom': bottom!.toJson(),
    if (left != null) 'left': left!.toJson(),
  };
}
