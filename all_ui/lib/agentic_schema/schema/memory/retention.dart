class Retention {
  final int duration;
  final String unit;
  final bool? autoCleanup;

  Retention({
    required this.duration,
    required this.unit,
    this.autoCleanup = true,
  });

  factory Retention.fromJson(Map<String, dynamic> json) {
    return Retention(
      duration: json['duration'] as int,
      unit: json['unit'] as String,
      autoCleanup: json['autoCleanup'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'unit': unit,
      if (autoCleanup != null) 'autoCleanup': autoCleanup,
    };
  }
}
