import 'kitchen_station.dart';
import 'kitchen_station_summary.dart';
import 'service_status.dart';

/// Shared kitchen station lenses for station lists, chips, and saved filters.
enum FnbKitchenStationFilter {
  all,
  pressure,
  delayed,
  calm;

  static const delayedFireMinuteThreshold =
      FnbKitchenStationSummary.defaultDelayedFireMinuteThreshold;

  /// Human-readable label for filter chips and saved preference summaries.
  String get label => switch (this) {
    FnbKitchenStationFilter.all => 'All',
    FnbKitchenStationFilter.pressure => 'Pressure',
    FnbKitchenStationFilter.delayed => 'Delayed',
    FnbKitchenStationFilter.calm => 'Calm',
  };

  /// Whether [station] belongs in this filter lens.
  bool includes(FnbKitchenStation station) {
    return switch (this) {
      FnbKitchenStationFilter.all => true,
      FnbKitchenStationFilter.pressure =>
        station.status != FnbServiceStatus.calm,
      FnbKitchenStationFilter.delayed =>
        station.averageFireMinutes >= delayedFireMinuteThreshold,
      FnbKitchenStationFilter.calm => station.status == FnbServiceStatus.calm,
    };
  }
}
