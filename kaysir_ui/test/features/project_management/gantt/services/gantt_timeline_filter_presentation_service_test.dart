import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_filter_presentation_service.dart';

void main() {
  group('ganttTimelineFilterPresentation', () {
    test('describes filter fields in control order', () {
      expect(ganttTimelineFilterFieldPresentations.map((item) => item.role), [
        GanttTimelineFilterFieldRole.search,
        GanttTimelineFilterFieldRole.project,
        GanttTimelineFilterFieldRole.status,
        GanttTimelineFilterFieldRole.view,
        GanttTimelineFilterFieldRole.range,
      ]);

      final search = ganttTimelineFilterFieldPresentation(
        GanttTimelineFilterFieldRole.search,
      );
      final project = ganttTimelineFilterFieldPresentation(
        GanttTimelineFilterFieldRole.project,
      );
      final status = ganttTimelineFilterFieldPresentation(
        GanttTimelineFilterFieldRole.status,
      );
      final view = ganttTimelineFilterFieldPresentation(
        GanttTimelineFilterFieldRole.view,
      );
      final range = ganttTimelineFilterFieldPresentation(
        GanttTimelineFilterFieldRole.range,
      );

      expect(search.label, 'Search timeline tasks');
      expect(search.icon, Icons.search);
      expect(search.widthFor(compact: false), 280);
      expect(search.widthFor(compact: true), isNull);

      expect(project.label, 'Project');
      expect(project.icon, Icons.workspaces_outline);
      expect(project.expandedWidth, 230);

      expect(status.label, 'Status');
      expect(status.icon, Icons.filter_list_rounded);
      expect(status.expandedWidth, 190);

      expect(view.label, 'View');
      expect(view.icon, Icons.calendar_view_week_outlined);
      expect(view.expandedWidth, 170);

      expect(range.label, 'Range Preset');
      expect(range.icon, Icons.today_outlined);
      expect(range.expandedWidth, 210);
    });

    test('describes view mode labels and compact breakpoint', () {
      expect(ganttTimelineFilterUsesCompactLayout(759), isTrue);
      expect(ganttTimelineFilterUsesCompactLayout(760), isFalse);
      expect(
        ganttViewModePresentations.map((item) => item.mode),
        gantt.ViewMode.values,
      );
      expect(ganttViewModePresentation(gantt.ViewMode.day).label, 'Day');
      expect(ganttViewModePresentation(gantt.ViewMode.week).label, 'Week');
      expect(ganttViewModePresentation(gantt.ViewMode.month).label, 'Month');
      expect(
        ganttViewModePresentation(gantt.ViewMode.quarter).label,
        'Quarter',
      );
    });
  });
}
