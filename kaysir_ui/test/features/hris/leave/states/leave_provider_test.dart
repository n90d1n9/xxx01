import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/leave/models/leave_request.dart';
import 'package:kaysir/features/hris/leave/states/leave_provider.dart';

void main() {
  test('leave summary aggregates balance and request states', () {
    final container = ProviderContainer(
      overrides: [
        leaveAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(leaveSummaryProvider);

    expect(summary.balanceDays, 15);
    expect(summary.pendingCount, 1);
    expect(summary.approvedCount, 1);
    expect(summary.rejectedCount, 0);
    expect(summary.pendingDays, 3);
    expect(summary.approvedDays, 2);
    expect(summary.remainingBalance, 13);
  });

  test('leave request notifier supports add update and delete', () {
    final container = ProviderContainer(
      overrides: [
        leaveAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final request = LeaveRequest(
      id: 'test-001',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 3),
      reason: 'Family event',
      status: LeaveStatus.pending,
      leaveType: 'Personal Leave',
    );

    container.read(leaveRequestsProvider.notifier).addLeaveRequest(request);
    expect(container.read(leaveSummaryProvider).pendingCount, 2);
    expect(container.read(leaveSummaryProvider).pendingDays, 6);

    container
        .read(leaveRequestsProvider.notifier)
        .updateLeaveRequest(
          LeaveRequest(
            id: request.id,
            startDate: request.startDate,
            endDate: request.endDate,
            reason: request.reason,
            status: LeaveStatus.rejected,
            leaveType: request.leaveType,
          ),
        );
    expect(container.read(leaveSummaryProvider).pendingCount, 1);
    expect(container.read(leaveSummaryProvider).rejectedCount, 1);

    container
        .read(leaveRequestsProvider.notifier)
        .deleteLeaveRequest(request.id);
    expect(container.read(leaveRequestsProvider).map((item) => item.id), [
      '1',
      '2',
    ]);
  });

  test(
    'leave risk summary highlights upcoming requests and balance pressure',
    () {
      final container = ProviderContainer(
        overrides: [
          leaveAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
        ],
      );
      addTearDown(container.dispose);

      final risks = container.read(leaveRiskSummaryProvider);

      expect(risks.pendingRequests, 1);
      expect(risks.pendingDays, 3);
      expect(risks.upcomingPendingRequests, 1);
      expect(risks.approvedDays, 2);
      expect(risks.projectedRemainingBalance, 10);
      expect(risks.balancePressureDays, 0);
      expect(risks.totalRisks, 2);
    },
  );

  test('leave date override drives seeded request dates', () {
    final container = ProviderContainer(
      overrides: [
        leaveAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final requests = container.read(leaveRequestsProvider);

    expect(requests.first.startDate, DateTime(2026, 7, 15));
    expect(requests.first.endDate, DateTime(2026, 7, 17));
    expect(requests[1].startDate, DateTime(2026, 7, 25));
  });
}
