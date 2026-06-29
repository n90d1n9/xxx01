class Transition {
  final String? property;
  final String? duration;
  final String? timingFunction;
  final String? delay;

  Transition({this.property, this.duration, this.timingFunction, this.delay});

  factory Transition.fromJson(Map<String, dynamic> json) {
    return Transition(
      property: json['property'] as String?,
      duration: json['duration'] as String?,
      timingFunction: json['timingFunction'] as String?,
      delay: json['delay'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (property != null) 'property': property,
    if (duration != null) 'duration': duration,
    if (timingFunction != null) 'timingFunction': timingFunction,
    if (delay != null) 'delay': delay,
  };
}
