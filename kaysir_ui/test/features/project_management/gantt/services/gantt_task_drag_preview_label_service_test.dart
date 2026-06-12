import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_task_drag_preview_label_service.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  test('gantt task drag preview labels summarize range edits', () {
    final preview = KyGanttTaskDragPreview(
      task: GanttTask(
        id: 'build',
        title: 'Build',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 14),
      ),
      startDate: DateTime(2026, 1, 8),
      endDate: DateTime(2026, 1, 21),
      deltaDays: 7,
      snap: KyGanttTaskDragSnap.week,
    );

    expect(ganttTaskDragPreviewTitle(preview), 'Move +7d');
    expect(ganttTaskDragPreviewOriginalDateRangeLabel(preview), 'Jan 1-14');
    expect(ganttTaskDragPreviewDateRangeLabel(preview), 'Jan 8-21');
    expect(
      ganttTaskDragPreviewRangeShiftLabel(preview),
      'Jan 1-14 to Jan 8-21',
    );
    expect(ganttTaskDragPreviewImpactLabel(preview), 'Moves later');
    expect(
      ganttTaskDragPreviewMetadataLabel(preview),
      'Jan 8-21 - 2w - Week snap',
    );
    expect(
      ganttTaskDragPreviewSummaryLabel(preview),
      'Move +7d, Jan 8-21, Moves later, 2w, Week snap, Ready',
    );
    expect(
      ganttTaskDragPreviewSummaryLabel(preview, includeImpact: false),
      'Move +7d, Jan 8-21, 2w, Week snap, Ready',
    );
  });

  test('gantt task drag preview labels summarize resize direction', () {
    final task = GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 1, 8),
      endDate: DateTime(2026, 1, 21),
    );

    expect(
      ganttTaskDragPreviewImpactLabel(
        KyGanttTaskDragPreview(
          task: task,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 21),
          deltaDays: -7,
          action: KyGanttTaskRangePreviewAction.resizeStart,
        ),
      ),
      'Starts earlier',
    );
    expect(
      ganttTaskDragPreviewImpactLabel(
        KyGanttTaskDragPreview(
          task: task,
          startDate: DateTime(2026, 1, 8),
          endDate: DateTime(2026, 1, 28),
          deltaDays: 7,
          action: KyGanttTaskRangePreviewAction.resizeEnd,
        ),
      ),
      'Finishes later',
    );
  });

  test('gantt task drag preview labels summarize validation state', () {
    expect(
      ganttTaskDragPreviewValidationTitle(
        const KyGanttTaskDateRangeValidation.valid(),
      ),
      'Ready',
    );
    expect(
      ganttTaskDragPreviewValidationTitle(
        const KyGanttTaskDateRangeValidation.warning('Check dependency'),
      ),
      'Check',
    );
    expect(
      ganttTaskDragPreviewValidationTitle(
        const KyGanttTaskDateRangeValidation.blocked('Would overlap Testing'),
      ),
      'Blocked',
    );
    expect(
      ganttTaskDragPreviewSummaryLabel(
        KyGanttTaskDragPreview(
          task: GanttTask(
            id: 'build',
            title: 'Build',
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 1, 14),
          ),
          startDate: DateTime(2026, 1, 8),
          endDate: DateTime(2026, 1, 21),
          deltaDays: 7,
          snap: KyGanttTaskDragSnap.week,
          validation: const KyGanttTaskDateRangeValidation.blocked(
            'Would overlap Testing',
          ),
        ),
      ),
      'Move +7d, Jan 8-21, Moves later, 2w, Week snap, Blocked, Would overlap Testing',
    );
  });
}
