import 'package:flutter/widgets.dart';

import 'easing_type.dart';
import 'keyframe.dart';

@immutable
class AnimatedProperty {
  final String property;
  final List<Keyframe> keyframes;
  final EasingType easing;

  // Cache for fast lookups
  late final bool isAnimated = keyframes.length > 1;
  late final dynamic staticValue =
      keyframes.isEmpty ? null : keyframes.first.value;

  AnimatedProperty({
    required this.property,
    required this.keyframes,
    this.easing = EasingType.linear,
  });

  dynamic interpolate(double time) {
    if (keyframes.isEmpty) return null;
    if (!isAnimated) return staticValue;

    // Binary search for surrounding keyframes
    int left = 0;
    int right = keyframes.length - 1;

    if (time <= keyframes[left].time) return keyframes[left].value;
    if (time >= keyframes[right].time) return keyframes[right].value;

    while (left < right - 1) {
      final mid = (left + right) ~/ 2;
      if (keyframes[mid].time <= time) {
        left = mid;
      } else {
        right = mid;
      }
    }

    final before = keyframes[left];
    final after = keyframes[right];

    final t = (time - before.time) / (after.time - before.time);
    final easedT = easing.apply(t);

    return _lerp(before.value, after.value, easedT);
  }

  dynamic _lerp(dynamic a, dynamic b, double t) {
    if (a is num && b is num) {
      return a + (b - a) * t;
    } else if (a is List && b is List && a.length == b.length) {
      return List.generate(a.length, (i) => _lerp(a[i], b[i], t));
    } else if (a is Color && b is Color) {
      return Color.lerp(a, b, t);
    }
    return t < 0.5 ? a : b;
  }

  Map<String, dynamic> toJson() => {
    'property': property,
    'keyframes': keyframes.map((k) => k.toJson()).toList(),
    'easing': easing.name,
  };

  factory AnimatedProperty.fromJson(Map<String, dynamic> json) {
    return AnimatedProperty(
      property: json['property'] ?? '',
      keyframes:
          (json['keyframes'] as List?)
              ?.map((k) => Keyframe.fromJson(k))
              .toList() ??
          [],
      easing: EasingType.values.firstWhere(
        (e) => e.name == json['easing'],
        orElse: () => EasingType.linear,
      ),
    );
  }

  Map<String, dynamic> toLottieProperty(int totalFrames) {
    if (!isAnimated) {
      return {'a': 0, 'k': _valueToLottie(staticValue)};
    }

    return {
      'a': 1,
      'k':
          keyframes
              .map(
                (k) => {
                  't': (k.time * totalFrames / keyframes.last.time).round(),
                  's': [_valueToLottie(k.value)],
                  'i': {
                    'x': [0.833],
                    'y': [0.833],
                  },
                  'o': {
                    'x': [0.167],
                    'y': [0.167],
                  },
                },
              )
              .toList(),
    };
  }

  dynamic _valueToLottie(dynamic value) {
    if (value is List) return value;
    if (value is Color) {
      return [
        value.red / 255,
        value.green / 255,
        value.blue / 255,
        value.alpha / 255,
      ];
    }
    return value;
  }

  Map<String, dynamic> toRive() {
    return {
      'property': property,
      'frames':
          keyframes.map((k) => {'frame': k.time, 'value': k.value}).toList(),
    };
  }
}
