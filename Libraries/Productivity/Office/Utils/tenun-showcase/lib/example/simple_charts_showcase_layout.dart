import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'simple_charts_showcase_families.dart';
import 'simple_charts_showcase_gallery.dart';
import 'simple_charts_showcase_metrics.dart';

class SimpleChartsShowcaseLayout extends StatelessWidget {
  final SimpleBarChartStyle barStyle;
  final SimpleTrendChartStyle trendStyle;
  final SimpleChartsShowcaseTierFilter tierFilter;
  final bool darkMode;
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
  final bool progressiveGalleryLoading;
  final int initialVisibleGalleryGroups;
  final Duration galleryGroupRevealInterval;

  const SimpleChartsShowcaseLayout({
    super.key,
    required this.barStyle,
    required this.trendStyle,
    required this.tierFilter,
    required this.darkMode,
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
    this.progressiveGalleryLoading = true,
    this.initialVisibleGalleryGroups = 1,
    this.galleryGroupRevealInterval = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    final seed = darkMode ? const Color(0xFF76D7C4) : const Color(0xFF2563EB);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: darkMode ? Brightness.dark : Brightness.light,
    );
    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
    );

    return Theme(
      data: theme,
      child: Material(
        color: colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Simple Charts',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Compact sparklines, small multiples, bullet, gauge, radial bar, radar, parallel coordinates, scatter plot matrix, heatmap, continuous heatmap, punch card, bubble matrix, cohort retention, radial heatmap, correlation matrix, hexbin, Voronoi, contour, connected scatter, fan, spiral, cycle plot, calendar heatmap, tile map, ternary, histogram, binned dot plot, dot density, frequency polygon, density, raincloud, ECDF, QQ plot, Lorenz curve, Bland-Altman, box plot, boxen plot, forest plot, violin, ridgeline, rug plot, barcode plot, strip plot, sina plot, beeswarm, error bar, control chart, candlestick, network graph, word cloud, icicle, tree diagram, treemap, sunburst, sankey, alluvial, chord, arc diagram, venn, upset, timeline, milestone, event strip, gantt, pareto, quadrant, bubble, packed bubble, waffle, pictogram, mosaic plot, marimekko, range, tornado, dot plot, Likert, bump, slope, population pyramid, scatter, funnel, lollipop, dumbbell, donut, rose, waterfall, bar, grouped bar, stacked bar, horizon, streamgraph, step, line, and area charts across business, education, and product dashboards.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SimpleChartsMetricsStrip(
                    trendStyle: trendStyle,
                    showTooltips: showTooltips,
                  ),
                  const SizedBox(height: 16),
                  SimpleChartsGallery(
                    barStyle: barStyle,
                    trendStyle: trendStyle,
                    tierFilter: tierFilter,
                    showGrid: showGrid,
                    showValues: showValues,
                    showTracks: showTracks,
                    showTooltips: showTooltips,
                    showLegends: showLegends,
                    showReferenceLines: showReferenceLines,
                    showReferenceBands: showReferenceBands,
                    showActiveBars: showActiveBars,
                    stackAsPercent: stackAsPercent,
                    showSampleJson: showSampleJson,
                    showSampleCode: showSampleCode,
                    progressiveLoading: progressiveGalleryLoading,
                    initialVisibleGroupCount: initialVisibleGalleryGroups,
                    groupRevealInterval: galleryGroupRevealInterval,
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
