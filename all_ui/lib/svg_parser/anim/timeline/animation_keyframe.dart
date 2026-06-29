class AnimationKeyframe {
  final double time;
  final String property;
  final dynamic value;
  final String easing;

  AnimationKeyframe({
    required this.time,
    required this.property,
    required this.value,
    this.easing = 'linear',
  });
}
