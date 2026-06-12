import '../layout/transform.dart';
import '../styles/styles.dart';

class HoverAnimation {
  final Styles? hoverStyles;
  final Transform? hoverTransform;
  final String? duration;
  final String? timingFunction;

  HoverAnimation({
    this.hoverStyles,
    this.hoverTransform,
    this.duration,
    this.timingFunction,
  });

  factory HoverAnimation.fromJson(Map<String, dynamic> json) {
    return HoverAnimation(
      hoverStyles:
          json['hoverStyles'] != null
              ? Styles.fromJson(json['hoverStyles'] as Map<String, dynamic>)
              : null,
      hoverTransform:
          json['hoverTransform'] != null
              ? Transform.fromJson(
                json['hoverTransform'] as Map<String, dynamic>,
              )
              : null,
      duration: json['duration'] as String?,
      timingFunction: json['timingFunction'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (hoverStyles != null) 'hoverStyles': hoverStyles!.toJson(),
    if (hoverTransform != null) 'hoverTransform': hoverTransform!.toJson(),
    if (duration != null) 'duration': duration,
    if (timingFunction != null) 'timingFunction': timingFunction,
  };
}
