import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_branch_focus_summary_service.dart';

void main() {
  const service = GanttBranchFocusSummaryService();

  group('GanttBranchFocusSummaryService', () {
    test('summarizes branch task count progress dates and risks', () {
      final summary =
          service.summaryFor(
            gantt.GanttTask(
              id: 'parent',
              title: 'Parent Work',
              startDate: DateTime(2026, 1),
              endDate: DateTime(2026, 1, 10),
              progress: 0.5,
              subtasks: [
                gantt.GanttTask(
                  id: 'complete',
                  title: 'Complete Work',
                  startDate: DateTime(2026, 1),
                  endDate: DateTime(2026, 1, 2),
                  progress: 1,
                ),
                gantt.GanttTask(
                  id: 'late',
                  title: 'Late Work',
                  startDate: DateTime(2026, 1, 3),
                  endDate: DateTime(2026, 1, 4),
                  progress: 0.4,
                ),
              ],
            ),
            today: DateTime(2026, 1, 6),
          )!;

      expect(summary.taskId, 'parent');
      expect(summary.title, 'Parent Work');
      expect(summary.taskCount, 3);
      expect(summary.completedTaskCount, 1);
      expect(summary.riskTaskCount, 1);
      expect(summary.taskCountLabel, '3 tasks');
      expect(summary.completedLabel, '1 done');
      expect(summary.progressLabel, '63% avg');
      expect(summary.riskLabel, '1 risk');
      expect(summary.dateRangeLabel, 'Jan 1-10');
    });

    test('returns null when no branch is focused', () {
      expect(service.summaryFor(null), isNull);
    });
  });
}
