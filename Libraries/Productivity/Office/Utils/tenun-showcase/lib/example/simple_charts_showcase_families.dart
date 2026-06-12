import 'package:flutter/widgets.dart';

import 'simple_charts_showcase_api_examples.dart';
import 'simple_charts_showcase_gallery_advanced_dashboard.dart';
import 'simple_charts_showcase_gallery_comparison.dart';
import 'simple_charts_showcase_gallery_composition.dart';
import 'simple_charts_showcase_gallery_core.dart';
import 'simple_charts_showcase_gallery_flow.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_gallery_statistical.dart';
import 'simple_charts_showcase_gallery_trends.dart';

typedef SimpleChartsShowcasePanelBuilder =
    List<Widget> Function(SimpleChartsGalleryOptions options);

enum SimpleChartsShowcaseTier { core, pro, custom }

enum SimpleChartsShowcaseTierFilter { all, core, pro }

extension SimpleChartsShowcaseTierLabel on SimpleChartsShowcaseTier {
  String get label => switch (this) {
    SimpleChartsShowcaseTier.core => 'Core',
    SimpleChartsShowcaseTier.pro => 'Pro',
    SimpleChartsShowcaseTier.custom => 'Custom',
  };
}

extension SimpleChartsShowcaseTierFilterLabel
    on SimpleChartsShowcaseTierFilter {
  String get label => switch (this) {
    SimpleChartsShowcaseTierFilter.all => 'All',
    SimpleChartsShowcaseTierFilter.core => 'Core',
    SimpleChartsShowcaseTierFilter.pro => 'Pro',
  };

  bool includes(SimpleChartsShowcaseFamilySpec family) => switch (this) {
    SimpleChartsShowcaseTierFilter.all => true,
    SimpleChartsShowcaseTierFilter.core =>
      family.tier == SimpleChartsShowcaseTier.core,
    SimpleChartsShowcaseTierFilter.pro =>
      family.tier == SimpleChartsShowcaseTier.pro,
  };
}

class SimpleChartsShowcaseFamilySpec {
  const SimpleChartsShowcaseFamilySpec({
    required this.id,
    required this.title,
    required this.auditTitle,
    required this.description,
    required this.tier,
    required this.buildPanels,
  });

  final String id;
  final String title;
  final String auditTitle;
  final String description;
  final SimpleChartsShowcaseTier tier;
  final SimpleChartsShowcasePanelBuilder buildPanels;
}

final simpleChartsShowcaseFamilies =
    List<SimpleChartsShowcaseFamilySpec>.unmodifiable([
      const SimpleChartsShowcaseFamilySpec(
        id: 'api',
        title: 'API behavior',
        auditTitle: 'API Behavior',
        description:
            'Shared widget hooks, empty states, semantics, and callbacks.',
        tier: SimpleChartsShowcaseTier.core,
        buildPanels: simpleChartsApiPanels,
      ),
      const SimpleChartsShowcaseFamilySpec(
        id: 'core',
        title: 'Core simple charts',
        auditTitle: 'Core Simple Charts',
        description:
            'Vertical and horizontal bar basics for free-tier dashboards.',
        tier: SimpleChartsShowcaseTier.core,
        buildPanels: simpleChartsCorePanels,
      ),
      const SimpleChartsShowcaseFamilySpec(
        id: 'advanced_dashboard',
        title: 'Pro dashboard charts',
        auditTitle: 'Pro Dashboard Simple Charts',
        description:
            'Lollipop, bullet, gauge, radial, radar, and matrix dashboard views.',
        tier: SimpleChartsShowcaseTier.pro,
        buildPanels: simpleChartsAdvancedDashboardPanels,
      ),
      const SimpleChartsShowcaseFamilySpec(
        id: 'statistical',
        title: 'Statistical and spatial charts',
        auditTitle: 'Statistical Simple Charts',
        description:
            'Heatmaps, distributions, density plots, and multivariate views.',
        tier: SimpleChartsShowcaseTier.pro,
        buildPanels: simpleChartsStatisticalPanels,
      ),
      const SimpleChartsShowcaseFamilySpec(
        id: 'composition',
        title: 'Composition charts',
        auditTitle: 'Composition Simple Charts',
        description: 'Part-to-whole, hierarchy, sets, pictograms, and mosaics.',
        tier: SimpleChartsShowcaseTier.pro,
        buildPanels: simpleChartsCompositionPanels,
      ),
      const SimpleChartsShowcaseFamilySpec(
        id: 'comparison',
        title: 'Comparison charts',
        auditTitle: 'Comparison Simple Charts',
        description: 'Pareto, ranges, timelines, Gantt, slope, and pyramids.',
        tier: SimpleChartsShowcaseTier.pro,
        buildPanels: simpleChartsComparisonPanels,
      ),
      const SimpleChartsShowcaseFamilySpec(
        id: 'flow',
        title: 'Flow and relationship charts',
        auditTitle: 'Flow Simple Charts',
        description:
            'Funnels, sankey/alluvial/chord, network, scatter, and bars.',
        tier: SimpleChartsShowcaseTier.pro,
        buildPanels: simpleChartsFlowPanels,
      ),
      const SimpleChartsShowcaseFamilySpec(
        id: 'trends',
        title: 'Trend charts',
        auditTitle: 'Trend Simple Charts',
        description:
            'Lines, areas, cycles, candles, cohorts, horizon, and streamgraph.',
        tier: SimpleChartsShowcaseTier.pro,
        buildPanels: simpleChartsTrendPanels,
      ),
    ]);

List<SimpleChartsShowcaseFamilySpec> simpleChartsShowcaseFamiliesForTier(
  SimpleChartsShowcaseTierFilter tierFilter,
) {
  return simpleChartsShowcaseFamilies
      .where(tierFilter.includes)
      .toList(growable: false);
}
