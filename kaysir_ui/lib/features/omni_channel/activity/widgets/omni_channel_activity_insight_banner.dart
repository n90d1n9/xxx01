import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_insight.dart';
import 'omni_channel_activity_presentation.dart';

/// Compact status banner for summarized omni-channel activity readiness.
class OmniChannelActivityInsightBanner extends StatelessWidget {
  final OmniChannelActivityInsight insight;
  final bool showNextStep;
  final Widget? trailing;

  const OmniChannelActivityInsightBanner({
    super.key,
    required this.insight,
    this.showNextStep = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visuals = omniChannelActivitySeverityVisuals(insight.severity);
    final palette = _paletteFor(theme.colorScheme, visuals.tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InsightIconBadge(visuals: visuals, palette: palette),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InsightHeader(
                    headline: insight.headline,
                    summaryLabel: insight.summaryLabel,
                    palette: palette,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    insight.detail,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showNextStep) ...[
                    const SizedBox(height: 10),
                    _InsightNextStep(
                      message: insight.nextStep,
                      palette: palette,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Omni-channel activity insight banner')
Widget omniChannelActivityInsightBannerPreview() {
  final insight = OmniChannelActivityInsight.fromFeed(
    OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'preview-sync',
          kind: OmniChannelActivityKind.orderSync,
          sourceId: 'web_store',
          sourceLabel: 'Web store',
          occurredAt: DateTime(2026, 6, 9, 9, 30),
          title: 'Web order synced to cashier queue',
          detail: 'Click-and-collect order is ready for counter handoff.',
          severity: OmniChannelActivitySeverity.ready,
          channelId: 'web_store',
          orderId: 'ORD-2026-009',
        ),
      ],
    ),
  );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 520,
          child: OmniChannelActivityInsightBanner(insight: insight),
        ),
      ),
    ),
  );
}

/// Header row that pairs the insight headline with its metric summary.
class _InsightHeader extends StatelessWidget {
  final String headline;
  final String summaryLabel;
  final _OmniChannelActivityTonePalette palette;

  const _InsightHeader({
    required this.headline,
    required this.summaryLabel,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          headline,
          style: theme.textTheme.titleSmall?.copyWith(
            color: palette.foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
        _SummaryPill(label: summaryLabel, palette: palette),
      ],
    );
  }
}

/// Tone-aware icon container for the current activity severity.
class _InsightIconBadge extends StatelessWidget {
  final OmniChannelActivityVisuals visuals;
  final _OmniChannelActivityTonePalette palette;

  const _InsightIconBadge({required this.visuals, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: palette.iconBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(visuals.icon, size: 20, color: palette.foreground),
    );
  }
}

/// Bounded metric chip that keeps long activity summaries from stretching UI.
class _SummaryPill extends StatelessWidget {
  final String label;
  final _OmniChannelActivityTonePalette palette;

  const _SummaryPill({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: palette.pillBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Follow-up guidance row shown below the activity detail.
class _InsightNextStep extends StatelessWidget {
  final String message;
  final _OmniChannelActivityTonePalette palette;

  const _InsightNextStep({required this.message, required this.palette});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.route_outlined, size: 16, color: palette.foreground),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Next: $message',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Resolved Material colors for one omni-channel activity severity tone.
class _OmniChannelActivityTonePalette {
  final Color background;
  final Color foreground;
  final Color border;
  final Color iconBackground;
  final Color pillBackground;

  const _OmniChannelActivityTonePalette({
    required this.background,
    required this.foreground,
    required this.border,
    required this.iconBackground,
    required this.pillBackground,
  });
}

_OmniChannelActivityTonePalette _paletteFor(
  ColorScheme colorScheme,
  OmniChannelActivityTone tone,
) {
  switch (tone) {
    case OmniChannelActivityTone.success:
      return _tonePalette(
        colorScheme: colorScheme,
        container: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
        accent: colorScheme.primary,
      );
    case OmniChannelActivityTone.warning:
      return _tonePalette(
        colorScheme: colorScheme,
        container: colorScheme.tertiaryContainer,
        foreground: colorScheme.onTertiaryContainer,
        accent: colorScheme.tertiary,
      );
    case OmniChannelActivityTone.danger:
      return _tonePalette(
        colorScheme: colorScheme,
        container: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
        accent: colorScheme.error,
      );
    case OmniChannelActivityTone.info:
    case OmniChannelActivityTone.neutral:
      return _tonePalette(
        colorScheme: colorScheme,
        container: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
        accent: colorScheme.secondary,
      );
  }
}

_OmniChannelActivityTonePalette _tonePalette({
  required ColorScheme colorScheme,
  required Color container,
  required Color foreground,
  required Color accent,
}) {
  return _OmniChannelActivityTonePalette(
    background: container.withValues(alpha: 0.42),
    foreground: foreground,
    border: accent.withValues(alpha: 0.22),
    iconBackground: accent.withValues(alpha: 0.13),
    pillBackground: colorScheme.surface.withValues(alpha: 0.7),
  );
}
