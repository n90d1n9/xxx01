import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/states/ess_provider.dart';

void main() {
  test('ESS summary aggregates pay stubs and time-off requests', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(employeeSelfServiceSummaryProvider);

    expect(summary.payStubCount, 3);
    expect(summary.totalGrossPay, 10500);
    expect(summary.totalNetPay, 8400);
    expect(summary.latestNetPay, 2800);
    expect(summary.timeOffRequestCount, 2);
    expect(summary.pendingTimeOffCount, 1);
    expect(summary.approvedTimeOffDays, 6);
  });

  test('ESS summary reacts to payment and time-off overrides', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(payStubsProvider.notifier).state = [];
    container.read(timeOffRequestsProvider.notifier).state = [];

    final summary = container.read(employeeSelfServiceSummaryProvider);

    expect(summary.payStubCount, 0);
    expect(summary.latestNetPay, 0);
    expect(summary.timeOffRequestCount, 0);
    expect(summary.approvedTimeOffDays, 0);
  });

  test('ESS risk summary highlights pay and time-off actions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final risks = container.read(employeeSelfServiceRiskSummaryProvider);

    expect(risks.pendingTimeOffRequests, 1);
    expect(risks.pendingTimeOffDays, 1);
    expect(risks.lowBalanceTypes, 2);
    expect(risks.highDeductionPayStubs, 3);
    expect(risks.totalAvailableTimeOffDays, 25);
    expect(risks.totalAlerts, 6);
  });
}
