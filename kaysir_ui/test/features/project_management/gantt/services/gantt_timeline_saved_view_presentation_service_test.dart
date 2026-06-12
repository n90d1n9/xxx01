import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_saved_view_presentation_service.dart';

void main() {
  group('ganttTimelineSavedViewPresentation', () {
    test('describes every saved timeline view preset in order', () {
      expect(
        ganttTimelineSavedViewPresentations.map((item) => item.preset),
        orderedEquals(GanttTimelineViewPreset.values),
      );

      final all = ganttTimelineSavedViewPresentation(
        GanttTimelineViewPreset.all,
      );
      final active = ganttTimelineSavedViewPresentation(
        GanttTimelineViewPreset.activeNow,
      );
      final dependencyWatch = ganttTimelineSavedViewPresentation(
        GanttTimelineViewPreset.dependencyWatch,
      );
      final readyNext = ganttTimelineSavedViewPresentation(
        GanttTimelineViewPreset.readyNext,
      );

      expect(all.label, 'All Tasks');
      expect(all.icon, Icons.account_tree_outlined);
      expect(all.intentLabel, 'Complete schedule');
      expect(all.detail, contains('every task'));

      expect(active.label, 'Active Now');
      expect(active.icon, Icons.play_circle_outline_rounded);
      expect(active.intentLabel, 'In-flight work');
      expect(active.detail, contains('active today'));

      expect(dependencyWatch.label, 'Dependency Watch');
      expect(dependencyWatch.icon, Icons.link_rounded);
      expect(dependencyWatch.intentLabel, 'Dependency attention');
      expect(dependencyWatch.detail, contains('missing dependencies'));

      expect(readyNext.label, 'Ready Next');
      expect(readyNext.icon, Icons.next_plan_outlined);
      expect(readyNext.intentLabel, 'Ready starts');
      expect(readyNext.detail, contains('clear dependencies'));
    });
  });
}
