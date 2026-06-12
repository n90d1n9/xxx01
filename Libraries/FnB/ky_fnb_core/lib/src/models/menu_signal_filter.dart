import 'menu_signal.dart';

/// Selects menu signals by operating risk, margin, prep speed, or restock state.
enum FnbMenuSignalFilter {
  all,
  risk,
  margin,
  quick,
  restocked;

  String get label => switch (this) {
    FnbMenuSignalFilter.all => 'All',
    FnbMenuSignalFilter.risk => 'Risk',
    FnbMenuSignalFilter.margin => 'Margin',
    FnbMenuSignalFilter.quick => 'Quick',
    FnbMenuSignalFilter.restocked => 'Restocked',
  };

  bool includes(FnbMenuSignal signal) {
    return switch (this) {
      FnbMenuSignalFilter.all => true,
      FnbMenuSignalFilter.risk => signal.soldOutRiskPercent >= 50,
      FnbMenuSignalFilter.margin => signal.grossMarginPercent >= 65,
      FnbMenuSignalFilter.quick => signal.prepMinutes <= 8,
      FnbMenuSignalFilter.restocked => signal.tags.contains('Restocked'),
    };
  }
}
