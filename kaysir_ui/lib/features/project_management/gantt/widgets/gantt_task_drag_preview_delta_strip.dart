import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../services/gantt_task_drag_preview_delta_service.dart';
import 'gantt_task_drag_preview_visuals.dart';

class GanttTaskDragPreviewDeltaStrip extends StatelessWidget {
  const GanttTaskDragPreviewDeltaStrip({
    required this.preview,
    required this.visuals,
    super.key,
  });

  static const stripKey = ValueKey('gantt-task-drag-preview-delta-strip');

  final ky.KyGanttTaskDragPreview preview;
  final GanttTaskDragPreviewVisuals visuals;

  @override
  Widget build(BuildContext context) {
    final summary = ganttTaskDragPreviewDeltaSummary(preview);

    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          key: stripKey,
          decoration: BoxDecoration(
            color: visuals.foreground.withValues(alpha: 0.06),
            border: Border.all(
              color: visuals.foreground.withValues(alpha: 0.10),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.hasBoundedWidth && constraints.maxWidth < 330) {
                  return _CompactDeltaStrip(summary: summary, visuals: visuals);
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: _RangeChip(
                        eyebrow: 'Before',
                        label: summary.beforeLabel,
                        visuals: visuals,
                      ),
                    ),
                    _DeltaConnector(summary: summary, visuals: visuals),
                    Expanded(
                      child: _RangeChip(
                        eyebrow: 'After',
                        label: summary.afterLabel,
                        visuals: visuals,
                        emphasized: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactDeltaStrip extends StatelessWidget {
  const _CompactDeltaStrip({required this.summary, required this.visuals});

  final GanttTaskDragPreviewDeltaSummary summary;
  final GanttTaskDragPreviewVisuals visuals;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RangeChip(
          eyebrow: 'Before',
          label: summary.beforeLabel,
          visuals: visuals,
        ),
        const SizedBox(height: 6),
        _DeltaConnector(summary: summary, visuals: visuals, compact: true),
        const SizedBox(height: 6),
        _RangeChip(
          eyebrow: 'After',
          label: summary.afterLabel,
          visuals: visuals,
          emphasized: true,
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.eyebrow,
    required this.label,
    required this.visuals,
    this.emphasized = false,
  });

  final String eyebrow;
  final String label;
  final GanttTaskDragPreviewVisuals visuals;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            emphasized
                ? visuals.accent.withValues(alpha: 0.14)
                : visuals.background.withValues(alpha: 0.28),
        border: Border.all(
          color:
              emphasized
                  ? visuals.accent.withValues(alpha: 0.24)
                  : visuals.foreground.withValues(alpha: 0.08),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: visuals.foreground.withValues(alpha: 0.58),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: visuals.foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaConnector extends StatelessWidget {
  const _DeltaConnector({
    required this.summary,
    required this.visuals,
    this.compact = false,
  });

  final GanttTaskDragPreviewDeltaSummary summary;
  final GanttTaskDragPreviewVisuals visuals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final icon =
        summary.hasDateChange
            ? Icons.arrow_forward_rounded
            : Icons.drag_handle_rounded;

    return SizedBox(
      width: compact ? 156 : 84,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: visuals.foreground.withValues(alpha: 0.16),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: visuals.accent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: visuals.accent.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 15, color: visuals.background),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: visuals.foreground.withValues(alpha: 0.16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              summary.deltaLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: visuals.foreground.withValues(alpha: 0.72),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
