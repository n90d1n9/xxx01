import 'animation_keyframe.dart';

class AnimationTimeline {
  final String layerId;
  final List<AnimationKeyframe> keyframes;

  AnimationTimeline({required this.layerId, required this.keyframes});
}
