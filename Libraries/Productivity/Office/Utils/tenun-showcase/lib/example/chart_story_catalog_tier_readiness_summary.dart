import 'package:flutter/material.dart';

import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_tier.dart';
import '../story/chart_story_tier_coverage.dart';
import 'chart_story_tier_presentation.dart';

class ChartCatalogTierReadinessSummary extends StatelessWidget {
  const ChartCatalogTierReadinessSummary({super.key, required this.summaries});

  final List<ChartStoryTierContractCoverage> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tier readiness',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final summary in summaries)
                  _TierReadinessTile(summary: summary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TierReadinessTile extends StatelessWidget {
  const _TierReadinessTile({required this.summary});

  final ChartStoryTierContractCoverage summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tier = chartStoryTierFromKey(summary.tierKey);
    final palette = tier == null
        ? null
        : chartStoryTierPalette(tier, colorScheme);
    final readyRatioLabel = chartStoryContractCoverageRatioLabel(
      summary.readyRatio,
    );
    final description = chartStoryTierDescriptionForKey(summary.tierKey);
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                palette?.container.withValues(alpha: 0.8) ??
                colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TierReadinessIcon(summary: summary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.tierLabel,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    readyRatioLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: palette?.foreground ?? colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: summary.readyRatio.clamp(0, 1).toDouble(),
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text(
                '${summary.readyCount} / ${summary.totalCount} ready',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (summary.gapCount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${summary.gapCount} gaps',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (description == null || description.isEmpty) {
      return content;
    }

    return Tooltip(message: description, child: content);
  }
}

class _TierReadinessIcon extends StatelessWidget {
  const _TierReadinessIcon({required this.summary});

  final ChartStoryTierContractCoverage summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tier = chartStoryTierFromKey(summary.tierKey);
    final icon =
        chartStoryTierIconForKey(summary.tierKey) ??
        Icons.help_outline_outlined;
    final palette = tier == null
        ? null
        : chartStoryTierPalette(tier, colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            palette?.container.withValues(alpha: 0.55) ??
            colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 16,
          color: palette?.foreground ?? colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
