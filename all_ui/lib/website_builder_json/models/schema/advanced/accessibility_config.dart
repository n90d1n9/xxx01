import 'aria_config.dart';

class AccessibilityConfig {
  final bool enabled;
  final String colorScheme; // light, dark, auto
  final bool highContrast;
  final bool reducedMotion;
  final AriaConfig? aria;
  final Map<String, String>? labels;

  AccessibilityConfig({
    required this.enabled,
    required this.colorScheme,
    this.highContrast = false,
    this.reducedMotion = false,
    this.aria,
    this.labels,
  });

  factory AccessibilityConfig.fromJson(Map<String, dynamic> json) {
    return AccessibilityConfig(
      enabled: json['enabled'] as bool,
      colorScheme: json['colorScheme'] as String,
      highContrast: json['highContrast'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      aria:
          json['aria'] != null
              ? AriaConfig.fromJson(json['aria'] as Map<String, dynamic>)
              : null,
      labels:
          json['labels'] != null
              ? Map<String, String>.from(json['labels'] as Map)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'colorScheme': colorScheme,
    'highContrast': highContrast,
    'reducedMotion': reducedMotion,
    if (aria != null) 'aria': aria!.toJson(),
    if (labels != null) 'labels': labels,
  };
}
