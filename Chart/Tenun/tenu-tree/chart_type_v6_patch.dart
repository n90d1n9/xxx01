/// chart_type_v6_patch.dart
///
/// Apply this patch to chart_type.dart to add 21 new chart types:
///   General  (5): table, themeRiver, pictorialBar, matrix, chord
///   Tree     (7): treeLTR, treeRTL, treeTTB, treeBTT, treeRadial,
///                 treePolyline, multipleTrees
///   Graph    (9): lesMiserables, forceGraph, simpleGraph, cartesianGraph,
///                 overlapLabelGraph, lifeExpectancyGraph, dynamicGraph,
///                 calendarGraph, webkitDepGraph
///
/// ── STEP 1 ─ Add to enum ChartType { … } ───────────────────────────────
///
///   // ── General ──────────────────────────────────────────────────────────
///   table,               // sortable, scrollable data table
///   themeRiver,          // stacked stream / ThemeRiver
///   pictorialBar,        // bar chart using repeated symbol shapes
///   matrix,              // correlation / adjacency matrix with colour cells
///   chord,               // chord diagram (flow between categories)
///
///   // ── Tree (collapsible) ───────────────────────────────────────────────
///   treeLTR,             // left → right tree
///   treeRTL,             // right → left tree
///   treeTTB,             // top → bottom tree
///   treeBTT,             // bottom → top tree
///   treeRadial,          // radial / polar tree
///   treePolyline,        // tree with orthogonal polyline edges
///   multipleTrees,       // multiple independent trees side-by-side
///
///   // ── Graph ────────────────────────────────────────────────────────────
///   lesMiserables,       // community-colored force graph
///   forceGraph,          // configurable force-directed graph
///   simpleGraph,         // static-positioned graph
///   cartesianGraph,      // graph on Cartesian X/Y axes
///   overlapLabelGraph,   // force graph with overlapped labels hidden
///   lifeExpectancyGraph, // animated bubble timeline (Gapminder style)
///   dynamicGraph,        // live-streaming node/edge graph
///   calendarGraph,       // nodes placed on a calendar grid
///   webkitDepGraph,      // hierarchical DAG dependency graph
///
///
/// ── STEP 2 ─ Add cases to getChartType() switch ─────────────────────────
///
///   // general
///   case 'table':                   return ChartType.table;
///   case 'themeriver':
///   case 'stream':
///   case 'streamgraph':             return ChartType.themeRiver;
///   case 'pictorialbar':
///   case 'symbolbar':               return ChartType.pictorialBar;
///   case 'matrix':
///   case 'correlationmatrix':
///   case 'adjacencymatrix':         return ChartType.matrix;
///   case 'chord':
///   case 'chorddiagram':            return ChartType.chord;
///   // tree
///   case 'treeltr':
///   case 'treerightward':
///   case 'treehorizontal':          return ChartType.treeLTR;
///   case 'treertl':
///   case 'treeleftward':            return ChartType.treeRTL;
///   case 'treettb':
///   case 'treedownward':
///   case 'treevertical':            return ChartType.treeTTB;
///   case 'treebtt':
///   case 'treeupward':              return ChartType.treeBTT;
///   case 'treeradial':
///   case 'polartree':
///   case 'radialtree':              return ChartType.treeRadial;
///   case 'treepolyline':
///   case 'treeortho':
///   case 'treeelbow':               return ChartType.treePolyline;
///   case 'multipletrees':
///   case 'multitree':               return ChartType.multipleTrees;
///   // graph
///   case 'lesmiserables':
///   case 'lesmis':
///   case 'communitygraph':          return ChartType.lesMiserables;
///   case 'forcegraph':
///   case 'forcelayout':
///   case 'forcedirected':           return ChartType.forceGraph;
///   case 'simplegraph':             return ChartType.simpleGraph;
///   case 'cartesiangraph':
///   case 'graphcartesian':
///   case 'xygraph':                 return ChartType.cartesianGraph;
///   case 'overlaplabelgraph':
///   case 'hidelabelgraph':          return ChartType.overlapLabelGraph;
///   case 'lifeexpectancygraph':
///   case 'gapminder':
///   case 'bubbletimeline':          return ChartType.lifeExpectancyGraph;
///   case 'dynamicgraph':
///   case 'streaminggraph':
///   case 'livegraph':               return ChartType.dynamicGraph;
///   case 'calendargraph':           return ChartType.calendarGraph;
///   case 'webkitdepgraph':
///   case 'depgraph':
///   case 'daggraph':
///   case 'dependencygraph':         return ChartType.webkitDepGraph;
///
///
/// ── STEP 3 ─ Add cases to chartTypeToString() switch ────────────────────
///
///   case ChartType.table:                return 'table';
///   case ChartType.themeRiver:           return 'themeRiver';
///   case ChartType.pictorialBar:         return 'pictorialBar';
///   case ChartType.matrix:               return 'matrix';
///   case ChartType.chord:                return 'chord';
///   case ChartType.treeLTR:              return 'treeLTR';
///   case ChartType.treeRTL:              return 'treeRTL';
///   case ChartType.treeTTB:              return 'treeTTB';
///   case ChartType.treeBTT:              return 'treeBTT';
///   case ChartType.treeRadial:           return 'treeRadial';
///   case ChartType.treePolyline:         return 'treePolyline';
///   case ChartType.multipleTrees:        return 'multipleTrees';
///   case ChartType.lesMiserables:        return 'lesMiserables';
///   case ChartType.forceGraph:           return 'forceGraph';
///   case ChartType.simpleGraph:          return 'simpleGraph';
///   case ChartType.cartesianGraph:       return 'cartesianGraph';
///   case ChartType.overlapLabelGraph:    return 'overlapLabelGraph';
///   case ChartType.lifeExpectancyGraph:  return 'lifeExpectancyGraph';
///   case ChartType.dynamicGraph:         return 'dynamicGraph';
///   case ChartType.calendarGraph:        return 'calendarGraph';
///   case ChartType.webkitDepGraph:       return 'webkitDepGraph';
///
// ignore_for_file: unused_element
library chart_type_v6_patch;
