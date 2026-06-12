import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_branch_focus_preview_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_health_service.dart';

void main() {
  const service = GanttBranchFocusPreviewService();

  group('GanttBranchFocusPreviewService', () {
    test('ranks descendant tasks by schedule attention', () {
      final branch = _branchTask();
      final preview = service.previewFor(branch, today: DateTime(2026, 1, 10));
      final dependencyPreview = service.previewFor(
        branch,
        today: DateTime(2026, 1, 10),
        lens: GanttBranchAttentionLens.dependency,
      );
      final items = preview.items;

      expect(items.map((item) => item.taskId), ['blocked', 'late', 'active']);
      expect(preview.totalItemCount, 7);
      expect(preview.hiddenItemCount, 4);
      expect(preview.hasHiddenItems, isTrue);
      expect(preview.hiddenItemCountLabel, '4 more in branch');
      expect(preview.hasDependencySummary, isTrue);
      expect(preview.dependencyAlertCount, 1);
      expect(preview.waitingDependencyCount, 1);
      expect(preview.dependencyAlertCountLabel, '1 dependency risk');
      expect(preview.waitingDependencyCountLabel, '1 waiting dep');
      expect(items.first.dependencyHealth, GanttDependencyHealth.blocked);
      expect(
        items.first.dependencyDetail,
        'Late Work is incomplete and now blocks this task.',
      );
      expect(items.first.hasDependencyAttention, isTrue);
      expect(items[1].health, GanttScheduleHealth.overdue);
      expect(items[1].scheduleDetail, '5 days overdue');
      expect(items[1].progressLabel, '20%');
      expect(items[2].health, GanttScheduleHealth.active);
      expect(items[2].scheduleDetail, '2 days remaining');
      expect(dependencyPreview.items.map((item) => item.taskId), [
        'blocked',
        'waiting',
      ]);
      expect(dependencyPreview.totalItemCount, 2);
      expect(dependencyPreview.hasHiddenItems, isFalse);
      expect(dependencyPreview.dependencyAlertCount, 1);
      expect(dependencyPreview.waitingDependencyCount, 1);
    });

    test('returns no items for leaf branches or disabled item count', () {
      final task = gantt.GanttTask(
        id: 'leaf',
        title: 'Leaf',
        startDate: DateTime(2026, 1),
        endDate: DateTime(2026, 1, 2),
      );
      final parent = gantt.GanttTask(
        id: 'parent',
        title: 'Parent',
        startDate: DateTime(2026, 1),
        endDate: DateTime(2026, 1, 3),
        subtasks: [task],
      );

      expect(service.itemsFor(task), isEmpty);
      expect(service.previewFor(task).totalItemCount, 0);
      expect(service.itemsFor(parent, maxItems: 0), isEmpty);
      expect(service.previewFor(parent, maxItems: 0).hasHiddenItems, isFalse);
    });
  });
}

gantt.GanttTask _branchTask() {
  return gantt.GanttTask(
    id: 'parent',
    title: 'Parent Work',
    startDate: DateTime(2026, 1),
    endDate: DateTime(2026, 1, 20),
    progress: 0.5,
    subtasks: [
      gantt.GanttTask(
        id: 'scheduled',
        title: 'Scheduled Work',
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 2, 4),
      ),
      gantt.GanttTask(
        id: 'active',
        title: 'Active Work',
        startDate: DateTime(2026, 1, 8),
        endDate: DateTime(2026, 1, 12),
        progress: 0.4,
      ),
      gantt.GanttTask(
        id: 'complete',
        title: 'Complete Work',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
        progress: 1,
      ),
      gantt.GanttTask(
        id: 'late',
        title: 'Late Work',
        startDate: DateTime(2026, 1, 3),
        endDate: DateTime(2026, 1, 5),
        progress: 0.2,
      ),
      gantt.GanttTask(
        id: 'soon',
        title: 'Soon Work',
        startDate: DateTime(2026, 1, 12),
        endDate: DateTime(2026, 1, 14),
        progress: 0.1,
      ),
      gantt.GanttTask(
        id: 'blocked',
        title: 'Blocked Work',
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 2, 4),
        dependsOn: 'late',
      ),
      gantt.GanttTask(
        id: 'waiting',
        title: 'Waiting Work',
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 2, 6),
        dependsOn: 'active',
      ),
    ],
  );
}
