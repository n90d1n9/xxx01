import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_milestone_timeline_service.dart';

void main() {
  test('project milestone timeline summarizes due states and ordering', () {
    final summary = buildProjectMilestoneTimelineSummary(
      today: DateTime(2026, 5, 31),
      milestones: [
        ProjectMilestone(
          label: 'Done Audit',
          dueDate: DateTime(2026, 5, 12),
          isComplete: true,
        ),
        ProjectMilestone(
          label: 'Contract',
          dueDate: DateTime(2026, 5, 28),
          isComplete: false,
        ),
        ProjectMilestone(
          label: 'Pilot',
          dueDate: DateTime(2026, 6, 3),
          isComplete: false,
        ),
        ProjectMilestone(
          label: 'Rollout',
          dueDate: DateTime(2026, 7, 15),
          isComplete: false,
        ),
      ],
    );

    expect(summary.totalCount, 4);
    expect(summary.openCount, 3);
    expect(summary.doneCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.signalState, ProjectMilestoneTimelineState.overdue);
    expect(summary.nextOpenItem?.label, 'Contract');
    expect(summary.nextOpenItem?.dueLabel, '3d overdue');
    expect(summary.items.map((item) => item.label), [
      'Contract',
      'Pilot',
      'Rollout',
      'Done Audit',
    ]);
  });
}
