import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../services/gantt_task_drag_preview_label_service.dart';
import 'gantt_task_drag_preview_delta_strip.dart';
import 'gantt_task_drag_preview_ghost_bar.dart';
import 'gantt_task_drag_preview_visuals.dart';

class GanttTaskDragPreviewCard extends StatelessWidget {
  const GanttTaskDragPreviewCard({
    required this.preview,
    this.showImpactSummary = true,
    this.showMetadataPills = true,
    this.showGhostBar = true,
    this.showDeltaStrip = true,
    super.key,
  });

  static const summarySemanticsKey = ValueKey(
    'gantt-task-drag-preview-summary-semantics',
  );
  static const statusRailKey = ValueKey('gantt-task-drag-preview-status-rail');

  final ky.KyGanttTaskDragPreview preview;
  final bool showImpactSummary;
  final bool showMetadataPills;
  final bool showGhostBar;
  final bool showDeltaStrip;

  @override
  Widget build(BuildContext context) {
    final visuals = GanttTaskDragPreviewVisuals.from(
      Theme.of(context).colorScheme,
      preview.validation,
    );
    final validationMessage = preview.validation.message;

    return Semantics(
      key: summarySemanticsKey,
      label: ganttTaskDragPreviewSummaryLabel(
        preview,
        includeImpact: showImpactSummary,
      ),
      child: Material(
        key: ValueKey('gantt-task-drag-preview-${preview.task.id}'),
        color: Colors.transparent,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          scale: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: visuals.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: visuals.border),
              boxShadow: [
                BoxShadow(
                  color: visuals.shadow,
                  blurRadius: visuals.shadowBlur,
                  offset: visuals.shadowOffset,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: ColoredBox(
                      key: statusRailKey,
                      color: visuals.accent,
                      child: const SizedBox(width: 4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _PreviewIcon(visuals: visuals),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 260),
                              child: _PreviewTextBlock(
                                title: ganttTaskDragPreviewTitle(preview),
                                subtitle:
                                    showImpactSummary
                                        ? ganttTaskDragPreviewRangeShiftLabel(
                                          preview,
                                        )
                                        : ganttTaskDragPreviewMetadataLabel(
                                          preview,
                                        ),
                                color: visuals.foreground,
                              ),
                            ),
                            if (showImpactSummary && showMetadataPills) ...[
                              _PreviewStatusPill(
                                label: ganttTaskDragPreviewImpactLabel(preview),
                                visuals: visuals,
                              ),
                              _PreviewStatusPill(
                                label: preview.durationLabel,
                                visuals: visuals,
                              ),
                              _PreviewStatusPill(
                                label: preview.snapLabel,
                                visuals: visuals,
                              ),
                            ],
                            _PreviewStatusPill(
                              label: ganttTaskDragPreviewValidationTitle(
                                preview.validation,
                              ),
                              visuals: visuals,
                            ),
                            if (validationMessage != null &&
                                validationMessage.isNotEmpty) ...[
                              _PreviewDivider(visuals: visuals),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 220,
                                ),
                                child: _PreviewTextBlock(
                                  title: ganttTaskDragPreviewValidationTitle(
                                    preview.validation,
                                  ),
                                  subtitle: validationMessage,
                                  color: visuals.foreground,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (showImpactSummary && showGhostBar) ...[
                          const SizedBox(height: 8),
                          GanttTaskDragPreviewGhostBar(
                            preview: preview,
                            visuals: visuals,
                          ),
                        ],
                        if (showImpactSummary && showDeltaStrip) ...[
                          const SizedBox(height: 8),
                          GanttTaskDragPreviewDeltaStrip(
                            preview: preview,
                            visuals: visuals,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  const _PreviewIcon({required this.visuals});

  final GanttTaskDragPreviewVisuals visuals;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: visuals.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(visuals.icon, size: 16, color: visuals.accent),
    );
  }
}

class _PreviewTextBlock extends StatelessWidget {
  const _PreviewTextBlock({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.76),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PreviewStatusPill extends StatelessWidget {
  const _PreviewStatusPill({required this.label, required this.visuals});

  final String label;
  final GanttTaskDragPreviewVisuals visuals;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visuals.accent.withValues(alpha: 0.14),
        border: Border.all(color: visuals.accent.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: visuals.foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PreviewDivider extends StatelessWidget {
  const _PreviewDivider({required this.visuals});

  final GanttTaskDragPreviewVisuals visuals;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: visuals.foreground.withValues(alpha: 0.18),
    );
  }
}
