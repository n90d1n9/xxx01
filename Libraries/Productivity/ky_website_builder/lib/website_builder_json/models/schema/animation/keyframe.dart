import 'keyframe_step.dart';

class Keyframes {
  final Map<String, KeyframeStep> steps;

  Keyframes({required this.steps});

  factory Keyframes.fromJson(Map<String, dynamic> json) {
    return Keyframes(
      steps: (json['steps'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, KeyframeStep.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'steps': steps.map((k, v) => MapEntry(k, v.toJson())),
  };
}
