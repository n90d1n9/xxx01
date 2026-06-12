import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align, FontWeight;

import 'simple_charts_showcase_families.dart';
import 'simple_charts_showcase_gallery_options.dart';

class SimpleChartsGallery extends StatefulWidget {
  final SimpleBarChartStyle barStyle;
  final SimpleTrendChartStyle trendStyle;
  final SimpleChartsShowcaseTierFilter tierFilter;
  final bool showGrid;
  final bool showValues;
  final bool showTracks;
  final bool showTooltips;
  final bool showLegends;
  final bool showReferenceLines;
  final bool showReferenceBands;
  final bool showActiveBars;
  final bool stackAsPercent;
  final bool showSampleJson;
  final bool showSampleCode;
  final bool progressiveLoading;
  final int initialVisibleGroupCount;
  final Duration groupRevealInterval;

  const SimpleChartsGallery({
    super.key,
    required this.barStyle,
    required this.trendStyle,
    this.tierFilter = SimpleChartsShowcaseTierFilter.all,
    required this.showGrid,
    required this.showValues,
    required this.showTracks,
    required this.showTooltips,
    required this.showLegends,
    required this.showReferenceLines,
    required this.showReferenceBands,
    required this.showActiveBars,
    required this.stackAsPercent,
    required this.showSampleJson,
    required this.showSampleCode,
    this.progressiveLoading = true,
    this.initialVisibleGroupCount = 1,
    this.groupRevealInterval = const Duration(milliseconds: 350),
  });

  @override
  State<SimpleChartsGallery> createState() => _SimpleChartsGalleryState();
}

class _SimpleChartsGalleryState extends State<SimpleChartsGallery> {
  Timer? _revealTimer;
  late int _visibleGroupCount;

  @override
  void initState() {
    super.initState();
    _visibleGroupCount = _initialVisibleGroupCount();
    _scheduleNextReveal();
  }

  @override
  void didUpdateWidget(covariant SimpleChartsGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tierFilter != widget.tierFilter ||
        oldWidget.progressiveLoading != widget.progressiveLoading ||
        oldWidget.initialVisibleGroupCount != widget.initialVisibleGroupCount ||
        oldWidget.groupRevealInterval != widget.groupRevealInterval) {
      _revealTimer?.cancel();
      _visibleGroupCount = _initialVisibleGroupCount();
      _scheduleNextReveal();
      return;
    }

    if (widget.progressiveLoading) {
      _scheduleNextReveal();
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  int _initialVisibleGroupCount() {
    final familyCount = simpleChartsShowcaseFamiliesForTier(
      widget.tierFilter,
    ).length;
    if (familyCount == 0) return 0;
    if (!widget.progressiveLoading) return familyCount;
    return widget.initialVisibleGroupCount.clamp(1, familyCount).toInt();
  }

  void _scheduleNextReveal() {
    final familyCount = simpleChartsShowcaseFamiliesForTier(
      widget.tierFilter,
    ).length;
    if (!widget.progressiveLoading ||
        familyCount == 0 ||
        _visibleGroupCount >= familyCount ||
        _revealTimer?.isActive == true) {
      return;
    }

    _revealTimer = Timer(widget.groupRevealInterval, () {
      if (!mounted) return;
      setState(() {
        _visibleGroupCount = (_visibleGroupCount + 1)
            .clamp(1, familyCount)
            .toInt();
      });
      _revealTimer = null;
      _scheduleNextReveal();
    });
  }

  void _showAllGroups() {
    _revealTimer?.cancel();
    _revealTimer = null;
    final familyCount = simpleChartsShowcaseFamiliesForTier(
      widget.tierFilter,
    ).length;
    if (_visibleGroupCount >= familyCount) return;
    setState(() {
      _visibleGroupCount = familyCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth >= 900
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        final options = SimpleChartsGalleryOptions(
          panelWidth: panelWidth,
          barStyle: widget.barStyle,
          trendStyle: widget.trendStyle,
          showGrid: widget.showGrid,
          showValues: widget.showValues,
          showTracks: widget.showTracks,
          showTooltips: widget.showTooltips,
          showLegends: widget.showLegends,
          showReferenceLines: widget.showReferenceLines,
          showReferenceBands: widget.showReferenceBands,
          showActiveBars: widget.showActiveBars,
          stackAsPercent: widget.stackAsPercent,
          showSampleJson: widget.showSampleJson,
          showSampleCode: widget.showSampleCode,
        );
        final families = simpleChartsShowcaseFamiliesForTier(widget.tierFilter);
        final visibleGroups = families
            .take(_visibleGroupCount)
            .toList(growable: false);
        final remainingGroups = families.length - visibleGroups.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final group in visibleGroups) ...[
              _SimpleChartsGalleryGroupHeader(group: group),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: group.buildPanels(options),
              ),
              const SizedBox(height: 22),
            ],
            if (remainingGroups > 0)
              _SimpleChartsDeferredGroupsNotice(
                remainingGroups: remainingGroups,
                onLoadAll: _showAllGroups,
              ),
          ],
        );
      },
    );
  }
}

class _SimpleChartsGalleryGroupHeader extends StatelessWidget {
  final SimpleChartsShowcaseFamilySpec group;

  const _SimpleChartsGalleryGroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    group.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SimpleChartsFamilyTierBadge(tier: group.tier),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              group.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleChartsFamilyTierBadge extends StatelessWidget {
  final SimpleChartsShowcaseTier tier;

  const _SimpleChartsFamilyTierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = switch (tier) {
      SimpleChartsShowcaseTier.core => (
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
        border: colorScheme.primary.withValues(alpha: 0.32),
      ),
      SimpleChartsShowcaseTier.pro => (
        background: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
        border: colorScheme.secondary.withValues(alpha: 0.32),
      ),
      SimpleChartsShowcaseTier.custom => (
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
        border: colorScheme.outlineVariant,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          tier.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SimpleChartsDeferredGroupsNotice extends StatelessWidget {
  final int remainingGroups;
  final VoidCallback onLoadAll;

  const _SimpleChartsDeferredGroupsNotice({
    required this.remainingGroups,
    required this.onLoadAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Loading $remainingGroups more simple chart group(s)...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onLoadAll,
                icon: const Icon(Icons.unfold_more, size: 16),
                label: const Text('Load all now'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
