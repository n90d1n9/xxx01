import 'scroll_keyframe.dart';

class ScrollAnimation {
  final String trigger; // Scroll position or element
  final String start; // "top center", "bottom top", etc.
  final String? end;
  final bool scrub; // Link animation to scroll position
  final List<ScrollKeyframe>? timeline;

  ScrollAnimation({
    required this.trigger,
    required this.start,
    this.end,
    this.scrub = false,
    this.timeline,
  });

  factory ScrollAnimation.fromJson(Map<String, dynamic> json) {
    return ScrollAnimation(
      trigger: json['trigger'] as String,
      start: json['start'] as String,
      end: json['end'] as String?,
      scrub: json['scrub'] as bool? ?? false,
      timeline:
          json['timeline'] != null
              ? (json['timeline'] as List)
                  .map(
                    (t) => ScrollKeyframe.fromJson(t as Map<String, dynamic>),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'trigger': trigger,
    'start': start,
    if (end != null) 'end': end,
    'scrub': scrub,
    if (timeline != null) 'timeline': timeline!.map((t) => t.toJson()).toList(),
  };
}
