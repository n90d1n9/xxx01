import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_control_header_presentation_service.dart';

void main() {
  group('GanttChartControlHeaderPresentationService', () {
    const service = GanttChartControlHeaderPresentationService();

    test('builds concise header copy for same-month ranges', () {
      final presentation = service.presentationFor(
        dateRange: DateTimeRange(
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 30),
        ),
      );

      expect(presentation.eyebrow, 'Timeline Planning');
      expect(presentation.title, 'Full Gantt Chart');
      expect(presentation.dateRangeLabel, 'May 1-30');
      expect(
        presentation.subtitle,
        'Interactive schedule canvas for May 1-30.',
      );
    });

    test('formats cross-month and cross-year ranges', () {
      expect(
        service.dateRangeLabelFor(
          DateTimeRange(
            start: DateTime(2026, 5, 28),
            end: DateTime(2026, 6, 4),
          ),
        ),
        'May 28 - Jun 4',
      );
      expect(
        service.dateRangeLabelFor(
          DateTimeRange(
            start: DateTime(2026, 12, 28),
            end: DateTime(2027, 1, 4),
          ),
        ),
        'Dec 28, 2026 - Jan 4, 2027',
      );
    });
  });
}
