import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_viewport_navigator.dart';

void main() {
  testWidgets('gantt timeline viewport navigator renders visibility summary', (
    tester,
  ) async {
    GanttTimelineRangePreset? selectedPreset;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttTimelineViewportNavigator(
            rangePreset: GanttTimelineRangePreset.attentionWindow,
            visibleTaskCount: 3,
            totalTaskCount: 9,
            onPresetSelected: (preset) => selectedPreset = preset,
          ),
        ),
      ),
    );

    expect(find.text('Navigate timeline'), findsOneWidget);
    expect(
      find.text('Attention Window - 3 of 9 tasks visible'),
      findsOneWidget,
    );
    expect(find.text('Filtered'), findsOneWidget);
    expect(find.text('6 filtered out'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttTimelineViewportNavigator.fitAllButtonKey),
    );

    expect(selectedPreset, GanttTimelineRangePreset.projectSpan);
  });

  testWidgets('gantt timeline viewport navigator disables active preset', (
    tester,
  ) async {
    var selectedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttTimelineViewportNavigator(
            rangePreset: GanttTimelineRangePreset.planningWindow,
            visibleTaskCount: 4,
            totalTaskCount: 4,
            onPresetSelected: (_) => selectedCount++,
          ),
        ),
      ),
    );

    expect(find.text('All visible'), findsOneWidget);

    await tester.tap(find.byKey(GanttTimelineViewportNavigator.todayButtonKey));

    expect(selectedCount, 0);
  });
}
