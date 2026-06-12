import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_layer_toggle_presentation_service.dart';

void main() {
  group('ganttChartLayerTogglePresentation', () {
    test('describes chart layer toggles in strip order', () {
      expect(ganttChartLayerTogglePresentations.map((item) => item.role), [
        GanttChartLayerToggleRole.teamAvatars,
        GanttChartLayerToggleRole.dependencyLines,
        GanttChartLayerToggleRole.dependencyFocus,
        GanttChartLayerToggleRole.weekendBands,
        GanttChartLayerToggleRole.todayMarker,
      ]);

      final team = ganttChartLayerTogglePresentation(
        GanttChartLayerToggleRole.teamAvatars,
      );
      final links = ganttChartLayerTogglePresentation(
        GanttChartLayerToggleRole.dependencyLines,
      );
      final focus = ganttChartLayerTogglePresentation(
        GanttChartLayerToggleRole.dependencyFocus,
      );
      final today = ganttChartLayerTogglePresentation(
        GanttChartLayerToggleRole.todayMarker,
      );

      expect(team.key, ganttChartLayerTeamAvatarsChipKey);
      expect(team.label, 'Team');
      expect(team.summaryLabel, 'Team avatars');
      expect(team.icon, Icons.groups_2_outlined);
      expect(team.countsAsLayer, isTrue);

      expect(links.key, ganttChartLayerDependencyLinesChipKey);
      expect(links.label, 'Links');
      expect(links.summaryLabel, 'Dependency lines');
      expect(links.icon, Icons.account_tree_outlined);
      expect(links.countsAsLayer, isTrue);

      expect(focus.key, ganttChartLayerDependencyFocusChipKey);
      expect(focus.label, 'Focus');
      expect(focus.summaryLabel, 'Dependency focus');
      expect(focus.icon, Icons.hub_outlined);
      expect(focus.countsAsLayer, isFalse);

      expect(today.key, ganttChartLayerTodayMarkerChipKey);
      expect(today.label, 'Today');
      expect(today.summaryLabel, 'Today marker');
      expect(today.icon, Icons.today_outlined);
      expect(today.countsAsLayer, isTrue);
    });
  });
}
