import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_compact_control_summary_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_compact_control_summary.dart';

void main() {
  testWidgets('gantt compact control summary renders preview detail pill', (
    tester,
  ) async {
    final summary = _summary();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartCompactControlSummaryView(summary: summary),
        ),
      ),
    );

    expect(
      find.byKey(GanttChartCompactControlSummary.summaryKey),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Semantics>(
            find.byKey(GanttChartCompactControlSummary.summarySemanticsKey),
          )
          .properties
          .label,
      summary.semanticsLabel,
    );
    expect(find.text('Chart setup'), findsOneWidget);
    expect(
      find.byKey(
        GanttChartCompactControlSummary.itemKey(
          GanttChartCompactControlSummaryRole.previewDetail,
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Detailed preview'), findsOneWidget);
    expect(
      find.byTooltip(
        'Detailed preview adds ghost bar and before/after delta ranges.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('gantt compact control summary wraps on wide headers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: GanttChartCompactControlSummaryView(summary: _summary()),
          ),
        ),
      ),
    );

    expect(
      find.byKey(GanttChartCompactControlSummary.wrappedLayoutKey),
      findsOneWidget,
    );
    expect(
      find.byKey(GanttChartCompactControlSummary.scrollLayoutKey),
      findsNothing,
    );
  });

  testWidgets('gantt compact control summary scrolls on narrow headers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: GanttChartCompactControlSummaryView(summary: _summary()),
          ),
        ),
      ),
    );

    expect(
      find.byKey(GanttChartCompactControlSummary.scrollLayoutKey),
      findsOneWidget,
    );
    expect(
      find.byKey(GanttChartCompactControlSummary.wrappedLayoutKey),
      findsNothing,
    );
  });
}

GanttChartCompactControlSummarySnapshot _summary() {
  return const GanttChartCompactControlSummaryService().summaryFor(
    displayPreferences: GanttChartDisplayPreferences.initial,
    interactionPreferences: GanttChartInteractionPreferences.initial,
    timelineView: GanttTimelineViewPreset.all,
    rangePreset: GanttTimelineRangePreset.planningWindow,
  );
}
