import 'hover_animation.dart';
import 'keyframe.dart';
import 'scrool_animation,dart';

class Animation {
  final String type; // keyframe, scroll, hover, entrance, exit
  final String? name;
  final Keyframes? keyframes;
  final String? duration;
  final String? timingFunction;
  final String? delay;
  final String? iterationCount;
  final String? direction;
  final String? fillMode;
  final ScrollAnimation? scrollAnimation;
  final HoverAnimation? hoverAnimation;

  Animation({
    required this.type,
    this.name,
    this.keyframes,
    this.duration,
    this.timingFunction,
    this.delay,
    this.iterationCount,
    this.direction,
    this.fillMode,
    this.scrollAnimation,
    this.hoverAnimation,
  });

  factory Animation.fromJson(Map<String, dynamic> json) {
    return Animation(
      type: json['type'] as String,
      name: json['name'] as String?,
      keyframes:
          json['keyframes'] != null
              ? Keyframes.fromJson(json['keyframes'] as Map<String, dynamic>)
              : null,
      duration: json['duration'] as String?,
      timingFunction: json['timingFunction'] as String?,
      delay: json['delay'] as String?,
      iterationCount: json['iterationCount'] as String?,
      direction: json['direction'] as String?,
      fillMode: json['fillMode'] as String?,
      scrollAnimation:
          json['scrollAnimation'] != null
              ? ScrollAnimation.fromJson(
                json['scrollAnimation'] as Map<String, dynamic>,
              )
              : null,
      hoverAnimation:
          json['hoverAnimation'] != null
              ? HoverAnimation.fromJson(
                json['hoverAnimation'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (name != null) 'name': name,
    if (keyframes != null) 'keyframes': keyframes!.toJson(),
    if (duration != null) 'duration': duration,
    if (timingFunction != null) 'timingFunction': timingFunction,
    if (delay != null) 'delay': delay,
    if (iterationCount != null) 'iterationCount': iterationCount,
    if (direction != null) 'direction': direction,
    if (fillMode != null) 'fillMode': fillMode,
    if (scrollAnimation != null) 'scrollAnimation': scrollAnimation!.toJson(),
    if (hoverAnimation != null) 'hoverAnimation': hoverAnimation!.toJson(),
  };
}
