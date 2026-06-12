import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_edit_tool_strip.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  testWidgets('gantt chart edit tool strip updates active tools and snap', (
    tester,
  ) async {
    var preferences = GanttChartInteractionPreferences.initial;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GanttChartEditToolStrip(
                interactionPreferences: preferences,
                onChanged: (value) => setState(() => preferences = value),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Edit tools'), findsOneWidget);
    expect(find.text('3 active - Day snap'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Pattern'), findsOneWidget);
    expect(find.text('Impact'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Guides'), findsOneWidget);
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);
    expect(find.text('Depth'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.blockedPatternChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showBlockedDropPattern, isFalse);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.dropTargetChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showDropTarget, isFalse);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.leanPreviewChipKey));
    await tester.pumpAndSettle();

    expect(preferences.dragPreviewDetail, GanttDragPreviewDetail.lean);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.guideDatesChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showDragGuideLabels, isFalse);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.guideDatesChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showDragGuideLabels, isTrue);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartEditToolStrip.validationWarningsChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.showDragValidationBadge, isFalse);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartEditToolStrip.validationWarningsChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.showDragValidationBadge, isTrue);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.impactSummaryChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showDragImpactSummary, isFalse);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.dragPreviewChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showDragPreview, isFalse);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.snapGuidesChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showDragGuides, isFalse);
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.guideDatesChipKey));
    await tester.pumpAndSettle();

    expect(preferences.showDragGuideLabels, isTrue);

    await tester.tap(
      find.byKey(GanttChartEditToolStrip.validationWarningsChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.showDragValidationBadge, isTrue);

    await tester.tap(
      find.byKey(GanttChartEditToolStrip.balancedPreviewChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.dragPreviewDetail, GanttDragPreviewDetail.lean);

    await tester.tap(find.byKey(GanttChartEditToolStrip.elevatedDepthChipKey));
    await tester.pumpAndSettle();

    expect(
      preferences.interactionFeedbackDepth,
      GanttInteractionFeedbackDepth.elevated,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.dragChipKey));
    await tester.pumpAndSettle();

    expect(preferences.enableTaskBarDrag, isFalse);
    expect(find.text('2 active - Day snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.weekSnapChipKey));
    await tester.pumpAndSettle();

    expect(preferences.dragSnap, KyGanttTaskDragSnap.week);
    expect(find.text('2 active - Week snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.resizeChipKey));
    await tester.pumpAndSettle();

    expect(preferences.enableTaskBarResize, isFalse);
    expect(find.text('1 active - Week snap'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartEditToolStrip.daySnapChipKey));
    await tester.pumpAndSettle();

    expect(preferences.dragSnap, KyGanttTaskDragSnap.week);

    await tester.tap(find.byKey(GanttChartEditToolStrip.subtleDepthChipKey));
    await tester.pumpAndSettle();

    expect(
      preferences.interactionFeedbackDepth,
      GanttInteractionFeedbackDepth.elevated,
    );

    await tester.tap(find.byKey(GanttChartEditToolStrip.guardChipKey));
    await tester.pumpAndSettle();

    expect(preferences.enableScheduleGuard, isFalse);
    expect(find.text('0 active - Week snap'), findsOneWidget);
  });
}
