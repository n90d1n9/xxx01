class ActionTiming {
  final String? delay;
  final String? duration;
  final bool async;

  ActionTiming({this.delay, this.duration, this.async = false});

  factory ActionTiming.fromJson(Map<String, dynamic> json) {
    return ActionTiming(
      delay: json['delay'] as String?,
      duration: json['duration'] as String?,
      async: json['async'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (delay != null) 'delay': delay,
    if (duration != null) 'duration': duration,
    'async': async,
  };
}
