import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_toggle_row.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../services/gantt_drag_preview_detail_presentation_service.dart';
import '../services/gantt_interaction_feedback_depth_presentation_service.dart';
import '../services/gantt_interaction_segment_presentation_service.dart';
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_segmented_option_tile.dart';

List<Widget> ganttChartInteractionOptionTiles({
  required BuildContext context,
  required GanttChartInteractionPreferences interactionPreferences,
  required ValueChanged<GanttChartInteractionPreferences> onInteractionChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final hasTimelineEditing =
      interactionPreferences.enableTaskBarDrag ||
      interactionPreferences.enableTaskBarResize;
  final hasInteractionChrome =
      interactionPreferences.showDropTarget ||
      interactionPreferences.showBlockedDropPattern ||
      interactionPreferences.showInteractionLift ||
      interactionPreferences.showInteractionGhost ||
      interactionPreferences.showHoverFocusRing;

  return [
    AppToggleRow(
      title: 'Drag Dates',
      subtitle: 'Move taskbars to reschedule work',
      icon: Icons.open_with_rounded,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.enableTaskBarDrag,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(enableTaskBarDrag: value),
          ),
    ),
    AppToggleRow(
      title: 'Drag Preview',
      subtitle: 'Show the live schedule while dragging',
      icon: Icons.preview_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showDragPreview,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          interactionPreferences.enableTaskBarDrag
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showDragPreview: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Impact Summary',
      subtitle: 'Show before and after range while dragging',
      icon: Icons.compare_arrows_rounded,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showDragImpactSummary,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          interactionPreferences.showDragPreview && hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showDragImpactSummary: value),
              )
              : null,
    ),
    GanttSegmentedOptionTile<GanttDragPreviewDetail>(
      title: 'Preview Detail',
      subtitle: ganttDragPreviewDetailSettingsSubtitle(),
      icon: Icons.ballot_outlined,
      value: interactionPreferences.dragPreviewDetail,
      enabled:
          interactionPreferences.showDragPreview &&
          interactionPreferences.showDragImpactSummary &&
          hasTimelineEditing,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttDragPreviewDetailPresentations)
          ButtonSegment(
            value: presentation.detail,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(dragPreviewDetail: value),
          ),
    ),
    AppToggleRow(
      title: 'Drop Target',
      subtitle: 'Highlight the projected landing range',
      icon: Icons.ads_click_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showDropTarget,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showDropTarget: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Blocked Pattern',
      subtitle: 'Stripe blocked landing ranges before drop',
      icon: Icons.block_rounded,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showBlockedDropPattern,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showBlockedDropPattern: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Drag Lift',
      subtitle: 'Add lift shadow while editing bars',
      icon: Icons.layers_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showInteractionLift,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showInteractionLift: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Hover Focus',
      subtitle: 'Outline editable bars on hover',
      icon: Icons.center_focus_weak_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showHoverFocusRing,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showHoverFocusRing: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Edit Ghost',
      subtitle: 'Keep the original bar visible while editing',
      icon: Icons.motion_photos_on_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showInteractionGhost,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showInteractionGhost: value),
              )
              : null,
    ),
    GanttSegmentedOptionTile<GanttInteractionFeedbackDepth>(
      title: 'Feedback Depth',
      subtitle: ganttInteractionFeedbackDepthSettingsSubtitle(),
      icon: Icons.blur_on_rounded,
      value: interactionPreferences.interactionFeedbackDepth,
      enabled: hasTimelineEditing && hasInteractionChrome,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttInteractionFeedbackDepthPresentations)
          ButtonSegment(
            value: presentation.depth,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(interactionFeedbackDepth: value),
          ),
    ),
    AppToggleRow(
      title: 'Snap Guides',
      subtitle: 'Show date guide lines while editing',
      icon: Icons.straighten_rounded,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showDragGuides,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showDragGuides: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Guide Dates',
      subtitle: 'Label guide lines with proposed dates',
      icon: Icons.date_range_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showDragGuideLabels,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          interactionPreferences.showDragGuides && hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showDragGuideLabels: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Edit Warnings',
      subtitle: 'Show blocked edit reasons on chart',
      icon: Icons.warning_amber_rounded,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showDragValidationBadge,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          interactionPreferences.showDragGuides && hasTimelineEditing
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showDragValidationBadge: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Drag Handle',
      subtitle: 'Show a grip on active taskbars',
      icon: Icons.drag_indicator_rounded,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showDragHandle,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          interactionPreferences.enableTaskBarDrag
              ? (value) => onInteractionChanged(
                interactionPreferences.copyWith(showDragHandle: value),
              )
              : null,
    ),
    AppToggleRow(
      title: 'Resize Edges',
      subtitle: 'Adjust start and finish from bar edges',
      icon: Icons.open_in_full_rounded,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.enableTaskBarResize,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(enableTaskBarResize: value),
          ),
    ),
    GanttSegmentedOptionTile<ky.KyGanttTaskResizeHandleVisibility>(
      title: 'Resize Grips',
      subtitle: ganttResizeHandleVisibilitySettingsSubtitle(),
      icon: Icons.drag_handle_rounded,
      value: interactionPreferences.resizeHandleVisibility,
      enabled: interactionPreferences.enableTaskBarResize,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttResizeHandleVisibilityPresentations)
          ButtonSegment(
            value: presentation.visibility,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(resizeHandleVisibility: value),
          ),
    ),
    AppToggleRow(
      title: 'Schedule Guard',
      subtitle: 'Block dependency-breaking date changes',
      icon: Icons.verified_user_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.enableScheduleGuard,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(enableScheduleGuard: value),
          ),
    ),
    AppToggleRow(
      title: 'Edit Feedback',
      subtitle: 'Confirm schedule edits with Undo',
      icon: Icons.feedback_outlined,
      contained: true,
      iconBadge: true,
      value: interactionPreferences.showScheduleEditFeedback,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(showScheduleEditFeedback: value),
          ),
    ),
    GanttSegmentedOptionTile<ky.KyGanttTaskDragSnap>(
      title: 'Snap Mode',
      subtitle: ganttDragSnapSettingsSubtitle(),
      icon: Icons.grid_4x4_outlined,
      value: interactionPreferences.dragSnap,
      enabled: hasTimelineEditing,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttDragSnapPresentations)
          ButtonSegment(
            value: presentation.snap,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(dragSnap: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttTaskInspectorPlacement>(
      title: 'Inspector',
      subtitle: ganttInspectorPlacementSettingsSubtitle(),
      icon: Icons.vertical_align_bottom,
      value: interactionPreferences.inspectorPlacement,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttInspectorPlacementPresentations)
          ButtonSegment(
            value: presentation.placement,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onInteractionChanged(
            interactionPreferences.copyWith(inspectorPlacement: value),
          ),
    ),
  ];
}
