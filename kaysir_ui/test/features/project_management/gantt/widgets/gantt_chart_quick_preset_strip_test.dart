import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_quick_preset_strip.dart';

void main() {
  testWidgets('gantt chart quick preset strip applies display presets', (
    tester,
  ) async {
    var selectedPreferences = GanttChartDisplayPreferences.initial;
    GanttTimelineViewPreset? selectedTimelineView;
    GanttTimelineRangePreset? selectedRangePreset;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GanttChartQuickPresetStrip(
                displayPreferences: selectedPreferences,
                onChanged:
                    (preferences) =>
                        setState(() => selectedPreferences = preferences),
                onTimelineViewChanged:
                    (value) => setState(() => selectedTimelineView = value),
                onRangePresetChanged:
                    (value) => setState(() => selectedRangePreset = value),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Chart focus'), findsOneWidget);
    expect(find.text('Custom setup'), findsOneWidget);
    expect(find.text('Risk'), findsOneWidget);
    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
    expect(
      find.byTooltip(
        'Risk: Dependency Watch, Attention Window - highlights blocked '
        'dependencies and schedule conflicts.',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Team: Active Now, Next 90 Days - emphasizes ownership, progress, '
        'and active work.',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Milestones: All Tasks, Project Span - simplifies bars for a '
        'roadmap-level milestone scan.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        GanttChartQuickPresetStrip.presetChipKey(GanttChartQuickPreset.team),
      ),
    );
    await tester.pump();

    expect(selectedPreferences.showTeamAvatars, isTrue);
    expect(selectedPreferences.maxTeamAvatars, 4);
    expect(selectedPreferences.teamAvatarStyle, GanttTeamAvatarStyle.prominent);
    expect(selectedTimelineView, GanttTimelineViewPreset.activeNow);
    expect(selectedRangePreset, GanttTimelineRangePreset.nextNinetyDays);
    expect(find.text('Team: Active Now, Next 90 Days'), findsOneWidget);

    await tester.tap(
      find.byKey(
        GanttChartQuickPresetStrip.presetChipKey(
          GanttChartQuickPreset.milestones,
        ),
      ),
    );
    await tester.pump();

    expect(selectedPreferences.showMilestoneLabels, isTrue);
    expect(selectedPreferences.showDependencyLines, isFalse);
    expect(selectedTimelineView, GanttTimelineViewPreset.all);
    expect(selectedRangePreset, GanttTimelineRangePreset.projectSpan);
    expect(find.text('Milestones: All Tasks, Project Span'), findsOneWidget);
  });

  testWidgets('gantt chart quick preset strip marks custom state read-only', (
    tester,
  ) async {
    var changeCount = 0;
    final customPreferences = const GanttChartQuickPresetService()
        .preferencesFor(GanttChartQuickPreset.team)
        .copyWith(showTaskBarShadows: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartQuickPresetStrip(
            displayPreferences: customPreferences,
            onChanged: (_) => changeCount++,
          ),
        ),
      ),
    );

    final customFinder = find.byKey(
      GanttChartQuickPresetStrip.presetChipKey(GanttChartQuickPreset.custom),
    );
    final customChoiceChipFinder = find.descendant(
      of: customFinder,
      matching: find.byType(ChoiceChip),
    );

    expect(find.text('Custom setup'), findsOneWidget);
    expect(customFinder, findsOneWidget);
    expect(
      find.byTooltip('Custom setup uses the current chart controls.'),
      findsOneWidget,
    );
    expect(tester.widget<ChoiceChip>(customChoiceChipFinder).selected, isTrue);
    expect(
      tester.widget<ChoiceChip>(customChoiceChipFinder).onSelected,
      isNull,
    );

    await tester.tap(customFinder);
    await tester.pump();

    expect(changeCount, isZero);
  });

  testWidgets('gantt chart quick preset strip can hide lens affordances', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartQuickPresetStrip(
            displayPreferences: const GanttChartQuickPresetService()
                .preferencesFor(GanttChartQuickPreset.team),
            showLensSummary: false,
            showPresetTooltips: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Team setup'), findsOneWidget);
    expect(find.byTooltip('Team: Active Now, Next 90 Days'), findsNothing);
    expect(
      find.byTooltip(
        'Team: Active Now, Next 90 Days - emphasizes ownership, progress, '
        'and active work.',
      ),
      findsNothing,
    );
  });
}
