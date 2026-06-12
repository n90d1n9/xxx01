import 'menu_signal.dart';

/// Aggregates live menu signal counts for operating dashboards and controls.
class FnbMenuSignalSummary {
  const FnbMenuSignalSummary({
    required this.totalCount,
    required this.riskCount,
    required this.highMarginCount,
    required this.quickPrepCount,
    required this.restockedCount,
    required this.averageMarginPercent,
  });

  factory FnbMenuSignalSummary.fromSignals(List<FnbMenuSignal> signals) {
    var riskCount = 0;
    var highMarginCount = 0;
    var quickPrepCount = 0;
    var restockedCount = 0;
    var marginTotal = 0;

    for (final signal in signals) {
      if (signal.soldOutRiskPercent >= 50) riskCount += 1;
      if (signal.grossMarginPercent >= 65) highMarginCount += 1;
      if (signal.prepMinutes <= 8) quickPrepCount += 1;
      if (signal.tags.contains('Restocked')) restockedCount += 1;
      marginTotal += signal.grossMarginPercent;
    }

    return FnbMenuSignalSummary(
      totalCount: signals.length,
      riskCount: riskCount,
      highMarginCount: highMarginCount,
      quickPrepCount: quickPrepCount,
      restockedCount: restockedCount,
      averageMarginPercent: signals.isEmpty
          ? 0
          : (marginTotal / signals.length).round(),
    );
  }

  final int totalCount;
  final int riskCount;
  final int highMarginCount;
  final int quickPrepCount;
  final int restockedCount;
  final int averageMarginPercent;

  double get riskRate {
    if (totalCount == 0) return 0;
    return riskCount / totalCount;
  }

  String get riskLabel => riskCount == 1 ? '1 at risk' : '$riskCount at risk';
}
