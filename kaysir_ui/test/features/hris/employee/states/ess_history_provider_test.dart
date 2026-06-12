import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/ess_history_models.dart';
import 'package:kaysir/features/hris/employee/states/ess_provider.dart';

void main() {
  test('pay history summary aggregates pay stubs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(payHistorySummaryProvider);
    final breakdowns = container.read(payStubBreakdownsProvider);

    expect(summary.stubCount, 3);
    expect(summary.totalGrossPay, 10500);
    expect(summary.totalNetPay, 8400);
    expect(summary.totalDeductions, 2100);
    expect(summary.averageNetPay, 2800);
    expect(summary.latestPayDate, DateTime(2025, 3, 20));
    expect(breakdowns.first.stub.id, 'PS003');
    expect(breakdowns.first.deductions.length, 6);
    expect(
      breakdowns.first.deductions.fold<double>(
        0,
        (total, line) => total + line.amount,
      ),
      closeTo(700, 0.01),
    );
  });

  test('time off history summary aggregates request status and days', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(timeOffHistorySummaryProvider);

    expect(summary.requestCount, 2);
    expect(summary.pendingCount, 1);
    expect(summary.approvedCount, 1);
    expect(summary.rejectedCount, 0);
    expect(summary.totalRequestedDays, 7);
    expect(summary.approvedDays, 6);
    expect(summary.nextPendingDate, DateTime(2025, 5, 22));
  });

  test('time off history filter narrows and sorts requests', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedTimeOffHistoryFilterProvider.notifier).state =
        TimeOffHistoryFilter.pending;

    final requests = container.read(filteredTimeOffRequestsProvider);

    expect(requests, hasLength(1));
    expect(requests.single.id, 'TOR002');
    expect(requests.single.status, 'Pending');
  });
}
