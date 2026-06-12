import 'package:flutter/material.dart';

import 'chart_sample_panels.dart';
import 'chart_samples_registry.dart';

export 'chart_sample_source_helpers.dart';

class ChartSampleFamilyGallery extends StatelessWidget {
  const ChartSampleFamilyGallery({
    super.key,
    required this.family,
    this.options = const ChartSampleShowcaseOptions(),
    this.padding = const EdgeInsets.all(12),
    this.showHeader = true,
  });

  final ChartShowcaseFamily family;
  final ChartSampleShowcaseOptions options;
  final EdgeInsetsGeometry padding;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            ChartSampleFamilyHeader(family: family),
            const SizedBox(height: 18),
          ],
          ChartSampleList(samples: family.samples, options: options),
        ],
      ),
    );
  }
}

class ChartSampleFamilyHeader extends StatelessWidget {
  const ChartSampleFamilyHeader({
    super.key,
    required this.family,
    this.onChartTypeSelected,
  });

  final ChartShowcaseFamily family;
  final ValueChanged<String>? onChartTypeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chartTypes = family.uniqueChartTypes;

    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            family.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            family.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChartSampleFamilyChip(label: family.tierLabel),
              _ChartSampleFamilyChip(label: _sampleCountLabel(family)),
              for (final type in chartTypes)
                _ChartSampleFamilyChip(
                  label: type,
                  onPressed: onChartTypeSelected == null
                      ? null
                      : () => onChartTypeSelected!(type),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartSampleFamilyCatalog extends StatelessWidget {
  const ChartSampleFamilyCatalog({
    super.key,
    required this.families,
    this.padding = const EdgeInsets.all(12),
    this.selectedFamilyId,
    this.onFamilySelected,
    this.onChartTypeSelected,
  });

  final List<ChartShowcaseFamily> families;
  final EdgeInsetsGeometry padding;
  final String? selectedFamilyId;
  final ValueChanged<ChartShowcaseFamily>? onFamilySelected;
  final ValueChanged<String>? onChartTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: ChartSampleFamilyCatalogWrap(
        families: families,
        selectedFamilyId: selectedFamilyId,
        onFamilySelected: onFamilySelected,
        onChartTypeSelected: onChartTypeSelected,
      ),
    );
  }
}

class ChartSampleFamilyCatalogWrap extends StatelessWidget {
  const ChartSampleFamilyCatalogWrap({
    super.key,
    required this.families,
    required this.selectedFamilyId,
    required this.onFamilySelected,
    required this.onChartTypeSelected,
  });

  final List<ChartShowcaseFamily> families;
  final String? selectedFamilyId;
  final ValueChanged<ChartShowcaseFamily>? onFamilySelected;
  final ValueChanged<String>? onChartTypeSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = _catalogTileWidth(constraints.maxWidth);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final family in families)
              SizedBox(
                width: tileWidth,
                child: _ChartSampleFamilyCatalogTile(
                  family: family,
                  selected: family.id == selectedFamilyId,
                  onTap: onFamilySelected == null
                      ? null
                      : () => onFamilySelected!(family),
                  onChartTypeSelected: onChartTypeSelected,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChartSampleFamilyCatalogTile extends StatelessWidget {
  const _ChartSampleFamilyCatalogTile({
    required this.family,
    required this.selected,
    this.onTap,
    this.onChartTypeSelected,
  });

  final ChartShowcaseFamily family;
  final bool selected;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChartTypeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chartTypes = family.uniqueChartTypes;
    final visibleTypes = chartTypes.take(4).toList(growable: false);
    final hiddenTypeCount = chartTypes.length - visibleTypes.length;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.28)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: selected ? 1.6 : 1),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                family.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                family.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChartSampleFamilyChip(label: family.tierLabel),
                  _ChartSampleFamilyChip(label: _sampleCountLabel(family)),
                  for (final type in visibleTypes)
                    _ChartSampleFamilyChip(
                      label: type,
                      onPressed: onChartTypeSelected == null
                          ? null
                          : () => onChartTypeSelected!(type),
                    ),
                  if (hiddenTypeCount > 0)
                    _ChartSampleFamilyChip(label: '+$hiddenTypeCount'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartSampleFamilyChip extends StatelessWidget {
  const _ChartSampleFamilyChip({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onPressed == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(999),
        ),
        child: child,
      );
    }

    return Tooltip(
      message: 'Filter $label',
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: child,
        ),
      ),
    );
  }
}

String _sampleCountLabel(ChartShowcaseFamily family) {
  final label = family.sampleCount == 1 ? 'sample' : 'samples';
  return '${family.sampleCount} $label';
}

double _catalogTileWidth(double maxWidth) {
  if (!maxWidth.isFinite || maxWidth < 620) {
    return maxWidth.isFinite ? maxWidth : 320;
  }
  if (maxWidth < 920) {
    return (maxWidth - 12) / 2;
  }
  return (maxWidth - 24) / 3;
}
