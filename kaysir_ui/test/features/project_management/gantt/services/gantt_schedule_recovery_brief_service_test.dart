import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_focus_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_recovery_brief_service.dart';

void main() {
  test('gantt schedule recovery brief summarizes focus actions', () {
    final brief = buildGanttScheduleRecoveryBrief(
      tasks: [
        _task(
          id: 'late',
          title: 'Late Foundation',
          start: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 8),
          progress: 0.5,
          projectId: 'retail',
        ),
        _task(
          id: 'behind',
          title: 'Slow Fit Out',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.2,
          dependsOn: 'late',
        ),
      ],
      dependencyTasks: [
        _task(
          id: 'late',
          title: 'Late Foundation',
          start: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 8),
          progress: 0.5,
        ),
      ],
      projectNamesById: const {'retail': 'Retail Modernization'},
      scopeLabel: 'Retail roadmap',
      today: DateTime(2026, 5, 6),
    );

    expect(brief.title, 'Retail roadmap schedule recovery brief');
    expect(brief.summary.level, GanttScheduleFocusLevel.critical);
    expect(brief.focusItems, hasLength(2));
    expect(brief.dependencyImpactSummary.alertCount, 1);
    expect(brief.briefText, contains('Status: Critical'));
    expect(brief.briefText, contains('Late Foundation (Retail Modernization)'));
    expect(brief.briefText, contains('Recovery actions'));
    expect(brief.briefText, contains('Dependency impact'));
    expect(
      brief.briefText,
      contains('Late Foundation is incomplete and now blocks this task'),
    );
    expect(brief.briefText, contains('Overdue: 1'));
    expect(brief.briefText, contains('Behind baseline: 1'));
  });

  test('gantt schedule recovery brief reports clear schedules', () {
    final brief = buildGanttScheduleRecoveryBrief(
      tasks: [
        _task(
          id: 'steady',
          title: 'Steady Work',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.7,
        ),
      ],
      scopeLabel: '',
      today: DateTime(2026, 5, 6),
    );

    expect(brief.scopeLabel, 'Roadmap');
    expect(brief.summary.level, GanttScheduleFocusLevel.clear);
    expect(brief.briefText, contains('Status: Clear'));
    expect(brief.briefText, contains('Keep cadence'));
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  required double progress,
  String? projectId,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end,
    progress: progress,
    projectId: projectId,
    dependsOn: dependsOn,
  );
}
