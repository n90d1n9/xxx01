import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_view_profile_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_view_profile_service.dart';

void main() {
  group('ganttChartViewProfilePresentation', () {
    test('describes coordinated view profiles', () {
      final planner = ganttChartViewProfilePresentation(
        GanttChartViewProfile.planner,
      );
      final team = ganttChartViewProfilePresentation(
        GanttChartViewProfile.team,
      );
      final review = ganttChartViewProfilePresentation(
        GanttChartViewProfile.review,
      );

      expect(planner.label, 'Plan');
      expect(planner.icon, Icons.edit_calendar_outlined);
      expect(planner.isPreset, isTrue);
      expect(team.summaryLabel, 'Team highlights ownership');
      expect(review.tooltip, contains('inspection'));
      expect(ganttChartViewProfileSettingsSubtitle(), contains('Team'));
    });

    test('shows custom only when the current profile is custom', () {
      expect(
        ganttChartViewProfilePresentationsFor(
          GanttChartViewProfile.planner,
        ).map((presentation) => presentation.profile),
        isNot(contains(GanttChartViewProfile.custom)),
      );
      expect(
        ganttChartViewProfilePresentationsFor(
          GanttChartViewProfile.custom,
        ).map((presentation) => presentation.profile),
        contains(GanttChartViewProfile.custom),
      );
    });
  });
}
