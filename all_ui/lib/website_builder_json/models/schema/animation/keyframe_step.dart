import '../layout/transform.dart';
import '../styles/styles.dart';

class KeyframeStep {
  final Styles? styles;
  final Transform? transform;
  final String? opacity;

  KeyframeStep({this.styles, this.transform, this.opacity});

  factory KeyframeStep.fromJson(Map<String, dynamic> json) {
    return KeyframeStep(
      styles:
          json['styles'] != null
              ? Styles.fromJson(json['styles'] as Map<String, dynamic>)
              : null,
      transform:
          json['transform'] != null
              ? Transform.fromJson(json['transform'] as Map<String, dynamic>)
              : null,
      opacity: json['opacity'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (styles != null) 'styles': styles!.toJson(),
    if (transform != null) 'transform': transform!.toJson(),
    if (opacity != null) 'opacity': opacity,
  };
}
