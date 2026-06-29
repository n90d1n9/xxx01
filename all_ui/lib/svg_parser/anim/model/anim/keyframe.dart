import 'package:flutter/widgets.dart';

@immutable
class Keyframe {
  final double time;
  final dynamic value;

  const Keyframe({required this.time, required this.value});

  Map<String, dynamic> toJson() => {'time': time, 'value': value};

  factory Keyframe.fromJson(Map<String, dynamic> json) {
    return Keyframe(time: (json['time'] ?? 0).toDouble(), value: json['value']);
  }
}
