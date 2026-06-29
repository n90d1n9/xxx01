/// Complete chart registration bundle — registers every chart type
/// implemented in this library with [ChartRegistry].
///
/// Usage in main():
/// ```dart
/// void main() {
///   completeChartsBundle.register();   // all charts
///   // — or selectively —
///   coreChartsBundle.register();
///   advancedChartsBundle.register();
///   tradingChartsBundle.register();
///   statisticalChartsBundle.register();
/// }
/// ```
library complete_chart_registration_bundle;

import '../core/config/chart_type.dart';
import '../core/registry/chart_registry.dart';
import '../core/registry/chart_registration.dart';

// ── chart config imports ──────────────────────────────────
// Basic / core
import '../charts/bar_chart.dart';
import '../charts/line_chart.dart';
import '../charts/pie_donut_chart.dart';
import '../charts/area_chart.dart';
import '../charts/scatter_chart.dart';
import '../charts/bubble_chart.dart';

// Advanced (previous session)
import '../charts/sunburst_chart.dart';
import '../charts/funnel_chart.dart';
import '../charts/sankey_chart.dart';
import '../charts/waterfall_chart.dart';
import '../charts/gauge_chart.dart';
import '../charts/radar_chart.dart';
import '../charts/gantt_chart.dart';
import '../charts/polar_bar_chart.dart';
import '../charts/treemap_chart.dart';

// New batch
import '../charts/combo_chart.dart';
import '../charts/lollipop_chart.dart';
import '../charts/bullet_chart.dart';
import '../charts/sparkline_chart.dart';
import '../charts/histogram_chart.dart';
import '../charts/box_plot_chart.dart';
import '../charts/candlestick_ohlc_chart.dart';
import '../charts/violin_chart.dart';
import '../charts/heatmap_calendar_parallel_charts.dart';
import '../charts/trading_charts.dart';
import '../charts/ridgeline_strip_error_bar_charts.dart';
import '../charts/network_radial_timeline_wordcloud_charts.dart';

// ─────────────────────────────────────────────────────────
// CORE bundle  (bar, line, area, pie/donut, scatter, bubble)
// ─────────────────────────────────────────────────────────

final ChartRegistration barRegistration = ChartRegistration(
  type: ChartType.bar,
  typeString: 'bar',
  aliases: const ['stackedBar', 'groupedBar', 'horizontalBar', 'stackedHorizontalBar'],
  fromJson: BarChartConfig.fromJson,
  description: 'Vertical/horizontal bar chart with stacked & grouped variants',
  tags: const ['basic', 'comparison', 'categorical'],
);

final ChartRegistration lineRegistration = ChartRegistration(
  type: ChartType.line,
  typeString: 'line',
  aliases: const ['lineArea'],
  fromJson: LineChartConfig.fromJson,
  description: 'Line chart with optional area fill and smooth curves',
  tags: const ['basic', 'trend', 'time-series'],
);

final ChartRegistration areaRegistration = ChartRegistration(
  type: ChartType.area,
  typeString: 'area',
  aliases: const ['stackedArea'],
  fromJson: AreaChartConfig.fromJson,
  description: 'Filled area chart, stacked variant supported',
  tags: const ['basic', 'trend', 'composition'],
);

final ChartRegistration pieRegistration = ChartRegistration(
  type: ChartType.pie,
  typeString: 'pie',
  aliases: const ['donut'],
  fromJson: PieChartConfig.fromJson,
  description: 'Pie and donut chart with explode and label placement',
  tags: const ['basic', 'part-to-whole'],
);

final ChartRegistration scatterRegistration = ChartRegistration(
  type: ChartType.scatter,
  typeString: 'scatter',
  aliases: const [],
  fromJson: ScatterChartConfig.fromJson,
  description: 'X-Y scatter plot with optional regression line',
  tags: const ['basic', 'correlation'],
);

final ChartRegistration bubbleRegistration = ChartRegistration(
  type: ChartType.bubble,
  typeString: 'bubble',
  aliases: const [],
  fromJson: BubbleChartConfig.fromJson,
  description: 'Bubble chart — scatter with variable dot radius',
  tags: const ['relational', 'multivariate'],
);

final RegistrationBundle coreChartsBundle = RegistrationBundle(
  name: 'core',
  description: 'Essential chart types: bar, line, area, pie, scatter, bubble',
  registrations: [
    barRegistration, lineRegistration, areaRegistration,
    pieRegistration, scatterRegistration, bubbleRegistration,
  ],
);

// ─────────────────────────────────────────────────────────
// ADVANCED bundle  (hierarchy, flow, radial)
// ─────────────────────────────────────────────────────────

final ChartRegistration sunburstRegistration = ChartRegistration(
  type: ChartType.sunburst,
  typeString: 'sunburst',
  aliases: const [],
  fromJson: SunburstChartConfig.fromJson,
  description: 'Multi-ring radial hierarchy with drill-down',
  tags: const ['hierarchy', 'radial', 'drill-down'],
);

final ChartRegistration funnelRegistration = ChartRegistration(
  type: ChartType.funnel,
  typeString: 'funnel',
  aliases: const ['pyramid'],
  fromJson: FunnelChartConfig.fromJson,
  description: 'Conversion funnel / sales pipeline',
  tags: const ['flow', 'conversion', 'process'],
);

final ChartRegistration sankeyRegistration = ChartRegistration(
  type: ChartType.sankey,
  typeString: 'sankey',
  aliases: const [],
  fromJson: SankeyChartConfig.fromJson,
  description: 'Directional flow diagram with proportional link widths',
  tags: const ['flow', 'network', 'alluvial'],
);

final ChartRegistration waterfallRegistration = ChartRegistration(
  type: ChartType.waterfall,
  typeString: 'waterfall',
  aliases: const ['bridge', 'cascade'],
  fromJson: WaterfallChartConfig.fromJson,
  description: 'Running-total waterfall / bridge chart',
  tags: const ['flow', 'financial', 'cumulative'],
);

final ChartRegistration gaugeRegistration = ChartRegistration(
  type: ChartType.gauge,
  typeString: 'gauge',
  aliases: const ['speedometer'],
  fromJson: GaugeChartConfig.fromJson,
  description: 'Arc speedometer with colored bands and needle',
  tags: const ['radial', 'KPI', 'single-value'],
);

final ChartRegistration radarRegistration = ChartRegistration(
  type: ChartType.radar,
  typeString: 'radar',
  aliases: const ['spider', 'web'],
  fromJson: RadarChartConfig.fromJson,
  description: 'Spider / web chart for multivariate comparison',
  tags: const ['radial', 'multivariate', 'comparison'],
);

final ChartRegistration ganttRegistration = ChartRegistration(
  type: ChartType.gantt,
  typeString: 'gantt',
  aliases: const [],
  fromJson: GanttChartConfig.fromJson,
  description: 'Project timeline with milestones, dependencies, and progress',
  tags: const ['flow', 'project', 'timeline'],
);

final ChartRegistration polarBarRegistration = ChartRegistration(
  type: ChartType.polarBar,
  typeString: 'polarBar',
  aliases: const ['nightingale', 'rose', 'coxcomb'],
  fromJson: PolarBarChartConfig.fromJson,
  description: 'Nightingale rose / polar bar chart',
  tags: const ['radial', 'comparison', 'angular'],
);

final ChartRegistration treemapRegistration = ChartRegistration(
  type: ChartType.treemap,
  typeString: 'treemap',
  aliases: const [],
  fromJson: TreemapChartConfig.fromJson,
  description: 'Hierarchical treemap with squarified layout',
  tags: const ['hierarchy', 'part-to-whole', 'area'],
);

final RegistrationBundle advancedChartsBundle = RegistrationBundle(
  name: 'advanced',
  description: 'Advanced charts: sunburst, funnel, sankey, waterfall, gauge, radar, gantt, polarBar, treemap',
  registrations: [
    sunburstRegistration, funnelRegistration, sankeyRegistration,
    waterfallRegistration, gaugeRegistration, radarRegistration,
    ganttRegistration, polarBarRegistration, treemapRegistration,
  ],
);

// ─────────────────────────────────────────────────────────
// STATISTICAL bundle
// ─────────────────────────────────────────────────────────

final ChartRegistration histogramRegistration = ChartRegistration(
  type: ChartType.histogram,
  typeString: 'histogram',
  aliases: const [],
  fromJson: HistogramChartConfig.fromJson,
  description: 'Frequency distribution with auto-binning and KDE overlay',
  tags: const ['statistical', 'distribution'],
);

final ChartRegistration boxPlotRegistration = ChartRegistration(
  type: ChartType.boxPlot,
  typeString: 'boxPlot',
  aliases: const ['whisker', 'box'],
  fromJson: BoxPlotChartConfig.fromJson,
  description: 'Box-and-whisker plot with outliers and notch option',
  tags: const ['statistical', 'distribution', 'comparison'],
);

final ChartRegistration violinRegistration = ChartRegistration(
  type: ChartType.violin,
  typeString: 'violin',
  aliases: const [],
  fromJson: ViolinChartConfig.fromJson,
  description: 'KDE violin shape with optional box-plot overlay',
  tags: const ['statistical', 'distribution'],
);

final ChartRegistration ridgelineRegistration = ChartRegistration(
  type: ChartType.ridgeline,
  typeString: 'ridgeline',
  aliases: const ['ridge', 'joyplot'],
  fromJson: RidgelineChartConfig.fromJson,
  description: 'Offset density curves per group (joy plot)',
  tags: const ['statistical', 'distribution', 'comparison'],
);

final ChartRegistration stripRegistration = ChartRegistration(
  type: ChartType.strip,
  typeString: 'strip',
  aliases: const ['dotPlot'],
  fromJson: StripChartConfig.fromJson,
  description: 'Individual data points as jittered dots on a strip',
  tags: const ['statistical', 'distribution'],
);

final ChartRegistration errorBarRegistration = ChartRegistration(
  type: ChartType.errorBar,
  typeString: 'errorBar',
  aliases: const ['ci', 'confidence'],
  fromJson: ErrorBarChartConfig.fromJson,
  description: 'Mean ± error bars / confidence intervals',
  tags: const ['statistical', 'uncertainty'],
);

final RegistrationBundle statisticalChartsBundle = RegistrationBundle(
  name: 'statistical',
  description: 'Statistical charts: histogram, boxPlot, violin, ridgeline, strip, errorBar',
  registrations: [
    histogramRegistration, boxPlotRegistration, violinRegistration,
    ridgelineRegistration, stripRegistration, errorBarRegistration,
  ],
);

// ─────────────────────────────────────────────────────────
// TRADING bundle
// ─────────────────────────────────────────────────────────

final ChartRegistration candlestickRegistration = ChartRegistration(
  type: ChartType.candlestick,
  typeString: 'candlestick',
  aliases: const [],
  fromJson: CandlestickChartConfig.fromJsonCandlestick,
  description: 'Japanese candlestick chart with optional volume pane',
  tags: const ['trading', 'financial', 'OHLC'],
);

final ChartRegistration ohlcRegistration = ChartRegistration(
  type: ChartType.ohlc,
  typeString: 'ohlc',
  aliases: const [],
  fromJson: CandlestickChartConfig.fromJsonOhlc,
  description: 'OHLC bar chart (tick marks on vertical lines)',
  tags: const ['trading', 'financial', 'OHLC'],
);

final ChartRegistration kagiRegistration = ChartRegistration(
  type: ChartType.kagi,
  typeString: 'kagi',
  aliases: const [],
  fromJson: KagiChartConfig.fromJson,
  description: 'Kagi chart — price reversal lines ignoring time axis',
  tags: const ['trading', 'financial', 'reversal'],
);

final ChartRegistration renkoRegistration = ChartRegistration(
  type: ChartType.renko,
  typeString: 'renko',
  aliases: const [],
  fromJson: RenkoChartConfig.fromJson,
  description: 'Renko chart — fixed-size price bricks',
  tags: const ['trading', 'financial', 'reversal'],
);

final ChartRegistration macdRegistration = ChartRegistration(
  type: ChartType.macd,
  typeString: 'macd',
  aliases: const [],
  fromJson: MacdChartConfig.fromJson,
  description: 'MACD indicator — histogram, MACD line, and signal line',
  tags: const ['trading', 'financial', 'indicator'],
);

final RegistrationBundle tradingChartsBundle = RegistrationBundle(
  name: 'trading',
  description: 'Trading/financial charts: candlestick, OHLC, kagi, renko, MACD',
  registrations: [
    candlestickRegistration, ohlcRegistration,
    kagiRegistration, renkoRegistration, macdRegistration,
  ],
);

// ─────────────────────────────────────────────────────────
// COMPARISON / KPI bundle
// ─────────────────────────────────────────────────────────

final ChartRegistration comboRegistration = ChartRegistration(
  type: ChartType.combo,
  typeString: 'combo',
  aliases: const ['mixed'],
  fromJson: ComboChartConfig.fromJson,
  description: 'Overlaid bar + line series on shared axis with optional dual Y',
  tags: const ['comparison', 'overlay', 'mixed'],
);

final ChartRegistration lollipopRegistration = ChartRegistration(
  type: ChartType.lollipop,
  typeString: 'lollipop',
  aliases: const ['dumbbell'],
  fromJson: LollipopChartConfig.fromJson,
  description: 'Dot + stem lollipop chart, horizontal or vertical',
  tags: const ['comparison', 'categorical'],
);

final ChartRegistration bulletRegistration = ChartRegistration(
  type: ChartType.bullet,
  typeString: 'bullet',
  aliases: const [],
  fromJson: BulletChartConfig.fromJson,
  description: 'Bullet KPI bar — actual vs target with qualitative bands',
  tags: const ['KPI', 'comparison', 'performance'],
);

final ChartRegistration sparklineRegistration = ChartRegistration(
  type: ChartType.sparkline,
  typeString: 'sparkline',
  aliases: const [],
  fromJson: SparklineChartConfig.fromJson,
  description: 'Minimal inline trend chart for tables and KPI cards',
  tags: const ['KPI', 'inline', 'trend'],
);

// ─────────────────────────────────────────────────────────
// RELATIONAL / MISC bundle
// ─────────────────────────────────────────────────────────

final ChartRegistration heatmapRegistration = ChartRegistration(
  type: ChartType.heatmap,
  typeString: 'heatmap',
  aliases: const [],
  fromJson: HeatmapChartConfig.fromJson,
  description: '2-D color-encoded matrix heatmap',
  tags: const ['relational', 'matrix', 'density'],
);

final ChartRegistration calendarRegistration = ChartRegistration(
  type: ChartType.calendar,
  typeString: 'calendar',
  aliases: const ['activityCalendar'],
  fromJson: CalendarChartConfig.fromJson,
  description: 'GitHub-style activity calendar heatmap',
  tags: const ['calendar', 'time-series', 'density'],
);

final ChartRegistration parallelRegistration = ChartRegistration(
  type: ChartType.parallel,
  typeString: 'parallel',
  aliases: const ['parallelCoordinates'],
  fromJson: ParallelChartConfig.fromJson,
  description: 'Parallel coordinates plot for multivariate data',
  tags: const ['multivariate', 'comparison', 'relational'],
);

final ChartRegistration networkRegistration = ChartRegistration(
  type: ChartType.network,
  typeString: 'network',
  aliases: const ['graph', 'forceDirected'],
  fromJson: NetworkChartConfig.fromJson,
  description: 'Force-directed node-link network graph',
  tags: const ['network', 'relational', 'graph'],
);

final ChartRegistration radialRegistration = ChartRegistration(
  type: ChartType.radial,
  typeString: 'radial',
  aliases: const ['rings', 'activityRings'],
  fromJson: RadialChartConfig.fromJson,
  description: 'Concentric progress arc rings — Apple Watch style',
  tags: const ['KPI', 'radial', 'progress'],
);

final ChartRegistration timelineRegistration = ChartRegistration(
  type: ChartType.timeline,
  typeString: 'timeline',
  aliases: const [],
  fromJson: TimelineChartConfig.fromJson,
  description: 'Vertical event timeline with labels and connectors',
  tags: const ['timeline', 'events', 'chronological'],
);

final ChartRegistration wordcloudRegistration = ChartRegistration(
  type: ChartType.wordcloud,
  typeString: 'wordcloud',
  aliases: const ['tagCloud'],
  fromJson: WordcloudChartConfig.fromJson,
  description: 'Proportional word cloud with spiral layout',
  tags: const ['text', 'frequency', 'visual'],
);

// ─────────────────────────────────────────────────────────
// COMPLETE bundle (all charts)
// ─────────────────────────────────────────────────────────

/// Registers every chart type. Call once in main():
/// ```dart
/// completeChartsBundle.register();
/// ```
final RegistrationBundle completeChartsBundle = RegistrationBundle(
  name: 'complete',
  description: 'All ${_allRegistrations.length} chart types in the library',
  registrations: _allRegistrations,
);

final List<ChartRegistration> _allRegistrations = [
  // core
  barRegistration, lineRegistration, areaRegistration,
  pieRegistration, scatterRegistration, bubbleRegistration,
  // advanced
  sunburstRegistration, funnelRegistration, sankeyRegistration,
  waterfallRegistration, gaugeRegistration, radarRegistration,
  ganttRegistration, polarBarRegistration, treemapRegistration,
  // statistical
  histogramRegistration, boxPlotRegistration, violinRegistration,
  ridgelineRegistration, stripRegistration, errorBarRegistration,
  // trading
  candlestickRegistration, ohlcRegistration,
  kagiRegistration, renkoRegistration, macdRegistration,
  // comparison / KPI
  comboRegistration, lollipopRegistration,
  bulletRegistration, sparklineRegistration,
  // relational / misc
  heatmapRegistration, calendarRegistration, parallelRegistration,
  networkRegistration, radialRegistration,
  timelineRegistration, wordcloudRegistration,
];

/// Quick lookup: get registration by type string (lowercase, no dashes).
ChartRegistration? findRegistration(String typeString) {
  final key = typeString.toLowerCase().replaceAll(RegExp(r'[-_]'), '');
  for (final r in _allRegistrations) {
    if (r.typeString.toLowerCase() == key) return r;
    if (r.aliases.any((a) => a.toLowerCase() == key)) return r;
  }
  return null;
}

/// Print a catalog of all registered chart types to the console.
void printChartCatalog() {
  // ignore: avoid_print
  print('╔══════════════════════════════════════════════════════╗');
  // ignore: avoid_print
  print('║          Chart Library — ${_allRegistrations.length} Chart Types               ║');
  // ignore: avoid_print
  print('╠══════════════════════════════════════════════════════╣');
  for (final r in _allRegistrations) {
    // ignore: avoid_print
    print('║  ${r.typeString.padRight(20)} ${r.description.substring(0, math.min(r.description.length, 32)).padRight(32)} ║');
  }
  // ignore: avoid_print
  print('╚══════════════════════════════════════════════════════╝');
}

// needed for math.min in printChartCatalog
import 'dart:math' as math;
