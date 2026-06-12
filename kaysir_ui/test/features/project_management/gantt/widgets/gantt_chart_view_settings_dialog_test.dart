import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_display_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_preferences_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_view_settings_dialog.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  testWidgets('gantt chart view settings dialog updates workspace display', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: GanttChartViewSettingsDialog()),
        ),
      ),
    );

    expect(find.text('View Settings'), findsOneWidget);
    expect(find.text('View Profile'), findsOneWidget);
    expect(
      find.text(
        'Plan balances editing, Team highlights ownership, Review locks inspection',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Team profile highlights ownership with prominent avatars and weekly snap.',
      ),
      findsOneWidget,
    );
    expect(find.text('Appearance'), findsOneWidget);
    expect(
      find.text(
        'Compact saves space, Balanced fits daily work, Presentation highlights ownership, Review trims visual noise',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Compact preset reduces labels, bands, and visual depth for dense planning.',
      ),
      findsOneWidget,
    );
    expect(find.text('View Defaults'), findsOneWidget);
    expect(find.text('Default preferences active'), findsOneWidget);
    expect(find.byTooltip('Reset view defaults'), findsOneWidget);
    expect(find.text('Team Avatars'), findsOneWidget);
    expect(find.text('Avatar Style'), findsOneWidget);
    expect(
      find.text(
        'Compact saves space, Balanced is standard, Prominent highlights ownership',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Prominent avatars increase size and overlap for team-first views.',
      ),
      findsOneWidget,
    );
    expect(find.text('Task Tooltip'), findsOneWidget);
    expect(find.text('Tooltip Detail'), findsOneWidget);
    expect(
      find.text(
        'Rich shows full context, Lean trims extras, Minimal keeps it compact',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Rich tooltips include status, duration, dependencies, assignees, and clip hints.',
      ),
      findsOneWidget,
    );
    expect(find.text('Avatar Count'), findsOneWidget);
    expect(
      find.text('Limit visible avatars from 1 to 5 teammates'),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Show up to five assigned teammates on each taskbar.'),
      findsOneWidget,
    );
    expect(find.text('Edit Feedback'), findsOneWidget);
    expect(find.text('Impact Summary'), findsOneWidget);
    expect(find.text('Preview Detail'), findsOneWidget);
    expect(
      find.text(
        'Lean hides extras, Balanced adds ghost bar, Detailed adds deltas',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Balanced preview adds the original versus target ghost bar.',
      ),
      findsOneWidget,
    );
    expect(find.text('Drop Target'), findsOneWidget);
    expect(find.text('Drag Lift'), findsOneWidget);
    expect(find.text('Edit Ghost'), findsOneWidget);
    expect(find.text('Feedback Depth'), findsOneWidget);
    expect(
      find.text(
        'Subtle keeps feedback quiet, Balanced is standard, Elevated adds lift',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Elevated feedback strengthens lift, shadow, and edit movement cues.',
      ),
      findsOneWidget,
    );
    expect(find.text('Hover Focus'), findsOneWidget);
    expect(find.text('Snap Guides'), findsOneWidget);
    expect(find.text('Guide Dates'), findsOneWidget);
    expect(find.text('Edit Warnings'), findsOneWidget);
    expect(find.text('Drag Handle'), findsOneWidget);
    expect(find.text('Resize Grips'), findsOneWidget);
    expect(
      find.text('Focus shows grips on intent, Always keeps grips visible'),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Focus grips appear when a task is selected, hovered, or being edited.',
      ),
      findsOneWidget,
    );
    expect(find.text('Snap Mode'), findsOneWidget);
    expect(
      find.text('Day edits are precise, Week aligns schedules'),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Week snap aligns task edits to whole-week movement.'),
      findsOneWidget,
    );
    expect(find.text('Inspector'), findsOneWidget);
    expect(
      find.text(
        'Auto chooses by space, Side keeps chart context, Bottom preserves width',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Bottom docks task details below the chart for more horizontal room.',
      ),
      findsOneWidget,
    );
    expect(find.text('Today Marker'), findsOneWidget);
    expect(find.text('Weekend Bands'), findsOneWidget);
    expect(find.text('Timeline Emphasis'), findsOneWidget);
    expect(
      find.text(
        'Subtle keeps markers quiet, Balanced is standard, Strong raises contrast',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Strong emphasis increases weekend and today marker contrast.',
      ),
      findsOneWidget,
    );
    expect(find.text('Dependency Lines'), findsOneWidget);
    expect(find.text('Dependency Focus'), findsOneWidget);
    expect(find.text('Focus Scope'), findsOneWidget);
    expect(
      find.byTooltip('Highlights upstream and downstream dependency chains'),
      findsOneWidget,
    );
    expect(find.text('Milestone Dates'), findsOneWidget);
    expect(find.text('Schedule Badges'), findsOneWidget);
    expect(find.text('Badge Style'), findsOneWidget);
    expect(
      find.text(
        'Full shows label and accent, Marker stays compact, Text keeps labels plain',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Marker badges use schedule color without extra label text.',
      ),
      findsOneWidget,
    );
    expect(find.text('Line Weight'), findsOneWidget);
    expect(
      find.text(
        'Subtle reduces connector noise, Balanced keeps links readable, Strong highlights chains',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Strong lines increase connector opacity and stroke weight.',
      ),
      findsOneWidget,
    );
    expect(find.text('Density'), findsOneWidget);
    expect(
      find.text(
        'Airy gives room, Cozy balances scan speed, Dense fits more work',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Dense rows fit more tasks into the visible timeline.'),
      findsOneWidget,
    );
    expect(find.text('Timeline Zoom'), findsOneWidget);
    expect(
      find.text(
        'Compact fits more dates, Balanced is standard, Wide opens spacing',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Wide zoom gives each day more horizontal room for precision.',
      ),
      findsOneWidget,
    );
    expect(find.text('Date Labels'), findsOneWidget);
    expect(find.text('Duration Labels'), findsOneWidget);
    expect(find.text('Dependency Badges'), findsOneWidget);
    expect(find.text('Dependency Risks'), findsOneWidget);
    expect(find.text('Row Emphasis'), findsOneWidget);
    expect(
      find.text('Subtle row is quiet, Balanced is steady, Strong draws focus'),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Strong row emphasis uses a stronger row highlight for reviews.',
      ),
      findsOneWidget,
    );
    expect(find.text('Bar Depth'), findsOneWidget);
    expect(
      find.text(
        'Subtle keeps bars flat, Balanced adds dimension, Elevated feels lifted',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        'Elevated depth strengthens taskbar shadows and vertical lift.',
      ),
      findsOneWidget,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTeamAvatars,
      isFalse,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).teamAvatarStyle,
      GanttTeamAvatarStyle.balanced,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTaskBarTooltips,
      isTrue,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).taskBarTooltipDetail,
      GanttTaskBarTooltipDetail.rich,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTodayMarker,
      isTrue,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showWeekendBands,
      isTrue,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .timelineAccentIntensity,
      GanttTimelineAccentIntensity.balanced,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .selectedTaskRowEmphasis,
      GanttSelectedTaskRowEmphasis.balanced,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTaskBarShadows,
      isTrue,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).taskBarDepth,
      GanttTaskBarDepth.balanced,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDateLabels,
      isTrue,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDurationLabels,
      isTrue,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDependencyBadges,
      isTrue,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDependencyConflictBadges,
      isTrue,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarScheduleBadges,
      isTrue,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .taskBarScheduleBadgeStyle,
      GanttTaskBarScheduleBadgeStyle.full,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showMilestoneDateLabels,
      isTrue,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .dependencyLineIntensity,
      GanttDependencyLineIntensity.balanced,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showScheduleEditFeedback,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragImpactSummary,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .dragPreviewDetail,
      GanttDragPreviewDetail.detailed,
    );
    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDragGuides,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragGuideLabels,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragValidationBadge,
      isTrue,
    );
    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDropTarget,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showBlockedDropPattern,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showInteractionLift,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showInteractionGhost,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showHoverFocusRing,
      isTrue,
    );
    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDragHandle,
      isTrue,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .interactionFeedbackDepth,
      GanttInteractionFeedbackDepth.balanced,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .resizeHandleVisibility,
      KyGanttTaskResizeHandleVisibility.focused,
    );
    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .inspectorPlacement,
      GanttTaskInspectorPlacement.adaptive,
    );

    await tester.ensureVisible(find.text('Preview Detail'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttDragPreviewDetail>),
        matching: find.text('Balanced'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .dragPreviewDetail,
      GanttDragPreviewDetail.balanced,
    );

    final compactPreset = find.descendant(
      of: find.byType(AppFilterChipGroup<GanttChartDisplayPreset>),
      matching: find.text('Compact'),
    );
    await tester.ensureVisible(find.text('Appearance'));
    await tester.tap(compactPreset);
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).density,
      GanttChartDensity.dense,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).timelineZoom,
      GanttChartTimelineZoom.compact,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDateLabels,
      isFalse,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDurationLabels,
      isFalse,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDependencyBadges,
      isFalse,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDependencyConflictBadges,
      isFalse,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarProgressLabels,
      isFalse,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarScheduleBadges,
      isFalse,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .taskBarScheduleBadgeStyle,
      GanttTaskBarScheduleBadgeStyle.marker,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showMilestoneDateLabels,
      isFalse,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showWeekendBands,
      isFalse,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .timelineAccentIntensity,
      GanttTimelineAccentIntensity.subtle,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTaskBarShadows,
      isFalse,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).teamAvatarStyle,
      GanttTeamAvatarStyle.compact,
    );
    expect(
      container.read(ganttChartDisplayPreferencesProvider).taskBarDepth,
      GanttTaskBarDepth.subtle,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .selectedTaskRowEmphasis,
      GanttSelectedTaskRowEmphasis.subtle,
    );
    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .dependencyLineIntensity,
      GanttDependencyLineIntensity.subtle,
    );

    await tester.ensureVisible(find.text('Line Weight'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttDependencyLineIntensity>),
        matching: find.text('Strong'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .dependencyLineIntensity,
      GanttDependencyLineIntensity.strong,
    );

    await tester.ensureVisible(find.text('Focus Scope'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<KyGanttDependencyLineFocusScope>),
        matching: find.text('Down'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).dependencyFocusScope,
      KyGanttDependencyLineFocusScope.downstream,
    );

    await tester.ensureVisible(find.text('Timeline Emphasis'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttTimelineAccentIntensity>),
        matching: find.text('Strong'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .timelineAccentIntensity,
      GanttTimelineAccentIntensity.strong,
    );

    await tester.ensureVisible(find.text('Selection Row'));
    await tester.tap(find.text('Selection Row'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showSelectedTaskRowHighlight,
      isTrue,
    );

    await tester.ensureVisible(find.text('Row Emphasis'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttSelectedTaskRowEmphasis>),
        matching: find.text('Strong'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .selectedTaskRowEmphasis,
      GanttSelectedTaskRowEmphasis.strong,
    );

    await tester.ensureVisible(find.text('Bar Shadows'));
    await tester.tap(find.text('Bar Shadows'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTaskBarShadows,
      isTrue,
    );

    await tester.ensureVisible(find.text('Bar Depth'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttTaskBarDepth>),
        matching: find.text('Elevated'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).taskBarDepth,
      GanttTaskBarDepth.elevated,
    );

    await tester.ensureVisible(find.text('Edit Feedback'));
    await tester.tap(find.text('Edit Feedback'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showScheduleEditFeedback,
      isFalse,
    );

    await tester.ensureVisible(find.text('Impact Summary'));
    await tester.tap(find.text('Impact Summary'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragImpactSummary,
      isFalse,
    );

    await tester.ensureVisible(find.text('Guide Dates'));
    await tester.tap(find.text('Guide Dates'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragGuideLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('Drop Target'));
    await tester.tap(find.text('Drop Target'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDropTarget,
      isFalse,
    );

    await tester.ensureVisible(find.text('Blocked Pattern'));
    await tester.tap(find.text('Blocked Pattern'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showBlockedDropPattern,
      isFalse,
    );

    await tester.ensureVisible(find.text('Drag Lift'));
    await tester.tap(find.text('Drag Lift'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showInteractionLift,
      isFalse,
    );

    await tester.ensureVisible(find.text('Edit Ghost'));
    await tester.tap(find.text('Edit Ghost'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showInteractionGhost,
      isFalse,
    );

    await tester.ensureVisible(find.text('Feedback Depth'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttInteractionFeedbackDepth>),
        matching: find.text('Elevated'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .interactionFeedbackDepth,
      GanttInteractionFeedbackDepth.elevated,
    );

    await tester.ensureVisible(find.text('Hover Focus'));
    await tester.tap(find.text('Hover Focus'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showHoverFocusRing,
      isFalse,
    );

    await tester.ensureVisible(find.text('Edit Warnings'));
    await tester.tap(find.text('Edit Warnings'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragValidationBadge,
      isFalse,
    );

    await tester.ensureVisible(find.text('Snap Guides'));
    await tester.tap(find.text('Snap Guides'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDragGuides,
      isFalse,
    );

    await tester.ensureVisible(find.text('Drag Handle'));
    await tester.tap(find.text('Drag Handle'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDragHandle,
      isFalse,
    );

    await tester.ensureVisible(find.text('Date Labels'));
    await tester.tap(find.text('Date Labels'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDateLabels,
      isTrue,
    );

    await tester.ensureVisible(find.text('Duration Labels'));
    await tester.tap(find.text('Duration Labels'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDurationLabels,
      isTrue,
    );

    await tester.ensureVisible(find.text('Dependency Badges'));
    await tester.tap(find.text('Dependency Badges'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDependencyBadges,
      isTrue,
    );

    await tester.ensureVisible(find.text('Dependency Risks'));
    await tester.tap(find.text('Dependency Risks'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarDependencyConflictBadges,
      isTrue,
    );

    await tester.ensureVisible(find.text('Schedule Badges'));
    await tester.tap(find.text('Schedule Badges'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarScheduleBadges,
      isTrue,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttTaskBarScheduleBadgeStyle>),
        matching: find.text('Text'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .taskBarScheduleBadgeStyle,
      GanttTaskBarScheduleBadgeStyle.text,
    );

    await tester.ensureVisible(find.text('Milestone Dates'));
    await tester.tap(find.text('Milestone Dates'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartDisplayPreferencesProvider)
          .showMilestoneDateLabels,
      isTrue,
    );

    await tester.ensureVisible(find.text('Resize Grips'));
    await tester.tap(find.text('Always'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .resizeHandleVisibility,
      KyGanttTaskResizeHandleVisibility.always,
    );

    await tester.ensureVisible(find.text('Inspector'));
    await tester.tap(find.text('Bottom'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .inspectorPlacement,
      GanttTaskInspectorPlacement.bottom,
    );

    await tester.ensureVisible(find.text('Team Avatars'));
    await tester.tap(find.text('Team Avatars'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTeamAvatars,
      isTrue,
    );

    await tester.ensureVisible(find.text('Avatar Style'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttTeamAvatarStyle>),
        matching: find.text('Prominent'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).teamAvatarStyle,
      GanttTeamAvatarStyle.prominent,
    );

    await tester.ensureVisible(find.text('Task Tooltip'));
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<GanttTaskBarTooltipDetail>),
        matching: find.text('Lean'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).taskBarTooltipDetail,
      GanttTaskBarTooltipDetail.lean,
    );

    await tester.tap(find.text('Task Tooltip'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTaskBarTooltips,
      isFalse,
    );

    await tester.ensureVisible(find.text('Today Marker'));
    await tester.tap(find.text('Today Marker'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTodayMarker,
      isFalse,
    );

    await tester.ensureVisible(find.text('Weekend Bands'));
    await tester.tap(find.text('Weekend Bands'));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showWeekendBands,
      isTrue,
    );
  });
}
