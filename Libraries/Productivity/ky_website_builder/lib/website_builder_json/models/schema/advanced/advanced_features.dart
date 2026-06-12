import 'accessibility_config.dart';
import 'analytics_config.dart';
import 'lazy_loading.dart';
import 'performance_config.dart';
import 'pwa_config.dart';

class AdvancedFeatures {
  final LazyLoading? lazyLoading;
  final PWAConfig? pwa;
  final AnalyticsConfig? analytics;
  final AccessibilityConfig? accessibility;
  final PerformanceConfig? performance;

  AdvancedFeatures({
    this.lazyLoading,
    this.pwa,
    this.analytics,
    this.accessibility,
    this.performance,
  });

  factory AdvancedFeatures.fromJson(Map<String, dynamic> json) {
    return AdvancedFeatures(
      lazyLoading:
          json['lazyLoading'] != null
              ? LazyLoading.fromJson(
                json['lazyLoading'] as Map<String, dynamic>,
              )
              : null,
      pwa:
          json['pwa'] != null
              ? PWAConfig.fromJson(json['pwa'] as Map<String, dynamic>)
              : null,
      analytics:
          json['analytics'] != null
              ? AnalyticsConfig.fromJson(
                json['analytics'] as Map<String, dynamic>,
              )
              : null,
      accessibility:
          json['accessibility'] != null
              ? AccessibilityConfig.fromJson(
                json['accessibility'] as Map<String, dynamic>,
              )
              : null,
      performance:
          json['performance'] != null
              ? PerformanceConfig.fromJson(
                json['performance'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (lazyLoading != null) 'lazyLoading': lazyLoading!.toJson(),
    if (pwa != null) 'pwa': pwa!.toJson(),
    if (analytics != null) 'analytics': analytics!.toJson(),
    if (accessibility != null) 'accessibility': accessibility!.toJson(),
    if (performance != null) 'performance': performance!.toJson(),
  };
}
