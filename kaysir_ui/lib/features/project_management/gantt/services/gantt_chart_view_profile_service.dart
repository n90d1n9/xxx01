import 'package:ky_gantt/ky_gantt.dart' as ky;

import 'gantt_chart_display_preset_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';

/// Coordinated display and interaction presets for the Gantt chart.
enum GanttChartViewProfile { planner, team, review, custom }

/// Immutable display and interaction bundle for a view profile.
class GanttChartViewProfileSnapshot {
  const GanttChartViewProfileSnapshot({
    required this.displayPreferences,
    required this.interactionPreferences,
  });

  final GanttChartDisplayPreferences displayPreferences;
  final GanttChartInteractionPreferences interactionPreferences;
}

/// Resolves Gantt view profiles to preference snapshots and back again.
class GanttChartViewProfileService {
  const GanttChartViewProfileService();

  static const presetProfiles = [
    GanttChartViewProfile.planner,
    GanttChartViewProfile.team,
    GanttChartViewProfile.review,
  ];

  GanttChartViewProfile profileFor({
    required GanttChartDisplayPreferences displayPreferences,
    required GanttChartInteractionPreferences interactionPreferences,
  }) {
    for (final profile in presetProfiles) {
      final snapshot = snapshotFor(profile);
      if (snapshot.displayPreferences == displayPreferences &&
          snapshot.interactionPreferences == interactionPreferences) {
        return profile;
      }
    }

    return GanttChartViewProfile.custom;
  }

  GanttChartViewProfileSnapshot snapshotFor(GanttChartViewProfile profile) {
    switch (profile) {
      case GanttChartViewProfile.planner:
        return const GanttChartViewProfileSnapshot(
          displayPreferences:
              GanttChartDisplayPresetService.balancedPreferences,
          interactionPreferences: GanttChartInteractionPreferences.initial,
        );
      case GanttChartViewProfile.team:
        return const GanttChartViewProfileSnapshot(
          displayPreferences:
              GanttChartDisplayPresetService.presentationPreferences,
          interactionPreferences: GanttChartInteractionPreferences(
            dragSnap: ky.KyGanttTaskDragSnap.week,
            interactionFeedbackDepth: GanttInteractionFeedbackDepth.elevated,
          ),
        );
      case GanttChartViewProfile.review:
        return const GanttChartViewProfileSnapshot(
          displayPreferences: GanttChartDisplayPresetService.reviewPreferences,
          interactionPreferences: GanttChartInteractionPreferences(
            enableTaskBarDrag: false,
            enableTaskBarResize: false,
            dragSnap: ky.KyGanttTaskDragSnap.week,
            showDragPreview: false,
            showDragImpactSummary: false,
            dragPreviewDetail: GanttDragPreviewDetail.lean,
            showDragGuides: false,
            showDragGuideLabels: false,
            showDragValidationBadge: false,
            showDropTarget: false,
            showBlockedDropPattern: false,
            showInteractionLift: false,
            showInteractionGhost: false,
            showHoverFocusRing: false,
            showDragHandle: false,
            interactionFeedbackDepth: GanttInteractionFeedbackDepth.subtle,
            resizeHandleVisibility:
                ky.KyGanttTaskResizeHandleVisibility.focused,
          ),
        );
      case GanttChartViewProfile.custom:
        throw ArgumentError.value(profile, 'profile', 'Custom has no snapshot');
    }
  }
}
