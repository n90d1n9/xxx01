import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_sla_tracker_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision SLA tracker groups open records by due-date lane', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    final tracker = workspace.decisionSlaTrackerSummary;
    final bucketedCount =
        tracker.overdueCount +
        tracker.dueTodayCount +
        tracker.dueSoonCount +
        tracker.onTrackCount +
        tracker.unscheduledCount;

    expect(tracker.openCount, workspace.decisionRegisterSummary.openCount);
    expect(bucketedCount, tracker.openCount);
    expect(tracker.bucketCount, greaterThan(0));
    expect(tracker.primaryBucket, isNotNull);
    expect(ProjectDecisionSlaSignal.values, contains(tracker.signal));
    expect(tracker.primaryBucket!.items, isNotEmpty);
    expect(tracker.briefText, contains('decision SLA tracker'));
    expect(tracker.briefText, contains('SLA lanes:'));
  });
}
