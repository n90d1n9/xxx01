import 'package:flutter/material.dart';

import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_groups.dart';
import 'chart_story_tier_presentation.dart';

class ChartCatalogEntryMetadataWrap extends StatelessWidget {
  const ChartCatalogEntryMetadataWrap({super.key, required this.entry});

  final ChartStoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final missingParts = chartStoryContractMissingParts(entry);
    final values = [
      entry.dataShape,
      entry.family,
      if (entry.knobs.isNotEmpty) '${entry.knobs.length} knobs',
      if (entry.hasSampleJson) 'JSON',
      if (entry.hasSampleCode) 'Code',
    ].whereType<String>().where((value) => value.isNotEmpty).toSet();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ChartCatalogTierChip(entry: entry),
        ChartCatalogContractReadinessChip(entry: entry),
        if (missingParts.isNotEmpty)
          ChartCatalogMetadataChip(
            label: 'Missing: ${missingParts.join(', ')}',
          ),
        for (final value in values) ChartCatalogMetadataChip(label: value),
      ],
    );
  }
}

class ChartCatalogTierChip extends StatelessWidget {
  const ChartCatalogTierChip({super.key, required this.entry});

  final ChartStoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final palette = chartStoryTierPalette(entry.tier, colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.container.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chartStoryTierIcon(entry.tier),
              size: 14,
              color: palette.foreground,
            ),
            const SizedBox(width: 4),
            Text(
              entry.tierLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: palette.foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartCatalogContractReadinessChip extends StatelessWidget {
  const ChartCatalogContractReadinessChip({super.key, required this.entry});

  final ChartStoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReady = entry.isContractReady;
    final containerColor = isReady
        ? colorScheme.primaryContainer.withValues(alpha: 0.55)
        : colorScheme.errorContainer.withValues(alpha: 0.45);
    final foregroundColor = isReady
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isReady ? Icons.check_circle_outline : Icons.pending_actions,
              size: 14,
              color: foregroundColor,
            ),
            const SizedBox(width: 4),
            Text(
              chartStoryContractReadinessLabel(entry),
              style: theme.textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartCatalogMetadataChip extends StatelessWidget {
  const ChartCatalogMetadataChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
