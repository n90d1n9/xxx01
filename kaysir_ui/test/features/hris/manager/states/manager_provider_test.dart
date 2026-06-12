import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/manager/states/manager_provider.dart';

void main() {
  test('manager summary rolls up team health and approvals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(managerSelfServiceSummaryProvider);

    expect(summary.teamMemberCount, 5);
    expect(summary.availableCount, 2);
    expect(summary.pendingApprovalCount, 4);
    expect(summary.highPriorityApprovals, 2);
    expect(summary.averageCapacity, 65);
    expect(summary.teamHealthScore, 86);
    expect(summary.attentionCount, 5);
  });

  test('manager summary reacts to selected team scope', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(managerSelectedTeamProvider.notifier).state = 'Engineering';

    final summary = container.read(managerSelfServiceSummaryProvider);

    expect(summary.teamMemberCount, 2);
    expect(summary.availableCount, 0);
    expect(summary.pendingApprovalCount, 2);
    expect(summary.highPriorityApprovals, 1);
    expect(summary.averageCapacity, 46);
    expect(summary.attentionCount, 3);
  });

  test('attention view keeps urgent requests and watched team members', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(managerAttentionOnlyProvider.notifier).state = true;

    expect(container.read(filteredTeamMembersProvider), hasLength(3));
    expect(container.read(filteredPendingRequestsProvider), hasLength(2));
    expect(container.read(managerSelfServiceSummaryProvider).attentionCount, 5);
  });

  test('manager risk summary aggregates urgent leadership signals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final risks = container.read(managerRiskSummaryProvider);

    expect(risks.busyMembers, 2);
    expect(risks.onLeaveMembers, 1);
    expect(risks.highCapacityMembers, 1);
    expect(risks.lowPerformanceMembers, 1);
    expect(risks.urgentPendingRequests, 2);
    expect(risks.stalePendingRequests, 3);
    expect(risks.totalRisks, 10);
  });

  test('manager date override drives pending request timestamps', () {
    final container = ProviderContainer(
      overrides: [
        managerAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10, 12)),
      ],
    );
    addTearDown(container.dispose);

    final requests = container.read(pendingRequestsProvider);

    expect(requests.first.requestDate, DateTime(2026, 7, 8, 9, 30));
    expect(requests[2].requestDate, DateTime(2026, 7, 9, 11));
  });
}
