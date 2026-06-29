
class ScaleOptions {
  final num min;
  final num max;
  final num step;
  final String? minLabel;
  final String? maxLabel;
  final bool showTicks;
  final bool showLabels;
  final num? defaultValue;

  ScaleOptions({
    required this.min,
    required this.max,
    required this.step,
    this.minLabel,
    this.maxLabel,
    required this.showTicks,
    required this.showLabels,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'step': step,
        'minLabel': minLabel,
        'maxLabel': maxLabel,
        'showTicks': showTicks,
        'showLabels': showLabels,
        'defaultValue': defaultValue,
      };

  factory ScaleOptions.fromJson(Map<String, dynamic> json) => ScaleOptions(
        min: json['min'],
        max: json['max'],
        step: json['step'],
        minLabel: json['minLabel'],
        maxLabel: json['maxLabel'],
        showTicks: json['showTicks'],
        showLabels: json['showLabels'],
        defaultValue: json['defaultValue'],
      );
}
