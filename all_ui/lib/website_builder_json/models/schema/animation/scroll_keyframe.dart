import '../layout/transform.dart';
import '../styles/styles.dart';

class ScrollKeyframe {
  final String position; // percentage of scroll progress
  final Styles? styles;
  final Transform? transform;

  ScrollKeyframe({required this.position, this.styles, this.transform});

  factory ScrollKeyframe.fromJson(Map<String, dynamic> json) {
    return ScrollKeyframe(
      position: json['position'] as String,
      styles:
          json['styles'] != null
              ? Styles.fromJson(json['styles'] as Map<String, dynamic>)
              : null,
      transform:
          json['transform'] != null
              ? Transform.fromJson(json['transform'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'position': position,
    if (styles != null) 'styles': styles!.toJson(),
    if (transform != null) 'transform': transform!.toJson(),
  };
}
