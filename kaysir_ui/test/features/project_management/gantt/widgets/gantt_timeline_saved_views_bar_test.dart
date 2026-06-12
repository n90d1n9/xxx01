import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_saved_views_bar.dart';

void main() {
  testWidgets(
    'gantt timeline saved view bar renders counts and changes value',
    (tester) async {
      var selected = GanttTimelineViewPreset.all;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GanttTimelineSavedViewsBar(
              tasks: [_activeTask()],
              value: selected,
              today: DateTime(2026, 5, 31),
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );

      expect(find.text('All Tasks'), findsOneWidget);
      expect(find.text('Active Now'), findsOneWidget);
      expect(find.text('Dependency Watch'), findsOneWidget);
      expect(
        find.byTooltip(
          'Complete schedule - All Tasks: 1 matching task. Shows every task '
          'in the current timeline scope.',
        ),
        findsOneWidget,
      );
      expect(
        find.byTooltip(
          'In-flight work - Active Now: 1 matching task. Shows tasks active '
          'today.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Active Now'));

      expect(selected, GanttTimelineViewPreset.activeNow);
    },
  );
}

gantt.GanttTask _activeTask() {
  return gantt.GanttTask(
    id: 'active',
    title: 'Active',
    startDate: DateTime(2026, 5, 28),
    endDate: DateTime(2026, 6, 5),
    progress: 0.5,
  );
}
