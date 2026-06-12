import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_display_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_view_profile_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  const service = GanttChartViewProfileService();

  group('GanttChartViewProfileService', () {
    test('resolves the default planner profile', () {
      expect(
        service.profileFor(
          displayPreferences: GanttChartDisplayPreferences.initial,
          interactionPreferences: GanttChartInteractionPreferences.initial,
        ),
        GanttChartViewProfile.planner,
      );
    });

    test('builds a team planning profile with avatars and weekly snap', () {
      final snapshot = service.snapshotFor(GanttChartViewProfile.team);

      expect(
        snapshot.displayPreferences,
        GanttChartDisplayPresetService.presentationPreferences,
      );
      expect(snapshot.displayPreferences.showTeamAvatars, isTrue);
      expect(snapshot.displayPreferences.maxTeamAvatars, 4);
      expect(
        snapshot.displayPreferences.teamAvatarStyle,
        GanttTeamAvatarStyle.prominent,
      );
      expect(snapshot.displayPreferences.density, GanttChartDensity.cozy);
      expect(
        snapshot.displayPreferences.timelineZoom,
        GanttChartTimelineZoom.wide,
      );
      expect(
        snapshot.interactionPreferences.dragSnap,
        KyGanttTaskDragSnap.week,
      );
      expect(
        snapshot.interactionPreferences.interactionFeedbackDepth,
        GanttInteractionFeedbackDepth.elevated,
      );
      expect(
        service.profileFor(
          displayPreferences: snapshot.displayPreferences,
          interactionPreferences: snapshot.interactionPreferences,
        ),
        GanttChartViewProfile.team,
      );
    });

    test('builds a review profile without timeline orientation chrome', () {
      final snapshot = service.snapshotFor(GanttChartViewProfile.review);

      expect(
        snapshot.displayPreferences,
        GanttChartDisplayPresetService.reviewPreferences,
      );
      expect(snapshot.displayPreferences.showTodayMarker, isFalse);
      expect(snapshot.displayPreferences.showTaskBarShadows, isFalse);
      expect(snapshot.displayPreferences.showSelectedTaskFocus, isFalse);
      expect(snapshot.displayPreferences.showTaskBarDateLabels, isFalse);
      expect(snapshot.displayPreferences.showTaskBarDurationLabels, isFalse);
      expect(snapshot.displayPreferences.showTaskBarDependencyBadges, isFalse);
      expect(
        snapshot.displayPreferences.showTaskBarDependencyConflictBadges,
        isFalse,
      );
      expect(snapshot.displayPreferences.showTaskBarProgressLabels, isFalse);
      expect(snapshot.displayPreferences.showTaskBarStatusLabels, isFalse);
      expect(snapshot.displayPreferences.showTaskBarScheduleBadges, isFalse);
      expect(snapshot.displayPreferences.showMilestoneLabels, isFalse);
      expect(snapshot.displayPreferences.showMilestoneDateLabels, isFalse);
      expect(snapshot.displayPreferences.density, GanttChartDensity.dense);
      expect(snapshot.interactionPreferences.showDragGuides, isFalse);
      expect(snapshot.interactionPreferences.showDragImpactSummary, isFalse);
      expect(
        snapshot.interactionPreferences.dragPreviewDetail,
        GanttDragPreviewDetail.lean,
      );
      expect(snapshot.interactionPreferences.showDragGuideLabels, isFalse);
      expect(snapshot.interactionPreferences.showDragValidationBadge, isFalse);
      expect(snapshot.interactionPreferences.showDropTarget, isFalse);
      expect(snapshot.interactionPreferences.showBlockedDropPattern, isFalse);
      expect(snapshot.interactionPreferences.showInteractionLift, isFalse);
      expect(snapshot.interactionPreferences.showInteractionGhost, isFalse);
      expect(snapshot.interactionPreferences.showHoverFocusRing, isFalse);
      expect(snapshot.interactionPreferences.showDragHandle, isFalse);
      expect(
        snapshot.interactionPreferences.interactionFeedbackDepth,
        GanttInteractionFeedbackDepth.subtle,
      );
      expect(
        snapshot.interactionPreferences.resizeHandleVisibility,
        KyGanttTaskResizeHandleVisibility.focused,
      );
      expect(
        service.profileFor(
          displayPreferences: snapshot.displayPreferences,
          interactionPreferences: snapshot.interactionPreferences,
        ),
        GanttChartViewProfile.review,
      );
    });

    test('marks unmatched preference bundles as custom', () {
      expect(
        service.profileFor(
          displayPreferences: GanttChartDisplayPreferences.initial.copyWith(
            showTeamAvatars: true,
          ),
          interactionPreferences: GanttChartInteractionPreferences.initial,
        ),
        GanttChartViewProfile.custom,
      );
    });
  });
}
