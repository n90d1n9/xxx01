import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';

void main() {
  const service = GanttTimelineRangePresetService();

  group('GanttTimelineRangePresetService', () {
    test(
      'keeps the planning window aligned with the default timeline range',
      () {
        final range = service.rangeFor(
          preset: GanttTimelineRangePreset.planningWindow,
          tasks: const [],
          today: DateTime(2026, 6, 1, 14, 30),
        );

        expect(range.start, DateTime(2026, 5, 25));
        expect(range.end, DateTime(2026, 7, 1));
      },
    );

    test('resolves the current month boundaries', () {
      final range = service.rangeFor(
        preset: GanttTimelineRangePreset.currentMonth,
        tasks: const [],
        today: DateTime(2026, 2, 12),
      );

      expect(range.start, DateTime(2026, 2));
      expect(range.end, DateTime(2026, 2, 28));
    });

    test('resolves a ninety day planning horizon', () {
      final range = service.rangeFor(
        preset: GanttTimelineRangePreset.nextNinetyDays,
        tasks: const [],
        today: DateTime(2026, 6, 1),
      );

      expect(range.start, DateTime(2026, 6, 1));
      expect(range.end, DateTime(2026, 8, 30));
    });

    test('fits overdue active and upcoming attention work', () {
      final range = service.rangeFor(
        preset: GanttTimelineRangePreset.attentionWindow,
        tasks: [
          _task(
            'complete',
            DateTime(2026, 5, 1),
            DateTime(2026, 5, 3),
            progress: 1,
          ),
          _task('overdue', DateTime(2026, 5, 22), DateTime(2026, 5, 28)),
          _task('active', DateTime(2026, 5, 30), DateTime(2026, 6, 5)),
          _task('upcoming', DateTime(2026, 6, 12), DateTime(2026, 6, 18)),
          _task('later', DateTime(2026, 7, 1), DateTime(2026, 7, 8)),
        ],
        today: DateTime(2026, 6, 1),
      );

      expect(range.start, DateTime(2026, 5, 20));
      expect(range.end, DateTime(2026, 6, 20));
    });

    test('falls back to the planning window when attention work is empty', () {
      final range = service.rangeFor(
        preset: GanttTimelineRangePreset.attentionWindow,
        tasks: [
          _task(
            'complete',
            DateTime(2026, 5, 1),
            DateTime(2026, 5, 3),
            progress: 1,
          ),
          _task('later', DateTime(2026, 7, 1), DateTime(2026, 7, 8)),
        ],
        today: DateTime(2026, 6, 1),
      );

      expect(range.start, DateTime(2026, 5, 25));
      expect(range.end, DateTime(2026, 7, 1));
    });

    test('summarizes preset task counts for option labels', () {
      final summaries = service.summariesFor(
        tasks: [
          _task(
            'complete',
            DateTime(2026, 5, 1),
            DateTime(2026, 5, 3),
            progress: 1,
          ),
          _task('overdue', DateTime(2026, 5, 22), DateTime(2026, 5, 28)),
          _task('active', DateTime(2026, 5, 30), DateTime(2026, 6, 5)),
          _task('upcoming', DateTime(2026, 6, 12), DateTime(2026, 6, 18)),
          _task('later', DateTime(2026, 7, 1), DateTime(2026, 7, 8)),
        ],
        today: DateTime(2026, 6, 1),
      );

      final summariesByPreset = {
        for (final summary in summaries) summary.preset: summary,
      };

      expect(
        summariesByPreset[GanttTimelineRangePreset.planningWindow]?.taskCount,
        4,
      );
      expect(
        summariesByPreset[GanttTimelineRangePreset.currentMonth]?.taskCount,
        2,
      );
      expect(
        summariesByPreset[GanttTimelineRangePreset.attentionWindow]?.taskCount,
        3,
      );
      expect(
        summariesByPreset[GanttTimelineRangePreset.nextNinetyDays]?.taskCount,
        3,
      );
      expect(
        summariesByPreset[GanttTimelineRangePreset.projectSpan]?.taskCount,
        5,
      );
      expect(
        summariesByPreset[GanttTimelineRangePreset.attentionWindow]
            ?.optionLabel,
        'Attention Window (3 tasks)',
      );
    });

    test('fits the complete flattened task span with padding', () {
      final range = service.rangeFor(
        preset: GanttTimelineRangePreset.projectSpan,
        tasks: [
          _task(
            'parent',
            DateTime(2026, 2, 10),
            DateTime(2026, 2, 20),
            subtasks: [
              _task('child', DateTime(2026, 1, 5), DateTime(2026, 1, 12)),
            ],
          ),
          _task('late', DateTime(2026, 3, 4), DateTime(2026, 3, 9)),
        ],
        today: DateTime(2026, 6, 1),
      );

      expect(range.start, DateTime(2026, 1, 2));
      expect(range.end, DateTime(2026, 3, 12));
    });

    test('falls back to the planning window when project span is empty', () {
      final range = service.rangeFor(
        preset: GanttTimelineRangePreset.projectSpan,
        tasks: const [],
        today: DateTime(2026, 6, 1),
      );

      expect(range.start, DateTime(2026, 5, 25));
      expect(range.end, DateTime(2026, 7, 1));
    });
  });
}

gantt.GanttTask _task(
  String id,
  DateTime startDate,
  DateTime endDate, {
  List<gantt.GanttTask> subtasks = const [],
  double progress = 0,
}) {
  return gantt.GanttTask(
    id: id,
    title: id,
    startDate: startDate,
    endDate: endDate,
    progress: progress,
    color: Colors.blue,
    subtasks: subtasks,
  );
}
