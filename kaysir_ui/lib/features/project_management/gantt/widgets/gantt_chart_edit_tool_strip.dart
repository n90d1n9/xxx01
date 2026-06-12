import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../services/gantt_chart_control_label_service.dart';
import '../services/gantt_chart_edit_tool_presentation_service.dart';
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_control_strip_primitives.dart';

/// Toggle strip for direct Gantt taskbar editing tools and snap settings.
class GanttChartEditToolStrip extends StatelessWidget {
  const GanttChartEditToolStrip({
    required this.interactionPreferences,
    required this.onChanged,
    super.key,
  });

  static const dragChipKey = ganttChartEditToolDragChipKey;
  static const resizeChipKey = ganttChartEditToolResizeChipKey;
  static const guardChipKey = ganttChartEditToolGuardChipKey;
  static const blockedPatternChipKey = ganttChartEditToolBlockedPatternChipKey;
  static const dropTargetChipKey = ganttChartEditToolDropTargetChipKey;
  static const dragPreviewChipKey = ganttChartEditToolDragPreviewChipKey;
  static const impactSummaryChipKey = ganttChartEditToolImpactSummaryChipKey;
  static const snapGuidesChipKey = ganttChartEditToolSnapGuidesChipKey;
  static const guideDatesChipKey = ganttChartEditToolGuideDatesChipKey;
  static const validationWarningsChipKey =
      ganttChartEditToolValidationWarningsChipKey;
  static const daySnapChipKey = ganttChartEditToolDaySnapChipKey;
  static const weekSnapChipKey = ganttChartEditToolWeekSnapChipKey;
  static const subtleDepthChipKey = ganttChartEditToolSubtleDepthChipKey;
  static const balancedDepthChipKey = ganttChartEditToolBalancedDepthChipKey;
  static const elevatedDepthChipKey = ganttChartEditToolElevatedDepthChipKey;
  static const leanPreviewChipKey = ganttChartEditToolLeanPreviewChipKey;
  static const balancedPreviewChipKey =
      ganttChartEditToolBalancedPreviewChipKey;
  static const detailedPreviewChipKey =
      ganttChartEditToolDetailedPreviewChipKey;

  final GanttChartInteractionPreferences interactionPreferences;
  final ValueChanged<GanttChartInteractionPreferences> onChanged;

  @override
  Widget build(BuildContext context) {
    final snapEnabled =
        interactionPreferences.enableTaskBarDrag ||
        interactionPreferences.enableTaskBarResize;
    final previewEnabled =
        snapEnabled && interactionPreferences.showDragPreview;
    final previewDetailEnabled =
        previewEnabled && interactionPreferences.showDragImpactSummary;
    final guidedFeedbackEnabled =
        snapEnabled && interactionPreferences.showDragGuides;

    return GanttControlStripShell(
      title: 'Edit tools',
      subtitle: ganttChartEditToolStripSubtitleLabel(interactionPreferences),
      icon: Icons.edit_outlined,
      accent: GanttControlAccent.tertiary,
      spacing: 16,
      children: [
        _toolChip(
          role: GanttChartEditToolRole.drag,
          selected: interactionPreferences.enableTaskBarDrag,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(enableTaskBarDrag: value),
              ),
        ),
        _toolChip(
          role: GanttChartEditToolRole.resize,
          selected: interactionPreferences.enableTaskBarResize,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(enableTaskBarResize: value),
              ),
        ),
        _toolChip(
          role: GanttChartEditToolRole.scheduleGuard,
          selected: interactionPreferences.enableScheduleGuard,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(enableScheduleGuard: value),
              ),
        ),
        GanttControlToggleChip(
          key: dropTargetChipKey,
          label: 'Target',
          tooltip: 'Highlight the projected landing range',
          icon: Icons.ads_click_outlined,
          selected: interactionPreferences.showDropTarget,
          enabled: snapEnabled,
          accent: GanttControlAccent.tertiary,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(showDropTarget: value),
              ),
        ),
        GanttControlToggleChip(
          key: blockedPatternChipKey,
          label: 'Pattern',
          tooltip: 'Show striped feedback on blocked date changes',
          icon: Icons.block_rounded,
          selected: interactionPreferences.showBlockedDropPattern,
          enabled: snapEnabled,
          accent: GanttControlAccent.tertiary,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(showBlockedDropPattern: value),
              ),
        ),
        GanttControlToggleChip(
          key: dragPreviewChipKey,
          label: 'Preview',
          tooltip: 'Show live drag preview card',
          icon: Icons.preview_outlined,
          selected: interactionPreferences.showDragPreview,
          enabled: snapEnabled,
          accent: GanttControlAccent.tertiary,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(showDragPreview: value),
              ),
        ),
        GanttControlToggleChip(
          key: impactSummaryChipKey,
          label: 'Impact',
          tooltip: 'Show before and after drag preview summary',
          icon: Icons.compare_arrows_rounded,
          selected: interactionPreferences.showDragImpactSummary,
          enabled: previewEnabled,
          accent: GanttControlAccent.tertiary,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(showDragImpactSummary: value),
              ),
        ),
        GanttControlToggleChip(
          key: snapGuidesChipKey,
          label: 'Guides',
          tooltip: 'Show snap guide lines while editing',
          icon: Icons.straighten_rounded,
          selected: interactionPreferences.showDragGuides,
          enabled: snapEnabled,
          accent: GanttControlAccent.tertiary,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(showDragGuides: value),
              ),
        ),
        GanttControlToggleChip(
          key: guideDatesChipKey,
          label: 'Dates',
          tooltip: 'Label snap guides with proposed dates',
          icon: Icons.date_range_outlined,
          selected: interactionPreferences.showDragGuideLabels,
          enabled: guidedFeedbackEnabled,
          accent: GanttControlAccent.tertiary,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(showDragGuideLabels: value),
              ),
        ),
        GanttControlToggleChip(
          key: validationWarningsChipKey,
          label: 'Warnings',
          tooltip: 'Show blocked edit reasons while dragging',
          icon: Icons.warning_amber_rounded,
          selected: interactionPreferences.showDragValidationBadge,
          enabled: guidedFeedbackEnabled,
          accent: GanttControlAccent.tertiary,
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(showDragValidationBadge: value),
              ),
        ),
        GanttControlChipGroup<GanttDragPreviewDetail>(
          label: 'Detail',
          value: interactionPreferences.dragPreviewDetail,
          enabled: previewDetailEnabled,
          accent: GanttControlAccent.tertiary,
          options: [
            for (final presentation in ganttChartEditPreviewDetailPresentations)
              GanttControlChipOption(
                key: presentation.key,
                value: presentation.detail,
                label: presentation.label,
                icon: presentation.icon,
                tooltip: presentation.tooltip,
              ),
          ],
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(dragPreviewDetail: value),
              ),
        ),
        GanttControlChipGroup<GanttInteractionFeedbackDepth>(
          label: 'Depth',
          value: interactionPreferences.interactionFeedbackDepth,
          enabled: snapEnabled,
          accent: GanttControlAccent.tertiary,
          options: [
            for (final presentation in ganttChartEditFeedbackDepthPresentations)
              GanttControlChipOption(
                key: presentation.key,
                value: presentation.depth,
                label: presentation.label,
                icon: presentation.icon,
                tooltip: presentation.tooltip,
              ),
          ],
          onChanged:
              (value) => onChanged(
                interactionPreferences.copyWith(
                  interactionFeedbackDepth: value,
                ),
              ),
        ),
        GanttControlChipGroup<ky.KyGanttTaskDragSnap>(
          label: 'Snap',
          value: interactionPreferences.dragSnap,
          enabled: snapEnabled,
          accent: GanttControlAccent.tertiary,
          options: [
            for (final presentation in ganttChartEditSnapPresentations)
              GanttControlChipOption(
                key: presentation.key,
                value: presentation.snap,
                label: presentation.label,
                icon: presentation.icon,
                tooltip: presentation.tooltip,
              ),
          ],
          onChanged:
              (value) =>
                  onChanged(interactionPreferences.copyWith(dragSnap: value)),
        ),
      ],
    );
  }

  Widget _toolChip({
    required GanttChartEditToolRole role,
    required bool selected,
    required ValueChanged<bool> onChanged,
  }) {
    final presentation = ganttChartEditToolPresentation(role);

    return GanttControlToggleChip(
      key: presentation.key,
      label: presentation.label,
      tooltip: presentation.tooltip,
      icon: presentation.icon,
      selected: selected,
      accent: GanttControlAccent.tertiary,
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Gantt chart edit tool strip')
Widget ganttChartEditToolStripPreview() {
  var preferences = GanttChartInteractionPreferences.initial;

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return GanttChartEditToolStrip(
                interactionPreferences: preferences,
                onChanged: (value) => setState(() => preferences = value),
              );
            },
          ),
        ),
      ),
    ),
  );
}
