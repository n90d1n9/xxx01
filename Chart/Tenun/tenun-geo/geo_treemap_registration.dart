/// Registration bundle for 6 geo + 3 treemap variant chart types.
///
/// Usage:
/// ```dart
/// void main() {
///   completeChartsBundle.register();
///   variantsBundle.register();
///   geoTreemapBundle.register();   // ← add this
///   runApp(const MyApp());
/// }
/// ```
library geo_treemap_registration;

import '../core/config/chart_type.dart';
import '../core/registry/chart_registry.dart';
import '../core/registry/chart_registration.dart';

import '../charts/geo_charts.dart';
import '../charts/treemap_variants.dart';

// ─── Geo registrations ──────────────────────────────────────────────────────

final ChartRegistration geoGraphRegistration = ChartRegistration(
  type: ChartType.geoGraph,
  typeString: 'geoGraph',
  aliases: const ['geograph', 'networkMap', 'connectionMap'],
  fromJson: GeoGraphConfig.fromJson,
  description: 'Network graph where nodes are placed at geographic lat/lon positions '
      'and connected by straight or quadratic arc edges. Supports zoom & pan.',
  tags: const ['geo', 'network', 'graph', 'map', 'connections'],
);

final ChartRegistration geoChoroplethScatterRegistration = ChartRegistration(
  type: ChartType.geoChoroplethScatter,
  typeString: 'geoChoroplethScatter',
  aliases: const ['choroplethScatter', 'mapScatter', 'geoOverlay'],
  fromJson: GeoChoroplethScatterConfig.fromJson,
  description: 'Choropleth region map with an independent scatter point layer '
      'on top — two value scales, two colour palettes.',
  tags: const ['geo', 'choropleth', 'scatter', 'map', 'overlay'],
);

final ChartRegistration geoBeefCutsRegistration = ChartRegistration(
  type: ChartType.geoBeefCuts,
  typeString: 'geoBeefCuts',
  aliases: const ['beefCuts', 'anatomyMap', 'regionDiagram', 'bodyMap'],
  fromJson: GeoBeefCutsConfig.fromJson,
  description: 'Labeled region map for anatomy / body diagrams (beef cuts, floor plans, etc.). '
      'Coordinates are normalised [0..1], not lat/lon.',
  tags: const ['geo', 'anatomy', 'region', 'diagram', 'beef'],
);

final ChartRegistration geoHeatmapRegistration = ChartRegistration(
  type: ChartType.geoHeatmap,
  typeString: 'geoHeatmap',
  aliases: const ['densityMap', 'hotspotMap', 'intensityMap'],
  fromJson: GeoHeatmapConfig.fromJson,
  description: 'Intensity heatmap on a geographic base — gaussian blobs composited '
      'with Screen blend mode for vivid hotspot colouring.',
  tags: const ['geo', 'heatmap', 'intensity', 'density', 'map'],
);

final ChartRegistration geoSvgLinesRegistration = ChartRegistration(
  type: ChartType.geoSvgLines,
  typeString: 'geoSvgLines',
  aliases: const ['flightMap', 'geoLines', 'arcMap', 'connectionArcs'],
  fromJson: GeoSvgLinesConfig.fromJson,
  description: 'Animated arc/line connections between geographic locations — '
      'travelling dot animation, glow effect, configurable arc height.',
  tags: const ['geo', 'arcs', 'connections', 'animated', 'lines', 'flight'],
);

final ChartRegistration geoMorphRegistration = ChartRegistration(
  type: ChartType.geoMorph,
  typeString: 'geoMorph',
  aliases: const ['mapToBar', 'geoBarMorph', 'mapBarTransition'],
  fromJson: GeoMorphConfig.fromJson,
  description: 'Animated transition between a geographic map view and a sorted '
      'horizontal bar chart — regions morph into bar rectangles.',
  tags: const ['geo', 'morph', 'transition', 'animated', 'bar', 'map'],
);

// ─── Treemap registrations ───────────────────────────────────────────────────

final ChartRegistration treemapSunburstMorphRegistration = ChartRegistration(
  type: ChartType.treemapSunburstMorph,
  typeString: 'treemapSunburstMorph',
  aliases: const ['treemapMorph', 'sunburstMorph', 'treeSunTransition'],
  fromJson: TreemapSunburstMorphConfig.fromJson,
  description: 'Animated cross-fade morph between a squarified treemap and a '
      'sunburst ring chart. Toggle button drives the animation.',
  tags: const ['treemap', 'sunburst', 'morph', 'animated', 'transition'],
);

final ChartRegistration treemapGradientRegistration = ChartRegistration(
  type: ChartType.treemapGradient,
  typeString: 'treemapGradient',
  aliases: const ['gradientTreemap', 'valueMappedTreemap', 'heatTreemap'],
  fromJson: TreemapGradientConfig.fromJson,
  description: 'Treemap where each leaf cell\'s fill is a gradient mapped from '
      'its value through a configurable multi-stop colour scale (linear or radial).',
  tags: const ['treemap', 'gradient', 'colour-scale', 'heatmap', 'value-mapping'],
);

final ChartRegistration treemapParentLabelsRegistration = ChartRegistration(
  type: ChartType.treemapParentLabels,
  typeString: 'treemapParentLabels',
  aliases: const ['parentLabelTreemap', 'groupTreemap', 'labelledTreemap'],
  fromJson: TreemapParentLabelsConfig.fromJson,
  description: 'Treemap with persistent parent-group labels — either as a '
      'sticky coloured header bar across each group, or as floating pill labels.',
  tags: const ['treemap', 'labels', 'parent', 'groups', 'hierarchy'],
);

// ─── Combined bundle ──────────────────────────────────────────────────────────

/// Register all 6 geo charts + 3 treemap variants.
final RegistrationBundle geoTreemapBundle = RegistrationBundle(
  name: 'geoTreemapBundle',
  description: '6 geo charts (geoGraph, geoChoroplethScatter, geoBeefCuts, '
      'geoHeatmap, geoSvgLines, geoMorph) + 3 treemap variants '
      '(treemapSunburstMorph, treemapGradient, treemapParentLabels)',
  registrations: [
    // Geo
    geoGraphRegistration,
    geoChoroplethScatterRegistration,
    geoBeefCutsRegistration,
    geoHeatmapRegistration,
    geoSvgLinesRegistration,
    geoMorphRegistration,
    // Treemap
    treemapSunburstMorphRegistration,
    treemapGradientRegistration,
    treemapParentLabelsRegistration,
  ],
);
