/// Enum of all supported chart types.
///
/// When adding a new chart type:
///  1. Add the enum value here.
///  2. Register its config factory in `core/utils/helper.dart` → `getChartConfig`.
///  3. Add mapping in `chartTypeToString` and `getChartType`.
///
/// v2 additions:
///  - combo / mixed   : overlaid bar + line on shared axis
///  - sparkline       : minimal inline trend line (no axes/labels)
///  - violin          : distribution shape + box-plot overlay
///  - kagi            : price-reversal chart (trading)
///  - renko           : fixed-brick price chart (trading)
///  - ridgeline       : offset density/distribution curves
///  - macd            : Moving Average Convergence Divergence (trading)
///  - ohlc            : Open-High-Low-Close bar chart (trading alternative to candlestick)
///  - strip           : dot-plot strip chart (all individual data points)
///  - bullet          : horizontal performance vs target gauge bar
///  - lollipop        : bar with circle cap — cleaner than bar for comparisons
enum ChartType {
  // ---- Basic ----
  bar,
  stackedBar,
  groupedBar,
  horizontalBar,
  stackedHorizontalBar,
  line,
  lineArea,
  area,
  stackedArea,
  pie,
  donut,
  scatter,

  // ---- Combo / Overlay ----
  /// Overlaid bar + line series on a shared axis.
  /// Use [Series.type] to tag individual series as 'bar' or 'line'.
  combo,

  // ---- Statistical ----
  boxPlot,
  histogram,
  errorBar,
  candlestick,

  /// Open-High-Low-Close bar chart (OHLC bars instead of candlestick bodies).
  ohlc,

  /// Kernel-density distribution shape with optional box-plot overlay.
  violin,

  /// Strip / dot plot — each data point drawn as a circle on a strip.
  strip,

  // ---- Relational ----
  bubble,
  heatmap,
  treemap,
  sunburst,
  network,

  // ---- Flow / Process ----
  sankey,
  funnel,
  waterfall,
  timeline,
  gantt,

  // ---- Radial / Angular ----
  radar,
  radial,
  gauge,
  polarBar,

  /// Bullet chart — horizontal bar with target marker and qualitative bands.
  bullet,

  // ---- Sparkline ----
  /// Minimal inline trend-line (no axes, no labels).
  /// Designed for embedding in tables / KPI cards.
  sparkline,

  // ---- Distribution / Continuous ----
  /// Offset, overlapping density curves per category — good for comparing
  /// distributions across many groups.
  ridgeline,

  // ---- Trading / Time-series ----
  /// Kagi chart: price-reversal lines, ignores time axis.
  kagi,

  /// Renko chart: fixed-brick reversal chart.
  renko,

  /// MACD indicator chart (bar histogram + signal lines).
  macd,

  /// Lollipop: dot + stem, cleaner alternative to bar for comparisons.
  lollipop,

  // ---- Geo ----
  choropleth,

  // ---- Misc ----
  calendar,
  wordcloud,
  parallel,
  custom,
}

/// Convert a string to [ChartType].
ChartType getChartType(String type) {
  switch (type.toLowerCase().replaceAll('_', '').replaceAll('-', '')) {
    // basic
    case 'bar': return ChartType.bar;
    case 'stackedbar': return ChartType.stackedBar;
    case 'groupedbar': return ChartType.groupedBar;
    case 'horizontalbar': return ChartType.horizontalBar;
    case 'stackedhorizontalbar': return ChartType.stackedHorizontalBar;
    case 'line': return ChartType.line;
    case 'linearea': return ChartType.lineArea;
    case 'area': return ChartType.area;
    case 'stackedarea': return ChartType.stackedArea;
    case 'pie': return ChartType.pie;
    case 'donut': return ChartType.donut;
    case 'scatter': return ChartType.scatter;
    // combo
    case 'combo':
    case 'mixed': return ChartType.combo;
    // statistical
    case 'boxplot': return ChartType.boxPlot;
    case 'histogram': return ChartType.histogram;
    case 'errorbar': return ChartType.errorBar;
    case 'candlestick': return ChartType.candlestick;
    case 'ohlc': return ChartType.ohlc;
    case 'violin': return ChartType.violin;
    case 'strip':
    case 'dotplot': return ChartType.strip;
    // relational
    case 'bubble': return ChartType.bubble;
    case 'heatmap': return ChartType.heatmap;
    case 'treemap': return ChartType.treemap;
    case 'sunburst': return ChartType.sunburst;
    case 'network': return ChartType.network;
    // flow
    case 'sankey': return ChartType.sankey;
    case 'funnel': return ChartType.funnel;
    case 'waterfall': return ChartType.waterfall;
    case 'timeline': return ChartType.timeline;
    case 'gantt': return ChartType.gantt;
    // radial
    case 'radar': return ChartType.radar;
    case 'radial': return ChartType.radial;
    case 'gauge': return ChartType.gauge;
    case 'polarbar': return ChartType.polarBar;
    case 'bullet': return ChartType.bullet;
    // sparkline
    case 'sparkline': return ChartType.sparkline;
    // distribution
    case 'ridgeline':
    case 'ridge': return ChartType.ridgeline;
    // trading
    case 'kagi': return ChartType.kagi;
    case 'renko': return ChartType.renko;
    case 'macd': return ChartType.macd;
    case 'lollipop': return ChartType.lollipop;
    // geo
    case 'choropleth': return ChartType.choropleth;
    // misc
    case 'calendar': return ChartType.calendar;
    case 'wordcloud': return ChartType.wordcloud;
    case 'parallel': return ChartType.parallel;
    case 'custom': return ChartType.custom;
    default: return ChartType.line;
  }
}

/// Convert [ChartType] back to a canonical string.
String chartTypeToString(ChartType type) {
  switch (type) {
    case ChartType.bar: return 'bar';
    case ChartType.stackedBar: return 'stackedBar';
    case ChartType.groupedBar: return 'groupedBar';
    case ChartType.horizontalBar: return 'horizontalBar';
    case ChartType.stackedHorizontalBar: return 'stackedHorizontalBar';
    case ChartType.line: return 'line';
    case ChartType.lineArea: return 'lineArea';
    case ChartType.area: return 'area';
    case ChartType.stackedArea: return 'stackedArea';
    case ChartType.pie: return 'pie';
    case ChartType.donut: return 'donut';
    case ChartType.scatter: return 'scatter';
    case ChartType.combo: return 'combo';
    case ChartType.boxPlot: return 'boxPlot';
    case ChartType.histogram: return 'histogram';
    case ChartType.errorBar: return 'errorBar';
    case ChartType.candlestick: return 'candlestick';
    case ChartType.ohlc: return 'ohlc';
    case ChartType.violin: return 'violin';
    case ChartType.strip: return 'strip';
    case ChartType.bubble: return 'bubble';
    case ChartType.heatmap: return 'heatmap';
    case ChartType.treemap: return 'treemap';
    case ChartType.sunburst: return 'sunburst';
    case ChartType.network: return 'network';
    case ChartType.sankey: return 'sankey';
    case ChartType.funnel: return 'funnel';
    case ChartType.waterfall: return 'waterfall';
    case ChartType.timeline: return 'timeline';
    case ChartType.gantt: return 'gantt';
    case ChartType.radar: return 'radar';
    case ChartType.radial: return 'radial';
    case ChartType.gauge: return 'gauge';
    case ChartType.polarBar: return 'polarBar';
    case ChartType.bullet: return 'bullet';
    case ChartType.sparkline: return 'sparkline';
    case ChartType.ridgeline: return 'ridgeline';
    case ChartType.kagi: return 'kagi';
    case ChartType.renko: return 'renko';
    case ChartType.macd: return 'macd';
    case ChartType.lollipop: return 'lollipop';
    case ChartType.choropleth: return 'choropleth';
    case ChartType.calendar: return 'calendar';
    case ChartType.wordcloud: return 'wordcloud';
    case ChartType.parallel: return 'parallel';
    case ChartType.custom: return 'custom';
  }
}
