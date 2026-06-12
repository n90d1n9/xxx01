import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/data/gantt_chart_workspace_preferences_repository.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/screens/gantt_dashboard_screen.dart';
import 'package:kaysir/features/project_management/gantt/screens/gantt_screen.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_workspace_preferences_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_display_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_view_profile_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_preferences_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_timeline_range_preset_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_baseline_variance_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_chain_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_overview_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_schedule_focus_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_selected_task_focus_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_header.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_overlay.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_schedule_guard_feedback.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_schedule_feedback.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_drag_preview_delta_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_drag_preview_ghost_bar.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_successor_impact_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_active_focus_bar.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_compact_control_summary.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_view_settings_dialog.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_edit_tool_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_layer_toggle_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_quick_preset_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_viewport_control_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_health_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_search_field.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_saved_views_bar.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_viewport_navigator.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_tree_control_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/project_gantt_chart_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  testWidgets('gantt dashboard renders schedule intelligence', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: GanttDashboardScreen())),
    );

    expect(find.text('Gantt Dashboard'), findsWidgets);
    expect(find.byType(AppMetricGrid), findsNWidgets(4));
    expect(find.byType(GanttScheduleFocusPanel), findsOneWidget);
    expect(find.byType(GanttBaselineVariancePanel), findsOneWidget);
    expect(find.byType(GanttDependencyOverviewPanel), findsOneWidget);
    expect(find.text('Schedule Focus'), findsOneWidget);
    expect(find.text('Baseline Variance'), findsOneWidget);
    expect(find.text('Dependency Readiness'), findsOneWidget);
    expect(find.text('Full Chart'), findsOneWidget);
    expect(find.byType(ProjectGanttChartPanel), findsNothing);
    expect(find.byType(KyGanttChart), findsNothing);
  });

  testWidgets('full gantt chart renders controls and filters tasks', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: GanttChartScreen())),
    );

    expect(find.text('Full Gantt Chart'), findsWidgets);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byType(GanttDependencyHealthStrip), findsOneWidget);
    expect(find.text('Dependency health'), findsOneWidget);
    expect(find.text('2 schedule risks'), findsOneWidget);
    expect(find.byType(AppSelectField<gantt.ViewMode>), findsOneWidget);
    expect(find.byType(AppSelectField<String>), findsOneWidget);
    expect(find.byType(AppSelectField<GanttTaskStatusFilter>), findsOneWidget);
    expect(
      find.byType(AppSelectField<GanttTimelineRangePreset>),
      findsOneWidget,
    );
    expect(find.byType(GanttTimelineSavedViewsBar), findsOneWidget);
    expect(find.byType(GanttTimelineViewportNavigator), findsOneWidget);
    expect(find.text('Range Preset'), findsOneWidget);
    expect(find.text('Navigate timeline'), findsOneWidget);
    expect(find.text('Fit All'), findsOneWidget);
    expect(find.textContaining('Planning Window'), findsWidgets);
    expect(find.text('All Tasks'), findsOneWidget);
    expect(find.text('Active Now'), findsOneWidget);
    expect(find.text('Chart layers'), findsOneWidget);
    expect(find.text('3 active - Full deps'), findsOneWidget);
    expect(find.text('Viewport'), findsOneWidget);
    expect(find.text('Loose rows - Normal scale'), findsOneWidget);
    expect(find.text('Edit tools'), findsOneWidget);
    expect(find.text('3 active - Day snap'), findsOneWidget);
    expect(
      find.byKey(GanttChartCompactControlSummary.summaryKey),
      findsNothing,
    );
    expect(find.text('Chart setup'), findsNothing);
    expect(find.text('Task tree'), findsOneWidget);
    expect(find.text('0 of 1 collapsed'), findsOneWidget);
    expect(find.text('Hide Controls'), findsOneWidget);
    expect(find.text('Show Controls'), findsNothing);
    expect(find.text('Undo Edit'), findsOneWidget);
    expect(find.text('View Settings'), findsOneWidget);
    expect(find.text('View Profile'), findsNothing);
    expect(find.text('Drag Dates'), findsNothing);
    expect(find.byType(SegmentedButton<KyGanttTaskDragSnap>), findsNothing);
    expect(
      find.byType(SegmentedButton<GanttTaskInspectorPlacement>),
      findsNothing,
    );
    expect(find.byType(SegmentedButton<int>), findsNothing);
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.comma,
    );
    await tester.pumpAndSettle();

    expect(find.byType(GanttChartViewSettingsDialog), findsOneWidget);
    expect(find.text('View Profile'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('View Defaults'), findsOneWidget);
    expect(find.text('Drag Dates'), findsOneWidget);
    expect(find.text('Drag Preview'), findsOneWidget);
    expect(find.text('Impact Summary'), findsOneWidget);
    expect(find.text('Preview Detail'), findsOneWidget);
    expect(find.text('Drop Target'), findsOneWidget);
    expect(find.text('Drag Lift'), findsOneWidget);
    expect(find.text('Edit Ghost'), findsOneWidget);
    expect(find.text('Hover Focus'), findsOneWidget);
    expect(find.text('Snap Guides'), findsOneWidget);
    expect(find.text('Guide Dates'), findsOneWidget);
    expect(find.text('Edit Warnings'), findsOneWidget);
    expect(find.text('Drag Handle'), findsOneWidget);
    expect(find.text('Resize Edges'), findsOneWidget);
    expect(find.text('Resize Grips'), findsOneWidget);
    expect(find.text('Schedule Guard'), findsOneWidget);
    expect(find.text('Snap Mode'), findsOneWidget);
    expect(find.text('Inspector'), findsOneWidget);
    expect(find.text('Team Avatars'), findsOneWidget);
    expect(find.text('Task Tooltip'), findsOneWidget);
    expect(find.text('Tooltip Detail'), findsOneWidget);
    expect(find.text('Avatar Count'), findsOneWidget);
    expect(find.text('Today Marker'), findsOneWidget);
    expect(find.text('Dependency Lines'), findsOneWidget);
    expect(find.text('Dependency Focus'), findsOneWidget);
    expect(find.text('Focus Scope'), findsOneWidget);
    expect(find.text('Line Weight'), findsOneWidget);
    expect(find.text('Density'), findsOneWidget);
    expect(find.text('Timeline Zoom'), findsOneWidget);
    expect(find.text('Milestone Labels'), findsOneWidget);
    expect(find.text('Milestone Dates'), findsOneWidget);
    expect(find.text('Status Badges'), findsOneWidget);
    expect(find.text('Schedule Badges'), findsOneWidget);
    expect(find.text('Badge Style'), findsOneWidget);
    expect(find.text('Date Labels'), findsOneWidget);
    expect(find.text('Duration Labels'), findsOneWidget);
    expect(find.text('Dependency Badges'), findsOneWidget);
    expect(find.text('Dependency Risks'), findsOneWidget);
    expect(find.text('Progress Labels'), findsOneWidget);
    expect(find.text('Selection Glow'), findsOneWidget);
    expect(find.text('Row Emphasis'), findsOneWidget);
    expect(find.text('Bar Shadows'), findsOneWidget);
    expect(find.byType(SegmentedButton<KyGanttTaskDragSnap>), findsOneWidget);
    expect(
      find.byType(SegmentedButton<KyGanttTaskResizeHandleVisibility>),
      findsOneWidget,
    );
    expect(
      find.byType(SegmentedButton<GanttTaskInspectorPlacement>),
      findsOneWidget,
    );
    expect(
      find.byType(SegmentedButton<GanttTaskBarTooltipDetail>),
      findsOneWidget,
    );
    expect(
      find.byType(SegmentedButton<GanttTaskBarScheduleBadgeStyle>),
      findsOneWidget,
    );
    expect(find.byType(SegmentedButton<int>), findsOneWidget);
    expect(
      find.byType(SegmentedButton<KyGanttDependencyLineFocusScope>),
      findsOneWidget,
    );
    expect(
      find.byType(SegmentedButton<GanttDependencyLineIntensity>),
      findsOneWidget,
    );
    expect(
      find.byType(SegmentedButton<GanttSelectedTaskRowEmphasis>),
      findsOneWidget,
    );
    expect(find.byType(SegmentedButton<GanttChartDensity>), findsOneWidget);
    expect(
      find.byType(SegmentedButton<GanttChartTimelineZoom>),
      findsOneWidget,
    );
    expect(find.byType(SegmentedButton<GanttChartViewProfile>), findsOneWidget);
    expect(
      find.byType(AppFilterChipGroup<GanttChartDisplayPreset>),
      findsOneWidget,
    );
    expect(find.byType(ProjectGanttChartPanel), findsOneWidget);
    expect(find.byType(KyGanttChart), findsOneWidget);
    expect(find.byKey(KyGanttDependencyLayer.defaultLayerKey), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsNothing,
    );
    expect(find.byType(GanttTaskInspectorOverlay), findsNothing);
    expect(find.text('Task Inspector'), findsNothing);
    expect(find.text('Select a timeline task'), findsNothing);
    expect(find.byType(GanttScheduleFocusPanel), findsNothing);
    expect(find.byType(GanttBaselineVariancePanel), findsNothing);
    expect(find.byType(GanttDependencyOverviewPanel), findsNothing);
    expect(find.text('Project Planning'), findsWidgets);
    expect(find.textContaining('Retail Modernization'), findsWidgets);
    expect(
      tester.widget<KyGanttChart>(find.byType(KyGanttChart)).rowHeight,
      58,
    );
    expect(tester.widget<KyGanttChart>(find.byType(KyGanttChart)).dayWidth, 42);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTodayMarker,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttTimelineHeader>(
            find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
          )
          .showTodayMarker,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showWeekendBands,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttTimelineHeader>(
            find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
          )
          .showWeekendBands,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showSelectedTaskFocus,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showSelectedTaskRowHighlight,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDateLabels,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDurationLabels,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDependencyBadges,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDependencyConflictBadges,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .dependencyLines
          .highlightConflictedDependencies,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarProgressLabels,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarStatusLabels,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarScheduleBadge
          .visible,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarTooltip
          .visible,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showMilestoneLabels,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showMilestoneDateLabels,
      isTrue,
    );

    await tester.ensureVisible(find.text('Today Marker'));
    await tester.tap(find.text('Today Marker'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTodayMarker,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttTimelineHeader>(
            find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
          )
          .showTodayMarker,
      isFalse,
    );

    await tester.ensureVisible(find.text('Weekend Bands'));
    await tester.tap(find.text('Weekend Bands'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showWeekendBands,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttTimelineHeader>(
            find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
          )
          .showWeekendBands,
      isFalse,
    );

    final teamProfile = find.descendant(
      of: find.byType(SegmentedButton<GanttChartViewProfile>),
      matching: find.text('Team'),
    );
    await tester.ensureVisible(teamProfile);
    await tester.tap(teamProfile);
    await tester.pumpAndSettle();

    final teamChart = tester.widget<KyGanttChart>(find.byType(KyGanttChart));
    expect(teamChart.rowHeight, 50);
    expect(teamChart.dayWidth, 52.08);
    expect(teamChart.displayOptions.showTaskBarAvatars, isTrue);
    expect(teamChart.displayOptions.maxTaskBarAvatars, 4);
    expect(teamChart.displayOptions.taskBarAvatar.size, 26);
    expect(teamChart.displayOptions.taskBarTooltip.visible, isTrue);
    expect(teamChart.displayOptions.showWeekendBands, isTrue);
    expect(teamChart.displayOptions.showSelectedTaskRowHighlight, isTrue);
    expect(teamChart.displayOptions.showTaskBarDateLabels, isTrue);
    expect(teamChart.displayOptions.showTaskBarDurationLabels, isTrue);
    expect(teamChart.displayOptions.showTaskBarDependencyBadges, isTrue);
    expect(teamChart.displayOptions.taskBarScheduleBadge.visible, isTrue);
    expect(
      teamChart.displayOptions.showTaskBarDependencyConflictBadges,
      isTrue,
    );
    expect(
      teamChart.displayOptions.dependencyLines.highlightConflictedDependencies,
      isTrue,
    );
    expect(teamChart.displayOptions.showMilestoneDateLabels, isTrue);
    expect(teamChart.interactionOptions.showTaskBarDragHandle, isTrue);
    expect(teamChart.interactionOptions.showTaskBarInteractionLift, isTrue);
    expect(teamChart.interactionOptions.showTaskBarInteractionGhost, isTrue);
    expect(teamChart.interactionOptions.showTaskBarHoverFocusRing, isTrue);
    expect(teamChart.interactionOptions.showTaskBarDropTarget, isTrue);
    expect(teamChart.interactionOptions.showTaskBarBlockedDropPattern, isTrue);
    expect(teamChart.interactionOptions.showTaskBarDragGuides, isTrue);
    expect(teamChart.interactionOptions.showTaskBarDragGuideLabels, isTrue);
    expect(teamChart.interactionOptions.showTaskBarDragValidationBadge, isTrue);
    expect(
      teamChart.interactionOptions.taskBarInteractionFeedback.opacityScale,
      1.22,
    );
    expect(
      teamChart.interactionOptions.resizeHandleVisibility,
      KyGanttTaskResizeHandleVisibility.focused,
    );
    expect(teamChart.interactionOptions.dragSnap, KyGanttTaskDragSnap.week);
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsWidgets,
    );

    await tester.ensureVisible(find.text('View Defaults'));
    await tester.tap(
      find.byKey(const ValueKey('gantt-chart-view-reset-button')),
    );
    await tester.pumpAndSettle();

    final profileResetChart = tester.widget<KyGanttChart>(
      find.byType(KyGanttChart),
    );
    expect(profileResetChart.rowHeight, 58);
    expect(profileResetChart.dayWidth, 42);
    expect(profileResetChart.displayOptions.showTaskBarAvatars, isFalse);
    expect(profileResetChart.displayOptions.taskBarAvatar.size, 22);
    expect(
      profileResetChart.interactionOptions.dragSnap,
      KyGanttTaskDragSnap.day,
    );

    final compactAppearance = find.descendant(
      of: find.byType(AppFilterChipGroup<GanttChartDisplayPreset>),
      matching: find.text('Compact'),
    );
    await tester.ensureVisible(find.text('Appearance'));
    await tester.tap(compactAppearance);
    await tester.pumpAndSettle();

    final compactChart = tester.widget<KyGanttChart>(find.byType(KyGanttChart));
    expect(compactChart.rowHeight, 44);
    expect(compactChart.dayWidth, 34.44);
    expect(compactChart.displayOptions.showTaskBarShadows, isFalse);
    expect(compactChart.displayOptions.showWeekendBands, isFalse);
    expect(compactChart.displayOptions.showSelectedTaskRowHighlight, isFalse);
    expect(compactChart.displayOptions.showTaskBarDateLabels, isFalse);
    expect(compactChart.displayOptions.showTaskBarDurationLabels, isFalse);
    expect(compactChart.displayOptions.showTaskBarDependencyBadges, isFalse);
    expect(
      compactChart.displayOptions.showTaskBarDependencyConflictBadges,
      isFalse,
    );
    expect(
      compactChart
          .displayOptions
          .dependencyLines
          .highlightConflictedDependencies,
      isFalse,
    );
    expect(compactChart.displayOptions.showTaskBarProgressLabels, isFalse);
    expect(compactChart.displayOptions.taskBarScheduleBadge.visible, isFalse);
    expect(compactChart.displayOptions.showMilestoneLabels, isFalse);
    expect(compactChart.displayOptions.showMilestoneDateLabels, isFalse);

    await tester.ensureVisible(find.text('View Defaults'));
    await tester.tap(
      find.byKey(const ValueKey('gantt-chart-view-reset-button')),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Density'));
    await tester.tap(find.text('Dense'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<KyGanttChart>(find.byType(KyGanttChart)).rowHeight,
      44,
    );

    await tester.ensureVisible(find.text('Timeline Zoom'));
    await tester.tap(find.text('Wide'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<KyGanttChart>(find.byType(KyGanttChart)).dayWidth,
      52.08,
    );

    await tester.ensureVisible(find.text('Team Avatars'));
    await tester.tap(find.text('Team Avatars'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsWidgets,
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
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarAvatar
          .size,
      26,
    );

    await tester.ensureVisible(find.text('Task Tooltip'));
    await tester.tap(find.text('Task Tooltip'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarTooltip
          .visible,
      isFalse,
    );

    final avatarCountTwo = find.descendant(
      of: find.byType(SegmentedButton<int>),
      matching: find.text('2'),
    );
    await tester.tap(avatarCountTwo);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .maxTaskBarAvatars,
      2,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-overflow')),
      findsWidgets,
    );

    await tester.ensureVisible(find.text('Drag Handle'));
    await tester.tap(find.text('Drag Handle'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDragHandle,
      isFalse,
    );

    await tester.ensureVisible(find.text('Guide Dates'));
    await tester.tap(find.text('Guide Dates'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDragGuideLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('Drop Target'));
    await tester.tap(find.text('Drop Target'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDropTarget,
      isFalse,
    );

    await tester.ensureVisible(find.text('Blocked Pattern'));
    await tester.tap(find.text('Blocked Pattern'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarBlockedDropPattern,
      isFalse,
    );

    await tester.ensureVisible(find.text('Drag Lift'));
    await tester.tap(find.text('Drag Lift'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarInteractionLift,
      isFalse,
    );

    await tester.ensureVisible(find.text('Edit Ghost'));
    await tester.tap(find.text('Edit Ghost'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarInteractionGhost,
      isFalse,
    );

    await tester.ensureVisible(find.text('Hover Focus'));
    await tester.tap(find.text('Hover Focus'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarHoverFocusRing,
      isFalse,
    );

    await tester.ensureVisible(find.text('Edit Warnings'));
    await tester.tap(find.text('Edit Warnings'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDragValidationBadge,
      isFalse,
    );

    await tester.ensureVisible(find.text('Snap Guides'));
    await tester.tap(find.text('Snap Guides'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDragGuides,
      isFalse,
    );

    final resizeGripAlways = find.descendant(
      of: find.byType(SegmentedButton<KyGanttTaskResizeHandleVisibility>),
      matching: find.text('Always'),
    );
    await tester.ensureVisible(find.text('Resize Grips'));
    await tester.tap(resizeGripAlways);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .resizeHandleVisibility,
      KyGanttTaskResizeHandleVisibility.always,
    );

    await tester.ensureVisible(find.text('Selection Glow'));
    await tester.tap(find.text('Selection Glow'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showSelectedTaskFocus,
      isFalse,
    );

    await tester.ensureVisible(find.text('Selection Row'));
    await tester.tap(find.text('Selection Row'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showSelectedTaskRowHighlight,
      isFalse,
    );

    await tester.ensureVisible(find.text('Progress Labels'));
    await tester.tap(find.text('Progress Labels'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarProgressLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('Status Badges'));
    await tester.tap(find.text('Status Badges'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarStatusLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('Schedule Badges'));
    await tester.tap(find.text('Schedule Badges'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarScheduleBadge
          .visible,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarScheduleBadge
          .showAccent,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarScheduleBadge
          .showLabel,
      isTrue,
    );

    await tester.ensureVisible(find.text('Date Labels'));
    await tester.tap(find.text('Date Labels'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDateLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('Duration Labels'));
    await tester.tap(find.text('Duration Labels'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDurationLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('Dependency Badges'));
    await tester.tap(find.text('Dependency Badges'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDependencyBadges,
      isFalse,
    );

    await tester.ensureVisible(find.text('Dependency Risks'));
    await tester.tap(find.text('Dependency Risks'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarDependencyConflictBadges,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .dependencyLines
          .highlightConflictedDependencies,
      isFalse,
    );

    await tester.ensureVisible(find.text('Milestone Labels'));
    await tester.tap(find.text('Milestone Labels'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showMilestoneLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('Milestone Dates'));
    await tester.tap(find.text('Milestone Dates'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showMilestoneDateLabels,
      isFalse,
    );

    await tester.ensureVisible(find.text('View Defaults'));
    await tester.tap(
      find.byKey(const ValueKey('gantt-chart-view-reset-button')),
    );
    await tester.pumpAndSettle();

    final resetChart = tester.widget<KyGanttChart>(find.byType(KyGanttChart));
    expect(resetChart.rowHeight, 58);
    expect(resetChart.dayWidth, 42);
    expect(resetChart.displayOptions.showTaskBarAvatars, isFalse);
    expect(resetChart.displayOptions.maxTaskBarAvatars, 3);
    expect(resetChart.displayOptions.taskBarTooltip.visible, isTrue);
    expect(resetChart.displayOptions.showWeekendBands, isTrue);
    expect(resetChart.displayOptions.showSelectedTaskFocus, isTrue);
    expect(resetChart.displayOptions.showSelectedTaskRowHighlight, isTrue);
    expect(resetChart.displayOptions.showTaskBarDateLabels, isTrue);
    expect(resetChart.displayOptions.showTaskBarDurationLabels, isTrue);
    expect(resetChart.displayOptions.showTaskBarDependencyBadges, isTrue);
    expect(
      resetChart.displayOptions.showTaskBarDependencyConflictBadges,
      isTrue,
    );
    expect(
      resetChart.displayOptions.dependencyLines.highlightConflictedDependencies,
      isTrue,
    );
    expect(resetChart.displayOptions.showTaskBarProgressLabels, isTrue);
    expect(resetChart.displayOptions.showTaskBarStatusLabels, isTrue);
    expect(resetChart.displayOptions.taskBarScheduleBadge.visible, isTrue);
    expect(resetChart.displayOptions.showMilestoneLabels, isTrue);
    expect(resetChart.displayOptions.showMilestoneDateLabels, isTrue);
    expect(resetChart.interactionOptions.showTaskBarInteractionLift, isTrue);
    expect(resetChart.interactionOptions.showTaskBarInteractionGhost, isTrue);
    expect(resetChart.interactionOptions.showTaskBarHoverFocusRing, isTrue);
    expect(resetChart.interactionOptions.showTaskBarDropTarget, isTrue);
    expect(resetChart.interactionOptions.showTaskBarBlockedDropPattern, isTrue);
    expect(resetChart.interactionOptions.showTaskBarDragGuides, isTrue);
    expect(resetChart.interactionOptions.showTaskBarDragGuideLabels, isTrue);
    expect(
      resetChart.interactionOptions.showTaskBarDragValidationBadge,
      isTrue,
    );
    expect(
      resetChart.interactionOptions.taskBarInteractionFeedback.opacityScale,
      1,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsNothing,
    );

    await tester.tap(find.byKey(GanttChartViewSettingsDialog.closeButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(GanttChartViewSettingsDialog), findsNothing);

    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.backslash,
    );
    await tester.pumpAndSettle();

    expect(find.text('Show Controls'), findsOneWidget);
    expect(
      find.byKey(GanttChartCompactControlSummary.summaryKey),
      findsOneWidget,
    );
    expect(find.text('Chart setup'), findsOneWidget);
    expect(find.text('Custom focus'), findsOneWidget);
    expect(find.text('All Tasks / Planning Window'), findsOneWidget);
    expect(find.text('3 layers'), findsOneWidget);
    expect(find.text('Loose rows / Normal scale'), findsOneWidget);
    expect(find.text('3 edit tools'), findsOneWidget);
    expect(find.text('Day snap'), findsOneWidget);
    expect(find.byType(AppSelectField<gantt.ViewMode>), findsNothing);
    expect(find.byType(AppSelectField<GanttTimelineRangePreset>), findsNothing);
    expect(find.byType(GanttTimelineSavedViewsBar), findsNothing);
    expect(find.byType(GanttTimelineViewportNavigator), findsNothing);
    expect(find.byType(KyGanttChart), findsOneWidget);

    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyF,
    );
    await tester.pumpAndSettle();

    final searchTextField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search timeline tasks',
    );
    expect(find.text('Show Controls'), findsNothing);
    expect(find.byType(AppSelectField<gantt.ViewMode>), findsOneWidget);
    expect(
      tester.widget<TextField>(searchTextField).focusNode?.hasFocus,
      isTrue,
    );

    final projectPlanningTile = find.widgetWithText(
      KyGanttTaskListRow,
      'Project Planning',
    );
    await tester.ensureVisible(projectPlanningTile);
    await tester.tap(projectPlanningTile);
    await tester.pumpAndSettle();

    expect(find.byType(GanttTaskInspectorOverlay), findsOneWidget);
    expect(find.byType(GanttTaskInspectorHeader), findsOneWidget);
    expect(find.byType(GanttSelectedTaskFocusStrip), findsNothing);
    expect(find.text('Task Inspector'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(GanttTaskInspectorHeader),
        matching: find.text('Retail Modernization'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GanttTaskInspectorHeader),
        matching: find.text('80% complete'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GanttTaskInspectorHeader),
        matching: find.text('In progress'),
      ),
      findsOneWidget,
    );
    expect(find.text('Clear Selection'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(GanttTaskInspectorOverlay), findsNothing);
    expect(find.text('Task Inspector'), findsNothing);

    await tester.enterText(searchTextField, 'Testing');
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Testing'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsNothing,
    );

    expect(find.byKey(GanttTimelineSearchField.clearButtonKey), findsOneWidget);

    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyL,
      shift: true,
    );
    await tester.pump();

    expect(find.byKey(GanttTimelineSearchField.clearButtonKey), findsNothing);
    expect(tester.widget<TextField>(searchTextField).controller?.text, isEmpty);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('full gantt chart collapses and expands task tree branches', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Requirements Gathering'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('ky-gantt-task-bar-1.1')), findsOneWidget);
    expect(find.text('0 of 1 collapsed'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttTreeControlStrip.collapseAllButtonKey),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(GanttTreeControlStrip.collapseAllButtonKey));
    await tester.pumpAndSettle();

    expect(container.read(ganttCollapsedTaskIdsProvider), {'1'});
    expect(find.text('1 of 1 collapsed'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Requirements Gathering'),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('ky-gantt-task-bar-1.1')), findsNothing);

    await tester.ensureVisible(
      find.byKey(GanttTreeControlStrip.expandAllButtonKey),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(GanttTreeControlStrip.expandAllButtonKey));
    await tester.pumpAndSettle();

    expect(container.read(ganttCollapsedTaskIdsProvider), isEmpty);
    expect(find.text('0 of 1 collapsed'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Requirements Gathering'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('ky-gantt-task-bar-1.1')), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('ky-gantt-task-collapse-toggle-1')),
    );
    await tester.pumpAndSettle();

    expect(container.read(ganttCollapsedTaskIdsProvider), {'1'});
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Requirements Gathering'),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('ky-gantt-task-bar-1.1')), findsNothing);
  });

  testWidgets('full gantt chart quick layer toggles update display layers', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chart layers'), findsOneWidget);
    expect(find.text('3 active - Full deps'), findsOneWidget);
    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTeamAvatars,
      isFalse,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsNothing,
    );

    await tester.ensureVisible(
      find.byKey(GanttChartLayerToggleStrip.teamAvatarsChipKey),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(GanttChartLayerToggleStrip.teamAvatarsChipKey));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTeamAvatars,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarAvatars,
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsWidgets,
    );
    expect(
      find.byKey(
        const ValueKey(
          'ky-gantt-task-avatar-retail-modernization-maya-santoso-delivery-lead',
        ),
      ),
      findsWidgets,
    );
    expect(
      find.byTooltip('Maya Santoso - Delivery Lead, 80% allocated'),
      findsWidgets,
    );
    expect(find.text('4 active - Full deps'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyLinesChipKey),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showDependencyLines,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .dependencyLines
          .visible,
      isFalse,
    );
    expect(find.byKey(KyGanttDependencyLayer.defaultLayerKey), findsNothing);
    expect(find.text('3 active - Deps hidden'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.weekendBandsChipKey),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showWeekendBands,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttTimelineHeader>(
            find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
          )
          .showWeekendBands,
      isFalse,
    );
    expect(find.text('2 active - Deps hidden'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartLayerToggleStrip.todayMarkerChipKey));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).showTodayMarker,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttTimelineHeader>(
            find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
          )
          .showTodayMarker,
      isFalse,
    );
    expect(find.text('1 active - Deps hidden'), findsOneWidget);
  });

  testWidgets('full gantt chart quick focus presets update chart display', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chart focus'), findsOneWidget);
    expect(find.text('Custom setup'), findsOneWidget);

    final teamPreset = find.byKey(
      GanttChartQuickPresetStrip.presetChipKey(GanttChartQuickPreset.team),
    );
    await tester.ensureVisible(teamPreset);
    await tester.pumpAndSettle();
    await tester.tap(teamPreset);
    await tester.pumpAndSettle();

    var displayPreferences = container.read(
      ganttChartDisplayPreferencesProvider,
    );
    expect(displayPreferences.showTeamAvatars, isTrue);
    expect(displayPreferences.maxTeamAvatars, 4);
    expect(displayPreferences.teamAvatarStyle, GanttTeamAvatarStyle.prominent);
    expect(displayPreferences.timelineZoom, GanttChartTimelineZoom.wide);
    expect(
      container.read(ganttTimelineViewProvider),
      GanttTimelineViewPreset.activeNow,
    );
    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.nextNinetyDays,
    );
    expect(find.text('Team: Active Now, Next 90 Days'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showTaskBarAvatars,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .taskBarAvatar
          .size,
      26,
    );
    final expectedTeamRange = const GanttTimelineRangePresetService().rangeFor(
      preset: GanttTimelineRangePreset.nextNinetyDays,
      tasks: container.read(gantt.tasksProvider),
    );
    expect(
      container.read(gantt.dateRangeProvider).start,
      expectedTeamRange.start,
    );
    expect(container.read(gantt.dateRangeProvider).end, expectedTeamRange.end);

    final milestonePreset = find.byKey(
      GanttChartQuickPresetStrip.presetChipKey(
        GanttChartQuickPreset.milestones,
      ),
    );
    await tester.ensureVisible(milestonePreset);
    await tester.pumpAndSettle();
    await tester.tap(milestonePreset);
    await tester.pumpAndSettle();

    displayPreferences = container.read(ganttChartDisplayPreferencesProvider);
    expect(displayPreferences.showMilestoneLabels, isTrue);
    expect(displayPreferences.showMilestoneDateLabels, isTrue);
    expect(displayPreferences.showDependencyLines, isFalse);
    expect(displayPreferences.showTaskBarProgressLabels, isFalse);
    expect(displayPreferences.density, GanttChartDensity.dense);
    expect(
      container.read(ganttTimelineViewProvider),
      GanttTimelineViewPreset.all,
    );
    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.projectSpan,
    );
    expect(find.text('Milestones: All Tasks, Project Span'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .dependencyLines
          .visible,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .displayOptions
          .showMilestoneLabels,
      isTrue,
    );
    final expectedMilestoneRange = const GanttTimelineRangePresetService()
        .rangeFor(
          preset: GanttTimelineRangePreset.projectSpan,
          tasks: container.read(gantt.tasksProvider),
        );
    expect(
      container.read(gantt.dateRangeProvider).start,
      expectedMilestoneRange.start,
    );
    expect(
      container.read(gantt.dateRangeProvider).end,
      expectedMilestoneRange.end,
    );

    await tester.tap(find.text('Hide Controls'));
    await tester.pumpAndSettle();

    expect(find.text('Show Controls'), findsOneWidget);
    expect(
      find.byKey(GanttChartCompactControlSummary.summaryKey),
      findsOneWidget,
    );
    expect(find.text('Milestones focus'), findsOneWidget);
    expect(find.text('All Tasks / Project Span'), findsOneWidget);
  });

  testWidgets('full gantt chart quick viewport controls update chart scale', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Viewport'), findsOneWidget);
    expect(find.text('Loose rows - Normal scale'), findsOneWidget);
    expect(
      tester.widget<KyGanttChart>(find.byType(KyGanttChart)).rowHeight,
      58,
    );
    expect(tester.widget<KyGanttChart>(find.byType(KyGanttChart)).dayWidth, 42);

    await tester.ensureVisible(
      find.byKey(GanttChartViewportControlStrip.denseRowsChipKey),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(GanttChartViewportControlStrip.denseRowsChipKey),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).density,
      GanttChartDensity.dense,
    );
    expect(find.text('Tight rows - Normal scale'), findsOneWidget);
    expect(
      tester.widget<KyGanttChart>(find.byType(KyGanttChart)).rowHeight,
      44,
    );

    await tester.tap(
      find.byKey(GanttChartViewportControlStrip.wideScaleChipKey),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).timelineZoom,
      GanttChartTimelineZoom.wide,
    );
    expect(find.text('Tight rows - Open scale'), findsOneWidget);
    expect(
      tester.widget<KyGanttChart>(find.byType(KyGanttChart)).dayWidth,
      52.08,
    );

    await tester.tap(
      find.byKey(GanttChartViewportControlStrip.cozyRowsChipKey),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartDisplayPreferencesProvider).density,
      GanttChartDensity.cozy,
    );
    expect(find.text('Steady rows - Open scale'), findsOneWidget);
    expect(
      tester.widget<KyGanttChart>(find.byType(KyGanttChart)).rowHeight,
      50,
    );
  });

  testWidgets('full gantt chart quick edit tools update interactions', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const GanttChartScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit tools'), findsOneWidget);
    expect(find.text('3 active - Day snap'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .enableTaskBarDrag,
      isTrue,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .taskDateRangeValidator,
      isNotNull,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarBlockedDropPattern,
      isTrue,
    );

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.dropTargetChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.dropTargetChipKey));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDropTarget,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDropTarget,
      isFalse,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.leanPreviewChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.leanPreviewChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .dragPreviewDetail,
      GanttDragPreviewDetail.lean,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.impactSummaryChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.impactSummaryChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragImpactSummary,
      isFalse,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.dragPreviewChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.dragPreviewChipKey));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDragPreview,
      isFalse,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.guideDatesChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.guideDatesChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragGuideLabels,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDragGuideLabels,
      isFalse,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.validationWarningsChipKey),
    );
    await tester.tap(
      find.byKey(GanttChartEditToolStrip.validationWarningsChipKey),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showDragValidationBadge,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDragValidationBadge,
      isFalse,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.snapGuidesChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.snapGuidesChipKey));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartInteractionPreferencesProvider).showDragGuides,
      isFalse,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarDragGuides,
      isFalse,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.blockedPatternChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.blockedPatternChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .showBlockedDropPattern,
      isFalse,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .showTaskBarBlockedDropPattern,
      isFalse,
    );

    await tester.tap(find.byKey(GanttChartEditToolStrip.elevatedDepthChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .interactionFeedbackDepth,
      GanttInteractionFeedbackDepth.elevated,
    );
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .taskBarInteractionFeedback
          .opacityScale,
      1.22,
    );
    expect(find.text('3 active - Day snap'), findsOneWidget);

    await tester.ensureVisible(find.byKey(GanttChartEditToolStrip.dragChipKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(GanttChartEditToolStrip.dragChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .enableTaskBarDrag,
      isFalse,
    );
    expect(find.text('2 active - Day snap'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .enableTaskBarDrag,
      isFalse,
    );

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.weekSnapChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.weekSnapChipKey));
    await tester.pumpAndSettle();

    expect(
      container.read(ganttChartInteractionPreferencesProvider).dragSnap,
      KyGanttTaskDragSnap.week,
    );
    expect(find.text('2 active - Week snap'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .dragSnap,
      KyGanttTaskDragSnap.week,
    );

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.guardChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.guardChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .enableScheduleGuard,
      isFalse,
    );
    expect(find.text('1 active - Week snap'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .taskDateRangeValidator,
      isNull,
    );

    await tester.ensureVisible(
      find.byKey(GanttChartEditToolStrip.resizeChipKey),
    );
    await tester.tap(find.byKey(GanttChartEditToolStrip.resizeChipKey));
    await tester.pumpAndSettle();

    expect(
      container
          .read(ganttChartInteractionPreferencesProvider)
          .enableTaskBarResize,
      isFalse,
    );
    expect(find.text('0 active - Week snap'), findsOneWidget);
    expect(
      tester
          .widget<KyGanttChart>(find.byType(KyGanttChart))
          .interactionOptions
          .enableTaskBarResize,
      isFalse,
    );
  });

  testWidgets(
    'full gantt chart opens downstream successors from inspector impact panel',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: GanttChartScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final projectPlanningTile = find.widgetWithText(
        KyGanttTaskListRow,
        'Project Planning',
      );
      await tester.ensureVisible(projectPlanningTile);
      await tester.tap(projectPlanningTile);
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '1');
      expect(find.text('Downstream Impact'), findsOneWidget);

      final inspectDesignButton = find.byKey(
        GanttSuccessorImpactPanel.inspectTaskButtonKey('2'),
      );
      await tester.ensureVisible(inspectDesignButton);
      await tester.tap(inspectDesignButton);
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '2');
      expect(find.text('Design Phase - 4 of 7 visible'), findsOneWidget);
      expect(
        find.text('Current predecessor: Project Planning'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'full gantt chart opens upstream predecessors from inspector chain panel',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: GanttChartScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final designPhaseTile = find.widgetWithText(
        KyGanttTaskListRow,
        'Design Phase',
      );
      await tester.ensureVisible(designPhaseTile);
      await tester.tap(designPhaseTile);
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '2');
      expect(find.text('Dependency Chain'), findsOneWidget);

      final inspectPlanningButton = find.byKey(
        GanttDependencyChainPanel.inspectTaskButtonKey('1'),
      );
      await tester.ensureVisible(inspectPlanningButton);
      await tester.tap(inspectPlanningButton);
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '1');
      expect(find.text('Project Planning - 1 of 7 visible'), findsOneWidget);
      expect(find.text('No upstream dependency chain.'), findsOneWidget);
    },
  );

  testWidgets(
    'full gantt chart navigates visible tasks from inspector header',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: GanttChartScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final projectPlanningTile = find.widgetWithText(
        KyGanttTaskListRow,
        'Project Planning',
      );
      await tester.ensureVisible(projectPlanningTile);
      await tester.tap(projectPlanningTile);
      await tester.pumpAndSettle();

      final previousButton = find.byKey(
        GanttTaskInspectorOverlay.previousTaskButtonKey,
      );
      final nextButton = find.byKey(
        GanttTaskInspectorOverlay.nextTaskButtonKey,
      );

      expect(container.read(gantt.selectedTaskProvider), '1');
      expect(find.text('Project Planning - 1 of 7 visible'), findsOneWidget);
      expect(tester.widget<IconButton>(previousButton).onPressed, isNull);
      expect(
        tester.widget<IconButton>(previousButton).tooltip,
        'No previous visible task',
      );
      expect(tester.widget<IconButton>(nextButton).onPressed, isNotNull);
      expect(
        tester.widget<IconButton>(nextButton).tooltip,
        'Next task: Requirements Gathering',
      );

      final inspectorScrollView = find.byKey(
        GanttTaskInspectorOverlay.contentScrollViewKey,
      );
      final inspectorScrollable = find.descendant(
        of: inspectorScrollView,
        matching: find.byType(Scrollable),
      );
      await tester.drag(inspectorScrollView, const Offset(0, -420));
      await tester.pumpAndSettle();

      expect(
        tester.state<ScrollableState>(inspectorScrollable).position.pixels,
        greaterThan(0),
      );

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '1.1');
      expect(
        find.text('Requirements Gathering - 2 of 7 visible'),
        findsOneWidget,
      );
      expect(
        tester.state<ScrollableState>(inspectorScrollable).position.pixels,
        0,
      );
      expect(find.text('Requirements Gathering'), findsWidgets);
      expect(tester.widget<IconButton>(previousButton).onPressed, isNotNull);
      expect(
        tester.widget<IconButton>(previousButton).tooltip,
        'Previous task: Project Planning',
      );
      expect(
        tester.widget<IconButton>(nextButton).tooltip,
        'Next task: Resource Allocation',
      );

      await tester.tap(previousButton);
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '1');
      expect(find.text('Project Planning'), findsWidgets);

      await _pressShortcut(
        tester,
        modifier: LogicalKeyboardKey.controlLeft,
        trigger: LogicalKeyboardKey.arrowRight,
      );
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '1.1');

      await _pressShortcut(
        tester,
        modifier: LogicalKeyboardKey.controlLeft,
        trigger: LogicalKeyboardKey.arrowLeft,
      );
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '1');

      container.read(gantt.selectedTaskProvider.notifier).state = '5';
      await tester.pumpAndSettle();

      expect(container.read(gantt.selectedTaskProvider), '5');
      expect(find.text('Launch Readiness - 7 of 7 visible'), findsOneWidget);
      expect(
        tester.widget<IconButton>(previousButton).tooltip,
        'Previous task: Testing',
      );
      expect(tester.widget<IconButton>(nextButton).onPressed, isNull);
      expect(
        tester.widget<IconButton>(nextButton).tooltip,
        'No next visible task',
      );
    },
  );

  testWidgets('full gantt chart can dock task inspector at bottom', (
    tester,
  ) async {
    final store = MemoryGanttChartWorkspacePreferencesSnapshotStore();
    final container = ProviderContainer(
      overrides: [
        ganttChartWorkspacePreferencesRepositoryProvider.overrideWithValue(
          GanttChartWorkspacePreferencesRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(gantt.selectedTaskProvider.notifier).state = '1.1';
    container
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setInteractionPreferences(
          GanttChartInteractionPreferences.initial.copyWith(
            inspectorPlacement: GanttTaskInspectorPlacement.bottom,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GanttTaskInspectorOverlay), findsOneWidget);
    expect(find.text('Task Inspector'), findsOneWidget);

    final panelRect = tester.getRect(
      find.byKey(GanttTaskInspectorOverlay.panelKey),
    );
    expect(panelRect.bottom, greaterThan(570));
    expect(panelRect.height, lessThan(400));
    expect(panelRect.left, greaterThan(20));
    expect(panelRect.right, lessThan(780));
  });

  testWidgets('full gantt chart applies timeline range presets', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final rangePresetField = find.byType(
      AppSelectField<GanttTimelineRangePreset>,
    );

    await tester.tap(rangePresetField);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('This Month').last);
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final thisMonthRange = container.read(gantt.dateRangeProvider);

    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.currentMonth,
    );
    expect(thisMonthRange.start, DateTime(now.year, now.month));
    expect(thisMonthRange.end, DateTime(now.year, now.month + 1, 0));

    await tester.tap(rangePresetField);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Attention Window').last);
    await tester.pumpAndSettle();

    final expectedAttentionWindow = const GanttTimelineRangePresetService()
        .rangeFor(
          preset: GanttTimelineRangePreset.attentionWindow,
          tasks: container.read(gantt.tasksProvider),
        );

    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.attentionWindow,
    );
    expect(
      container.read(gantt.dateRangeProvider).start,
      expectedAttentionWindow.start,
    );
    expect(
      container.read(gantt.dateRangeProvider).end,
      expectedAttentionWindow.end,
    );
    expect(find.text('Active focus'), findsOneWidget);
    expect(find.text('Attention Window'), findsWidgets);

    await tester.tap(rangePresetField);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Project Span').last);
    await tester.pumpAndSettle();

    final expectedProjectSpan = const GanttTimelineRangePresetService()
        .rangeFor(
          preset: GanttTimelineRangePreset.projectSpan,
          tasks: container.read(gantt.tasksProvider),
        );

    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.projectSpan,
    );
    expect(
      container.read(gantt.dateRangeProvider).start,
      expectedProjectSpan.start,
    );
    expect(
      container.read(gantt.dateRangeProvider).end,
      expectedProjectSpan.end,
    );
    expect(find.text('Active focus'), findsOneWidget);
    expect(find.text('Project Span'), findsWidgets);

    final todayViewportButton = find.byKey(
      GanttTimelineViewportNavigator.todayButtonKey,
    );
    await tester.ensureVisible(todayViewportButton);
    await tester.pumpAndSettle();
    await tester.tap(todayViewportButton);
    await tester.pumpAndSettle();

    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.planningWindow,
    );

    final fitAllViewportButton = find.byKey(
      GanttTimelineViewportNavigator.fitAllButtonKey,
    );
    await tester.ensureVisible(fitAllViewportButton);
    await tester.pumpAndSettle();
    await tester.tap(fitAllViewportButton);
    await tester.pumpAndSettle();

    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.projectSpan,
    );
    expect(
      container.read(gantt.dateRangeProvider).start,
      expectedProjectSpan.start,
    );
    expect(
      container.read(gantt.dateRangeProvider).end,
      expectedProjectSpan.end,
    );

    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();

    final expectedPlanningWindow = const GanttTimelineRangePresetService()
        .rangeFor(
          preset: GanttTimelineRangePreset.planningWindow,
          tasks: container.read(gantt.tasksProvider),
        );

    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.planningWindow,
    );
    expect(
      container.read(gantt.dateRangeProvider).start,
      expectedPlanningWindow.start,
    );
    expect(
      container.read(gantt.dateRangeProvider).end,
      expectedPlanningWindow.end,
    );
    expect(find.text('Active focus'), findsNothing);
  });

  testWidgets('full gantt chart empty filtered state clears filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: GanttChartScreen())),
    );
    await tester.pumpAndSettle();

    final searchTextField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search timeline tasks',
    );

    await tester.enterText(searchTextField, 'No matching schedule item');
    await tester.pumpAndSettle();

    expect(find.byType(ProjectGanttChartPanel), findsOneWidget);
    expect(find.byType(KyGanttChart), findsNothing);
    expect(find.text('No matching timeline tasks'), findsOneWidget);
    expect(find.text('Clear Timeline Filters'), findsOneWidget);
    expect(
      find.byKey(GanttChartScreen.emptyClearFiltersButtonKey),
      findsOneWidget,
    );

    await tester.tap(find.byKey(GanttChartScreen.emptyClearFiltersButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(KyGanttChart), findsOneWidget);
    expect(find.text('No matching timeline tasks'), findsNothing);
    expect(tester.widget<TextField>(searchTextField).controller?.text, isEmpty);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('full gantt chart reveals selected task hidden by filters', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(gantt.selectedTaskProvider.notifier).state = '1';
    container.read(gantt.searchQueryProvider.notifier).state = 'Testing';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GanttSelectedTaskFocusStrip), findsOneWidget);
    expect(find.text('Hidden by filters'), findsOneWidget);
    expect(find.text('Reveal Task'), findsOneWidget);
    expect(find.byType(GanttTaskInspectorOverlay), findsNothing);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Testing'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(GanttSelectedTaskFocusStrip.revealButtonKey));
    await tester.pumpAndSettle();

    expect(container.read(gantt.searchQueryProvider), isEmpty);
    expect(find.text('Hidden by filters'), findsNothing);
    expect(find.byType(GanttSelectedTaskFocusStrip), findsNothing);
    expect(find.byType(GanttTaskInspectorOverlay), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('full gantt chart focuses and clears a selected task branch', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('ky-gantt-task-bar-1')));
    await tester.pumpAndSettle();

    expect(find.byType(GanttTaskInspectorOverlay), findsOneWidget);
    expect(find.text('Focus Branch'), findsOneWidget);

    await tester.ensureVisible(find.text('Focus Branch'));
    await tester.tap(find.text('Focus Branch'));
    await tester.pumpAndSettle();

    expect(container.read(ganttBranchFocusTaskIdProvider), '1');
    expect(find.text('Branch: Project Planning'), findsOneWidget);
    expect(find.text('3 tasks'), findsWidgets);
    expect(find.text('80% avg'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Requirements Gathering'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Design Phase'),
      ),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Close inspector'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(GanttActiveFocusBar.clearBranchButtonKey));
    await tester.pumpAndSettle();

    expect(container.read(ganttBranchFocusTaskIdProvider), isNull);
    expect(find.text('Branch: Project Planning'), findsNothing);
    expect(find.text('80% avg'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Design Phase'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('full gantt chart hydrates persisted range preset', (
    tester,
  ) async {
    final store = MemoryGanttChartWorkspacePreferencesSnapshotStore();
    await store.write(
      const GanttChartWorkspacePreferences(
        rangePreset: GanttTimelineRangePreset.currentMonth,
        controlsExpanded: false,
      ).toJson(),
    );
    final container = ProviderContainer(
      overrides: [
        ganttChartWorkspacePreferencesRepositoryProvider.overrideWithValue(
          GanttChartWorkspacePreferencesRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final hydratedRange = container.read(gantt.dateRangeProvider);

    expect(
      container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.currentMonth,
    );
    expect(hydratedRange.start, DateTime(now.year, now.month));
    expect(hydratedRange.end, DateTime(now.year, now.month + 1, 0));
    expect(find.text('Active focus'), findsOneWidget);
    expect(find.text('This Month'), findsWidgets);
    expect(find.text('Show Controls'), findsOneWidget);
    expect(
      find.byKey(GanttChartCompactControlSummary.summaryKey),
      findsOneWidget,
    );
    expect(find.text('Custom focus'), findsOneWidget);
    expect(find.text('All Tasks / This Month'), findsOneWidget);
    expect(find.text('3 layers'), findsOneWidget);
    expect(find.text('Loose rows / Normal scale'), findsOneWidget);
    expect(find.text('3 edit tools'), findsOneWidget);
    expect(find.text('Day snap'), findsOneWidget);
    expect(find.byType(AppSelectField<gantt.ViewMode>), findsNothing);
  });

  testWidgets('full gantt chart drags task bars to reschedule work', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final originalTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1.1',
        )!;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final dragGesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-1.1'))),
    );
    await dragGesture.moveBy(const Offset(24, 0));
    await tester.pump();
    await dragGesture.moveBy(const Offset(84, 0));
    await tester.pump();

    final dragPreview = find.byKey(
      const ValueKey('gantt-task-drag-preview-1.1'),
    );
    expect(dragPreview, findsOneWidget);
    expect(
      find.descendant(of: dragPreview, matching: find.textContaining('Move +')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dragPreview, matching: find.textContaining('4d')),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: dragPreview,
        matching: find.textContaining('Moves later'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dragPreview,
        matching: find.textContaining('Day snap'),
      ),
      findsOneWidget,
    );

    await dragGesture.up();
    await tester.pumpAndSettle();

    final movedTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1.1',
        )!;

    expect(
      DateUtils.dateOnly(movedTask.startDate),
      DateUtils.dateOnly(originalTask.startDate).add(const Duration(days: 2)),
    );
    expect(
      DateUtils.dateOnly(movedTask.endDate),
      DateUtils.dateOnly(originalTask.endDate).add(const Duration(days: 2)),
    );
    expect(find.byType(GanttTaskInspectorOverlay), findsNothing);
    expect(
      container.read(gantt.tasksProvider.notifier).recentEdits.first.label,
      'Schedule moved +2d',
    );

    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyZ,
    );
    await tester.pumpAndSettle();

    final revertedTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1.1',
        )!;

    expect(
      DateUtils.dateOnly(revertedTask.startDate),
      DateUtils.dateOnly(originalTask.startDate),
    );
    expect(
      DateUtils.dateOnly(revertedTask.endDate),
      DateUtils.dateOnly(originalTask.endDate),
    );
    expect(
      container.read(gantt.tasksProvider.notifier).recentEdits.first.label,
      'Reverted last edit',
    );
  });

  testWidgets(
    'full gantt chart applies drag preview detail modes while dragging',
    (tester) async {
      final store = MemoryGanttChartWorkspacePreferencesSnapshotStore();
      final container = ProviderContainer(
        overrides: [
          ganttChartWorkspacePreferencesRepositoryProvider.overrideWithValue(
            GanttChartWorkspacePreferencesRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: GanttChartScreen()),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> expectPreviewChrome(
        GanttDragPreviewDetail detail, {
        required bool showsGhostBar,
        required bool showsDeltaStrip,
        required bool showsMetadataPills,
      }) async {
        container
            .read(ganttChartWorkspacePreferencesProvider.notifier)
            .setInteractionPreferences(
              GanttChartInteractionPreferences.initial.copyWith(
                dragPreviewDetail: detail,
              ),
            );
        await tester.pumpAndSettle();

        final chart = tester.widget<KyGanttChart>(find.byType(KyGanttChart));
        expect(chart.interactionOptions.enableTaskBarDrag, isTrue);
        expect(chart.interactionOptions.showTaskBarDragPreview, isTrue);

        final dragGesture = await _startTaskBarDragPreview(tester, '1.1');
        final dragPreview = find.byKey(
          const ValueKey('gantt-task-drag-preview-1.1'),
        );

        expect(dragPreview, findsOneWidget);
        expect(
          find.descendant(
            of: dragPreview,
            matching: find.byKey(GanttTaskDragPreviewGhostBar.barKey),
          ),
          showsGhostBar ? findsOneWidget : findsNothing,
        );
        expect(
          find.descendant(
            of: dragPreview,
            matching: find.byKey(GanttTaskDragPreviewDeltaStrip.stripKey),
          ),
          showsDeltaStrip ? findsOneWidget : findsNothing,
        );
        expect(
          find.descendant(
            of: dragPreview,
            matching: find.textContaining('Day snap'),
          ),
          showsMetadataPills ? findsOneWidget : findsNothing,
        );

        await dragGesture.cancel();
        await tester.pumpAndSettle();
      }

      await expectPreviewChrome(
        GanttDragPreviewDetail.lean,
        showsGhostBar: false,
        showsDeltaStrip: false,
        showsMetadataPills: false,
      );
      await expectPreviewChrome(
        GanttDragPreviewDetail.balanced,
        showsGhostBar: true,
        showsDeltaStrip: false,
        showsMetadataPills: true,
      );
      await expectPreviewChrome(
        GanttDragPreviewDetail.detailed,
        showsGhostBar: true,
        showsDeltaStrip: true,
        showsMetadataPills: true,
      );
    },
  );

  testWidgets('full gantt chart resizes task bars from edge handles', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final originalTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1.1',
        )!;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final resizeHover = await _hoverTaskBar(tester, '1.1');
    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-resize-end-handle-1.1')),
      const Offset(84, 0),
    );
    await resizeHover.removePointer();
    await tester.pumpAndSettle();

    final resizedTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1.1',
        )!;

    expect(
      DateUtils.dateOnly(resizedTask.startDate),
      DateUtils.dateOnly(originalTask.startDate),
    );
    expect(
      DateUtils.dateOnly(resizedTask.endDate),
      DateUtils.dateOnly(originalTask.endDate).add(const Duration(days: 2)),
    );
    expect(find.byType(GanttTaskInspectorOverlay), findsNothing);
    expect(
      container.read(gantt.tasksProvider.notifier).recentEdits.first.label,
      'Finish resized +2d',
    );
    expect(
      find.text('Finish resized +2d - Requirements Gathering'),
      findsOneWidget,
    );
    expect(find.byType(GanttTaskScheduleFeedback), findsOneWidget);
    expect(find.text('Schedule Updated'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await tester.pumpAndSettle();

    final revertedTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1.1',
        )!;

    expect(
      DateUtils.dateOnly(revertedTask.startDate),
      DateUtils.dateOnly(originalTask.startDate),
    );
    expect(
      DateUtils.dateOnly(revertedTask.endDate),
      DateUtils.dateOnly(originalTask.endDate),
    );
    expect(
      container.read(gantt.tasksProvider.notifier).recentEdits.first.label,
      'Reverted last edit',
    );
  });

  testWidgets('full gantt chart can disable schedule edit feedback', (
    tester,
  ) async {
    final store = MemoryGanttChartWorkspacePreferencesSnapshotStore();
    final container = ProviderContainer(
      overrides: [
        ganttChartWorkspacePreferencesRepositoryProvider.overrideWithValue(
          GanttChartWorkspacePreferencesRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setInteractionPreferences(
          GanttChartInteractionPreferences.initial.copyWith(
            showScheduleEditFeedback: false,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final resizeHover = await _hoverTaskBar(tester, '1.1');
    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-resize-end-handle-1.1')),
      const Offset(84, 0),
    );
    await resizeHover.removePointer();
    await tester.pumpAndSettle();

    expect(
      container.read(gantt.tasksProvider.notifier).recentEdits.first.label,
      'Finish resized +2d',
    );
    expect(
      find.text('Finish resized +2d - Requirements Gathering'),
      findsNothing,
    );
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsNothing);
  });

  testWidgets('full gantt chart blocks dependency-breaking date changes', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final originalTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1',
        )!;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-bar-1')),
      const Offset(84, 0),
    );
    await tester.pumpAndSettle();

    final unchangedTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1',
        )!;

    expect(
      DateUtils.dateOnly(unchangedTask.startDate),
      DateUtils.dateOnly(originalTask.startDate),
    );
    expect(
      DateUtils.dateOnly(unchangedTask.endDate),
      DateUtils.dateOnly(originalTask.endDate),
    );
    expect(container.read(gantt.tasksProvider.notifier).recentEdits, isEmpty);
    expect(find.byType(GanttTaskScheduleGuardFeedback), findsOneWidget);
    expect(find.text('Schedule Guard'), findsOneWidget);
    expect(
      find.text('Would overlap Design Phase - Project Planning'),
      findsOneWidget,
    );
    expect(find.widgetWithText(SnackBarAction, 'Review'), findsOneWidget);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Review'));
    await tester.pumpAndSettle();

    expect(container.read(gantt.selectedTaskProvider), '1');
    expect(find.byType(GanttTaskInspectorOverlay), findsOneWidget);
  });

  testWidgets('full gantt chart can hide dependency connectors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: GanttChartScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(KyGanttDependencyLayer.defaultLayerKey), findsOneWidget);

    await tester.tap(find.text('View Settings'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Dependency Lines'));
    await tester.tap(find.text('Dependency Lines'));
    await tester.pumpAndSettle();

    expect(find.byKey(KyGanttDependencyLayer.defaultLayerKey), findsNothing);
  });

  testWidgets('gantt screen applies saved timeline views', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: GanttChartScreen())),
    );
    await tester.pumpAndSettle();

    final activeNowChip = find.widgetWithText(ChoiceChip, 'Active Now');
    await tester.ensureVisible(activeNowChip);
    await tester.tap(activeNowChip);
    await tester.pump();

    expect(find.text('Active focus'), findsOneWidget);
    expect(find.text('Active Now'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Testing'),
      ),
      findsNothing,
    );

    await tester.tap(find.text('Clear Filters'));
    await tester.pump();

    expect(find.text('Active focus'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Testing'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('gantt screen applies initial project focus and clears filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GanttChartScreen(
            initialProjectId: 'mobile-field-app',
            initialTaskId: '3',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active focus'), findsOneWidget);
    expect(find.text('Mobile Field App'), findsWidgets);
    expect(find.text('Development'), findsWidgets);
    expect(find.text('Open Project'), findsOneWidget);
    expect(find.text('Clear Selection'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsNothing,
    );

    await tester.ensureVisible(find.text('Clear Selection'));
    await tester.tap(find.text('Clear Selection'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Clear Filters'));
    await tester.tap(find.text('Clear Filters'));
    await tester.pump();

    expect(find.text('Active focus'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Project Planning'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('gantt screen reveals hidden tasks from recent edit activity', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(gantt.tasksProvider.notifier).updateTaskProgress('3', 0.4);
    container.read(gantt.selectedTaskProvider.notifier).state = '1';
    container.read(gantt.searchQueryProvider.notifier).state =
        'Project Planning';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GanttChartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active focus'), findsOneWidget);
    expect(container.read(gantt.searchQueryProvider), 'Project Planning');
    expect(container.read(gantt.selectedTaskProvider), '1');
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Development'),
      ),
      findsNothing,
    );

    await tester.ensureVisible(find.text('Progress changed to 40%'));
    await tester.tap(find.text('Progress changed to 40%'));
    await tester.pumpAndSettle();

    expect(container.read(gantt.searchQueryProvider), isEmpty);
    expect(container.read(gantt.selectedTaskProvider), '3');
    expect(find.text('Active focus'), findsNothing);
    expect(find.text('Mobile Field App'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(KyGanttTaskListRow),
        matching: find.text('Development'),
      ),
      findsOneWidget,
    );
  });
}

Future<void> _pressShortcut(
  WidgetTester tester, {
  required LogicalKeyboardKey modifier,
  required LogicalKeyboardKey trigger,
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(modifier);
  if (shift) {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  }
  await tester.sendKeyEvent(trigger);
  if (shift) {
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  }
  await tester.sendKeyUpEvent(modifier);
}

Future<TestGesture> _hoverTaskBar(WidgetTester tester, String taskId) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer();
  await gesture.moveTo(
    tester.getCenter(find.byKey(ValueKey('ky-gantt-task-bar-$taskId'))),
  );
  await tester.pump();
  return gesture;
}

Future<TestGesture> _startTaskBarDragPreview(
  WidgetTester tester,
  String taskId,
) async {
  final taskBar = find.byKey(ValueKey('ky-gantt-task-bar-$taskId'));
  await tester.ensureVisible(taskBar);
  await tester.pump();

  final dragGesture = await tester.startGesture(tester.getCenter(taskBar));
  await dragGesture.moveBy(const Offset(24, 0));
  await tester.pump();
  await dragGesture.moveBy(const Offset(84, 0));
  await tester.pump();
  return dragGesture;
}
