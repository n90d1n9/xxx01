import 'package:flutter/material.dart';

import '../../logic/survey_evidence_sync_activity_summary.dart';
import '../survey_feedback_tone.dart';

/// Renders compact evidence upload activity for persistent dashboard context.
class SurveyEvidenceSyncActivityStrip extends StatelessWidget {
  final SurveyEvidenceSyncActivitySummary summary;
  final VoidCallback? onPressed;
  final String actionTooltip;

  const SurveyEvidenceSyncActivityStrip({
    super.key,
    required this.summary,
    this.onPressed,
    this.actionTooltip = 'Open evidence sync',
  });

  @override
  Widget build(BuildContext context) {
    if (!summary.hasActivity) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final toneStyle = SurveyFeedbackToneStyle.resolve(colorScheme, _tone);
    final color = toneStyle.color;
    final borderRadius = BorderRadius.circular(8);

    return Semantics(
      container: true,
      liveRegion: summary.activeUploadCount > 0,
      button: onPressed != null,
      enabled: onPressed != null,
      onTap: onPressed,
      label: '${summary.title}. ${summary.detailLabel}',
      child: Material(
        color: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;

                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: compact
                          ? constraints.maxWidth
                          : constraints.maxWidth.clamp(0, 620).toDouble(),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  summary.detailLabel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final metric in summary.metrics)
                          _SurveyEvidenceSyncActivityChip(
                            metric: metric,
                            color: color,
                          ),
                        if (onPressed != null)
                          _SurveyEvidenceSyncActivityOpenIcon(
                            color: color,
                            tooltip: actionTooltip,
                          ),
                      ],
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

  SurveyFeedbackTone get _tone {
    switch (summary.state) {
      case SurveyEvidenceSyncActivityState.attention:
        return SurveyFeedbackTone.error;
      case SurveyEvidenceSyncActivityState.active:
      case SurveyEvidenceSyncActivityState.waiting:
        return SurveyFeedbackTone.warning;
      case SurveyEvidenceSyncActivityState.ready:
        return SurveyFeedbackTone.success;
      case SurveyEvidenceSyncActivityState.clear:
        return SurveyFeedbackTone.info;
    }
  }

  IconData get _icon {
    switch (summary.state) {
      case SurveyEvidenceSyncActivityState.attention:
        return Icons.cloud_off_outlined;
      case SurveyEvidenceSyncActivityState.active:
        return Icons.sync_outlined;
      case SurveyEvidenceSyncActivityState.ready:
        return Icons.cloud_upload_outlined;
      case SurveyEvidenceSyncActivityState.waiting:
        return Icons.pending_actions_outlined;
      case SurveyEvidenceSyncActivityState.clear:
        return Icons.cloud_done_outlined;
    }
  }
}

class _SurveyEvidenceSyncActivityOpenIcon extends StatelessWidget {
  final Color color;
  final String tooltip;

  const _SurveyEvidenceSyncActivityOpenIcon({
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.26)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(Icons.arrow_forward, color: color, size: 16),
        ),
      ),
    );
  }
}

class _SurveyEvidenceSyncActivityChip extends StatelessWidget {
  final SurveyEvidenceSyncActivityMetric metric;
  final Color color;

  const _SurveyEvidenceSyncActivityChip({
    required this.metric,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metric.count > 99 ? '99+' : metric.count.toString(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              metric.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
