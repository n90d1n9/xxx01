import 'package:flutter/material.dart';

import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_groups.dart';
import 'chart_story_contract_starter_panel.dart';

class ChartCatalogExplorerHeader extends StatelessWidget {
  const ChartCatalogExplorerHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.groupCount,
    required this.storyCount,
    required this.categoryCount,
    required this.sectionCount,
    required this.dataShapeCount,
    required this.familyCount,
  });

  final String title;
  final String? subtitle;
  final int groupCount;
  final int storyCount;
  final int categoryCount;
  final int sectionCount;
  final int dataShapeCount;
  final int familyCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricPill(label: 'Groups', value: groupCount),
            _MetricPill(label: 'Stories', value: storyCount),
            _MetricPill(label: 'Categories', value: categoryCount),
            _MetricPill(label: 'Sections', value: sectionCount),
            _MetricPill(label: 'Data shapes', value: dataShapeCount),
            _MetricPill(label: 'Families', value: familyCount),
          ],
        ),
      ],
    );
  }
}

class ChartCatalogContractCoverageSummary extends StatelessWidget {
  const ChartCatalogContractCoverageSummary({
    super.key,
    required this.coverage,
  });

  final ChartStoryContractCoverage coverage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final readyRatioLabel = chartStoryContractCoverageRatioLabel(
      coverage.readyRatio,
    );

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
                Icon(Icons.fact_check_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Contract coverage',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  readyRatioLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${coverage.readyCount} of ${coverage.totalCount} stories are contract ready.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: coverage.readyRatio.clamp(0, 1).toDouble(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CoverageMetricPill(
                  label: 'Contracted',
                  value: coverage.contractedCount.toString(),
                ),
                _CoverageMetricPill(
                  label: 'Ready',
                  value: coverage.readyCount.toString(),
                ),
                _CoverageMetricPill(
                  label: 'JSON',
                  value: coverage.sampleJsonCount.toString(),
                ),
                _CoverageMetricPill(
                  label: 'Code',
                  value: coverage.sampleCodeCount.toString(),
                ),
                _CoverageMetricPill(
                  label: 'Knobs',
                  value: coverage.knobCount.toString(),
                ),
                _CoverageMetricPill(
                  label: 'Gaps',
                  value: coverage.gapCount.toString(),
                ),
              ],
            ),
            if (coverage.gaps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Next gaps',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              _ContractGapPreview(gaps: coverage.gaps.take(3).toList()),
              _ContractStarterBundleDisclosure(
                entries: [for (final gap in coverage.gaps) gap.entry],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _CoverageMetricPill extends StatelessWidget {
  const _CoverageMetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _ContractGapPreview extends StatelessWidget {
  const _ContractGapPreview({required this.gaps});

  final List<ChartStoryContractGap> gaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final gap in gaps)
          Tooltip(
            message: gap.missingLabel,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '${gap.label}: ${gap.missingParts.length} gaps',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ContractStarterBundleDisclosure extends StatefulWidget {
  const _ContractStarterBundleDisclosure({required this.entries});

  final List<ChartStoryEntry> entries;

  @override
  State<_ContractStarterBundleDisclosure> createState() =>
      _ContractStarterBundleDisclosureState();
}

class _ContractStarterBundleDisclosureState
    extends State<_ContractStarterBundleDisclosure> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          icon: Icon(
            _isExpanded ? Icons.expand_less : Icons.file_copy_outlined,
            size: 18,
          ),
          label: Text(
            'Starter bundle',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (_isExpanded)
          ChartStoryContractStarterBundlePanel(entries: widget.entries),
      ],
    );
  }
}
