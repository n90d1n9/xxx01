import 'menu_signal.dart';

/// Defines menu signal ordering for a selected operating lens.
enum FnbMenuSignalSort {
  demand,
  risk,
  margin,
  prep;

  String get label => switch (this) {
    FnbMenuSignalSort.demand => 'Demand',
    FnbMenuSignalSort.risk => 'Risk',
    FnbMenuSignalSort.margin => 'Margin',
    FnbMenuSignalSort.prep => 'Prep',
  };

  String get description => switch (this) {
    FnbMenuSignalSort.demand => 'Orders high to low',
    FnbMenuSignalSort.risk => 'Sell-out risk high to low',
    FnbMenuSignalSort.margin => 'Margin high to low',
    FnbMenuSignalSort.prep => 'Prep time low to high',
  };
}

/// Returns menu signals ordered by the requested operating sort.
List<FnbMenuSignal> sortFnbMenuSignals(
  Iterable<FnbMenuSignal> signals,
  FnbMenuSignalSort sort,
) {
  final sorted = signals.toList(growable: false);
  sorted.sort((a, b) {
    final result = switch (sort) {
      FnbMenuSignalSort.demand => b.orders.compareTo(a.orders),
      FnbMenuSignalSort.risk => b.soldOutRiskPercent.compareTo(
        a.soldOutRiskPercent,
      ),
      FnbMenuSignalSort.margin => b.grossMarginPercent.compareTo(
        a.grossMarginPercent,
      ),
      FnbMenuSignalSort.prep => a.prepMinutes.compareTo(b.prepMinutes),
    };
    if (result != 0) return result;
    return b.orders.compareTo(a.orders);
  });
  return sorted;
}
