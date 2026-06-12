import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('menu signal summary and filters group availability signals', () {
    final summary = FnbMenuSignalSummary.fromSignals(_signals);

    expect(summary.totalCount, 3);
    expect(summary.riskCount, 1);
    expect(summary.highMarginCount, 2);
    expect(summary.quickPrepCount, 2);
    expect(summary.restockedCount, 1);
    expect(summary.averageMarginPercent, 67);
    expect(summary.riskLabel, '1 at risk');
    expect(_signals.where(FnbMenuSignalFilter.risk.includes), hasLength(1));
    expect(_signals.where(FnbMenuSignalFilter.margin.includes), hasLength(2));
    expect(_signals.where(FnbMenuSignalFilter.quick.includes), hasLength(2));
    expect(
      _signals.where(FnbMenuSignalFilter.restocked.includes),
      hasLength(1),
    );
  });

  test('menu signal sort ranks signals for operating decisions', () {
    expect(
      sortFnbMenuSignals(
        _sortSignals,
        FnbMenuSignalSort.demand,
      ).map((signal) => signal.id),
      ['demand', 'slow-risk', 'fast-margin'],
    );
    expect(
      sortFnbMenuSignals(
        _sortSignals,
        FnbMenuSignalSort.risk,
      ).map((signal) => signal.id),
      ['slow-risk', 'demand', 'fast-margin'],
    );
    expect(
      sortFnbMenuSignals(
        _sortSignals,
        FnbMenuSignalSort.margin,
      ).map((signal) => signal.id),
      ['fast-margin', 'demand', 'slow-risk'],
    );
    expect(
      sortFnbMenuSignals(
        _sortSignals,
        FnbMenuSignalSort.prep,
      ).map((signal) => signal.id),
      ['fast-margin', 'demand', 'slow-risk'],
    );
  });

  test('menu signal copyWith keeps identity and updates operating fields', () {
    final updated = _signals.first.copyWith(
      soldOutRiskPercent: 20,
      tags: const ['Restocked'],
    );

    expect(updated.id, 'risk');
    expect(updated.name, 'Short Rib Rendang');
    expect(updated.soldOutRiskPercent, 20);
    expect(updated.tags, ['Restocked']);
  });
}

const _signals = [
  FnbMenuSignal(
    id: 'risk',
    name: 'Short Rib Rendang',
    category: 'Main',
    orders: 32,
    grossMarginPercent: 71,
    soldOutRiskPercent: 78,
    prepMinutes: 18,
    tags: ['Low stock'],
  ),
  FnbMenuSignal(
    id: 'quick',
    name: 'Pandan Spritz',
    category: 'Beverage',
    orders: 24,
    grossMarginPercent: 68,
    soldOutRiskPercent: 18,
    prepMinutes: 5,
    tags: ['Fast'],
  ),
  FnbMenuSignal(
    id: 'restocked',
    name: 'Burnt Cheesecake',
    category: 'Dessert',
    orders: 18,
    grossMarginPercent: 62,
    soldOutRiskPercent: 12,
    prepMinutes: 7,
    tags: ['Restocked'],
  ),
];

const _sortSignals = [
  FnbMenuSignal(
    id: 'slow-risk',
    name: 'Slow Risk',
    category: 'Main',
    orders: 12,
    grossMarginPercent: 61,
    soldOutRiskPercent: 88,
    prepMinutes: 18,
    tags: [],
  ),
  FnbMenuSignal(
    id: 'fast-margin',
    name: 'Fast Margin',
    category: 'Dessert',
    orders: 10,
    grossMarginPercent: 72,
    soldOutRiskPercent: 18,
    prepMinutes: 5,
    tags: [],
  ),
  FnbMenuSignal(
    id: 'demand',
    name: 'High Demand',
    category: 'Beverage',
    orders: 30,
    grossMarginPercent: 65,
    soldOutRiskPercent: 40,
    prepMinutes: 7,
    tags: [],
  ),
];
