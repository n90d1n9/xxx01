/// Registration bundle for:
///   • 5  General charts  (table, themeRiver, pictorialBar, matrix, chord)
///   • 7  Tree charts     (treeLTR, treeRTL, treeTTB, treeBTT, treeRadial,
///                         treePolyline, multipleTrees)
///   • 9  Graph charts    (lesMiserables, forceGraph, simpleGraph,
///                         cartesianGraph, overlapLabelGraph,
///                         lifeExpectancyGraph, dynamicGraph,
///                         calendarGraph, webkitDepGraph)
///
/// Usage:
/// ```dart
/// void main() {
///   completeChartsBundle.register();
///   variantsBundle.register();
///   remainingChartsBundle.register();
///   geoTreemapBundle.register();
///   generalTreeGraphBundle.register();   // ← add this
///   runApp(const MyApp());
/// }
/// ```
library general_tree_graph_registration;

import '../core/config/chart_type.dart';
import '../core/registry/chart_registry.dart';
import '../core/registry/chart_registration.dart';

import '../charts/general_charts.dart';
import '../charts/tree_charts.dart';
import '../charts/graph_charts.dart';

// ─── General chart registrations ─────────────────────────────────────────────

final ChartRegistration tableRegistration = ChartRegistration(
  type: ChartType.table,
  typeString: 'table',
  aliases: const ['dataTable', 'grid', 'spreadsheet'],
  fromJson: TableChartConfig.fromJson,
  description: 'Sortable, scrollable data table with alternating row bands, '
      'sticky header, and optional inline colour-scale progress bars per column.',
  tags: const ['table', 'data', 'grid', 'sortable'],
);

final ChartRegistration themeRiverRegistration = ChartRegistration(
  type: ChartType.themeRiver,
  typeString: 'themeRiver',
  aliases: const ['stream', 'streamgraph', 'riverChart'],
  fromJson: ThemeRiverConfig.fromJson,
  description: 'Stacked stream graph — each series flows as a river band over '
      'categories. Silhouette-centred baseline minimises wiggles.',
  tags: const ['stream', 'stacked', 'flow', 'area', 'time'],
);

final ChartRegistration pictorialBarRegistration = ChartRegistration(
  type: ChartType.pictorialBar,
  typeString: 'pictorialBar',
  aliases: const ['symbolBar', 'iconBar', 'unitChart'],
  fromJson: PictorialBarConfig.fromJson,
  description: 'Bar chart where bars are formed by stacked repeated symbols '
      '(circle, star, triangle, diamond, arrow, person). Fractional last symbol is clipped.',
  tags: const ['bar', 'pictorial', 'symbol', 'infographic'],
);

final ChartRegistration matrixRegistration = ChartRegistration(
  type: ChartType.matrix,
  typeString: 'matrix',
  aliases: const ['correlationMatrix', 'adjacencyMatrix', 'heatMatrix'],
  fromJson: MatrixChartConfig.fromJson,
  description: 'Colour-coded adjacency / correlation matrix. '
      'Supports blues, reds, greens and diverging colour scales. Hover-highlighted cells.',
  tags: const ['matrix', 'correlation', 'heatmap', 'adjacency'],
);

final ChartRegistration chordRegistration = ChartRegistration(
  type: ChartType.chord,
  typeString: 'chord',
  aliases: const ['chordDiagram', 'flowChord', 'ribbonChart'],
  fromJson: ChordChartConfig.fromJson,
  description: 'Chord diagram — circular arc segments on the periphery connected '
      'by gradient Bézier ribbons proportional to flow magnitude.',
  tags: const ['chord', 'flow', 'relationship', 'circular'],
);

// ─── Tree chart registrations ─────────────────────────────────────────────────

final ChartRegistration treeLTRRegistration = ChartRegistration(
  type: ChartType.treeLTR,
  typeString: 'treeLTR',
  aliases: const ['tree', 'treeRightward', 'treeHorizontal', 'orgChart'],
  fromJson: (j) => TreeChartConfig.fromJson({...j, 'direction': 'ltr'}),
  description: 'Collapsible left-to-right hierarchical tree. '
      'Tap any node to collapse or expand its subtree. Pinch/drag to zoom and pan.',
  tags: const ['tree', 'hierarchy', 'collapsible', 'ltr'],
);

final ChartRegistration treeRTLRegistration = ChartRegistration(
  type: ChartType.treeRTL,
  typeString: 'treeRTL',
  aliases: const ['treeLeftward', 'treeReverse'],
  fromJson: (j) => TreeChartConfig.fromJson({...j, 'direction': 'rtl'}),
  description: 'Collapsible right-to-left tree — mirror of LTR layout.',
  tags: const ['tree', 'hierarchy', 'collapsible', 'rtl'],
);

final ChartRegistration treeTTBRegistration = ChartRegistration(
  type: ChartType.treeTTB,
  typeString: 'treeTTB',
  aliases: const ['treeDownward', 'treeVertical', 'treeTopDown'],
  fromJson: (j) => TreeChartConfig.fromJson({...j, 'direction': 'ttb'}),
  description: 'Collapsible top-to-bottom tree — classic org-chart orientation.',
  tags: const ['tree', 'hierarchy', 'collapsible', 'vertical'],
);

final ChartRegistration treeBTTRegistration = ChartRegistration(
  type: ChartType.treeBTT,
  typeString: 'treeBTT',
  aliases: const ['treeUpward', 'treeBottomUp'],
  fromJson: (j) => TreeChartConfig.fromJson({...j, 'direction': 'btt'}),
  description: 'Collapsible bottom-to-top tree — root at the bottom.',
  tags: const ['tree', 'hierarchy', 'collapsible', 'btt'],
);

final ChartRegistration treeRadialRegistration = ChartRegistration(
  type: ChartType.treeRadial,
  typeString: 'treeRadial',
  aliases: const ['radialTree', 'polarTree', 'circularTree'],
  fromJson: (j) => TreeChartConfig.fromJson({...j, 'direction': 'radial'}),
  description: 'Radial / polar tree — depth as radius, breadth as angle. '
      'Compact and visually distinctive for large hierarchies.',
  tags: const ['tree', 'radial', 'hierarchy', 'polar', 'collapsible'],
);

final ChartRegistration treePolylineRegistration = ChartRegistration(
  type: ChartType.treePolyline,
  typeString: 'treePolyline',
  aliases: const ['treeOrtho', 'treeElbow', 'treeRightAngle'],
  fromJson: (j) => TreeChartConfig.fromJson({...j, 'direction': 'ltr', 'polylineEdge': true}),
  description: 'Tree with orthogonal (right-angle elbow) edge connectors '
      'instead of smooth Bézier curves.',
  tags: const ['tree', 'hierarchy', 'polyline', 'orthogonal', 'collapsible'],
);

final ChartRegistration multipleTreesRegistration = ChartRegistration(
  type: ChartType.multipleTrees,
  typeString: 'multipleTrees',
  aliases: const ['multiTree', 'forestChart', 'sideBySideTrees'],
  fromJson: MultipleTreesConfig.fromJson,
  description: 'Multiple independent tree roots displayed side-by-side in '
      'equal-width partitions. Each tree is independently collapsible.',
  tags: const ['tree', 'multiple', 'forest', 'hierarchy', 'collapsible'],
);

// ─── Graph chart registrations ────────────────────────────────────────────────

final ChartRegistration lesMiserablesRegistration = ChartRegistration(
  type: ChartType.lesMiserables,
  typeString: 'lesMiserables',
  aliases: const ['lesMis', 'communityGraph', 'categoryForceGraph'],
  fromJson: LesMiserablesGraphConfig.fromJson,
  description: 'Force-directed graph with community (category) colouring. '
      'Classic Les Misérables character network. Nodes animate with physics simulation.',
  tags: const ['graph', 'force', 'network', 'community', 'animated'],
);

final ChartRegistration forceGraphRegistration = ChartRegistration(
  type: ChartType.forceGraph,
  typeString: 'forceGraph',
  aliases: const ['forceLayout', 'forceDirected', 'physicsGraph'],
  fromJson: ForceLayoutGraphConfig.fromJson,
  description: 'Configurable force-directed graph — repulsion, attraction, '
      'and damping are all tunable via config.',
  tags: const ['graph', 'force', 'network', 'physics', 'animated'],
);

final ChartRegistration simpleGraphRegistration = ChartRegistration(
  type: ChartType.simpleGraph,
  typeString: 'simpleGraph',
  aliases: const ['staticGraph', 'positionedGraph'],
  fromJson: SimpleGraphConfig.fromJson,
  description: 'Static graph where each node has explicit x/y coordinates. '
      'Supports edge labels and hover highlighting.',
  tags: const ['graph', 'network', 'static', 'positioned'],
);

final ChartRegistration cartesianGraphRegistration = ChartRegistration(
  type: ChartType.cartesianGraph,
  typeString: 'cartesianGraph',
  aliases: const ['xyGraph', 'graphCartesian', 'scatterGraph'],
  fromJson: CartesianGraphConfig.fromJson,
  description: 'Graph overlaid on Cartesian X/Y axes. Node positions are '
      'data values mapped through the axis range to canvas.',
  tags: const ['graph', 'cartesian', 'axis', 'network'],
);

final ChartRegistration overlapLabelGraphRegistration = ChartRegistration(
  type: ChartType.overlapLabelGraph,
  typeString: 'overlapLabelGraph',
  aliases: const ['hideLabelGraph', 'smartLabelGraph'],
  fromJson: OverlapLabelGraphConfig.fromJson,
  description: 'Force-directed graph that automatically hides labels that '
      'would overlap each other — keeps the canvas readable at any density.',
  tags: const ['graph', 'force', 'labels', 'overlap', 'network'],
);

final ChartRegistration lifeExpectancyGraphRegistration = ChartRegistration(
  type: ChartType.lifeExpectancyGraph,
  typeString: 'lifeExpectancyGraph',
  aliases: const ['gapminder', 'bubbleTimeline', 'animatedBubble'],
  fromJson: LifeExpectancyGraphConfig.fromJson,
  description: 'Animated bubble chart across time frames (Gapminder style). '
      'Bubbles sized by value, coloured by category. Slider and play button animate years.',
  tags: const ['graph', 'bubble', 'animated', 'timeline', 'gapminder'],
);

final ChartRegistration dynamicGraphRegistration = ChartRegistration(
  type: ChartType.dynamicGraph,
  typeString: 'dynamicGraph',
  aliases: const ['streamingGraph', 'liveGraph', 'realtimeGraph'],
  fromJson: DynamicGraphConfig.fromJson,
  description: 'Live-updating graph that appends nodes and edges over time '
      'via a stream events sequence. Force layout re-runs as graph grows.',
  tags: const ['graph', 'dynamic', 'streaming', 'live', 'realtime'],
);

final ChartRegistration calendarGraphRegistration = ChartRegistration(
  type: ChartType.calendarGraph,
  typeString: 'calendarGraph',
  aliases: const ['dateGraph', 'eventGraph', 'calendarNetwork'],
  fromJson: CalendarGraphConfig.fromJson,
  description: 'Graph where nodes are positioned on a calendar year grid by '
      'their date field. Edges connect events across dates.',
  tags: const ['graph', 'calendar', 'date', 'event', 'network'],
);

final ChartRegistration webkitDepGraphRegistration = ChartRegistration(
  type: ChartType.webkitDepGraph,
  typeString: 'webkitDepGraph',
  aliases: const ['depGraph', 'dagGraph', 'dependencyGraph', 'dependencyDag'],
  fromJson: WebkitDepGraphConfig.fromJson,
  description: 'Hierarchical directed acyclic graph (DAG) for dependency '
      'visualisation. Nodes are sorted into depth layers with Bézier edges and arrows.',
  tags: const ['graph', 'dag', 'dependency', 'hierarchy', 'directed'],
);

// ─── Combined bundle ─────────────────────────────────────────────────────────

/// Register all 22 new chart types (5 general + 7 tree + 9 graph + 1 custom).
final RegistrationBundle generalTreeGraphBundle = RegistrationBundle(
  name: 'generalTreeGraphBundle',
  description: '22 new chart types: '
      '5 general (table, themeRiver, pictorialBar, matrix, chord), '
      '7 tree (treeLTR, treeRTL, treeTTB, treeBTT, treeRadial, treePolyline, multipleTrees), '
      '9 graph (lesMiserables, forceGraph, simpleGraph, cartesianGraph, '
      'overlapLabelGraph, lifeExpectancyGraph, dynamicGraph, calendarGraph, webkitDepGraph)',
  registrations: [
    // General
    tableRegistration,
    themeRiverRegistration,
    pictorialBarRegistration,
    matrixRegistration,
    chordRegistration,
    // Tree
    treeLTRRegistration,
    treeRTLRegistration,
    treeTTBRegistration,
    treeBTTRegistration,
    treeRadialRegistration,
    treePolylineRegistration,
    multipleTreesRegistration,
    // Graph
    lesMiserablesRegistration,
    forceGraphRegistration,
    simpleGraphRegistration,
    cartesianGraphRegistration,
    overlapLabelGraphRegistration,
    lifeExpectancyGraphRegistration,
    dynamicGraphRegistration,
    calendarGraphRegistration,
    webkitDepGraphRegistration,
  ],
);
