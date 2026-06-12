import 'package:flutter/material.dart';

enum AnimationType {
  none,
  fadeIn,
  slideInLeft,
  slideInRight,
  slideInUp,
  slideInDown,
  scaleIn,
  rotateIn,
  bounce,
  pulse,
  shake,
  fadeOut,
  scaleOut,
  rotateOut,
  bounceIn,
  bounceOut,
  wiggle,
  heartBeat,
  flash,
  rubberBand,
  swing,
  tada,
  elastic,
  jello,
  wobble,
  flip,
  rotate360,
  zoom,
  morph,
}

class ComponentAnimation {
  final AnimationType type;
  final double duration;
  final double delay;
  final bool repeat;
  final Curve curve;

  ComponentAnimation({
    this.type = AnimationType.none,
    this.duration = 1.0,
    this.delay = 0.0,
    this.repeat = false,

    this.curve = Curves.easeInOut,
  });

  ComponentAnimation copyWith({
    AnimationType? type,
    double? duration,
    double? delay,
    bool? repeat,
    Curve? curve,
  }) {
    return ComponentAnimation(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      delay: delay ?? this.delay,
      repeat: repeat ?? this.repeat,
      curve: curve ?? this.curve,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'duration': duration,
    'delay': delay,
    'repeat': repeat,
  };

  factory ComponentAnimation.fromJson(Map<String, dynamic> json) {
    return ComponentAnimation(
      type: AnimationType.values.byName(json['type'] ?? 'none'),
      duration: json['duration'] ?? 1.0,
      delay: json['delay'] ?? 0.0,
      repeat: json['repeat'] ?? false,
    );
  }
}
