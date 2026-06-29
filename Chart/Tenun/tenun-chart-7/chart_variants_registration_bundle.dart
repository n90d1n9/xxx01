/// Registration bundle for all bar, line/area, and pie variant charts
/// added in the v3 batch (39 additional chart sub-types).
///
/// Usage:
/// ```dart
/// void main() {
///   completeChartsBundle.register();   // original 37 types
///   newChartsBundle.register();         // choropleth + custom + slope + dumbbell + areaBump
///   variantsBundle.register();          // all bar / line / pie variants
///   runApp(const MyApp());
/// }
/// ```
library chart_variants_registration_bundle;

import '../core/config/chart_type.dart';
import '../core/registry/chart_registry.dart';
import '../core/registry/chart_registration.dart';

import '../charts/bar_chart_variants.dart';
import '../charts/line_area_variants.dart';
import '../charts/pie_chart_variants.dart';

// ─── BAR VARIANTS ──────────────────────────────────────────────────────────

final ChartRegistration barBackgroundRegistration = ChartRegistration(
  type: ChartType.barBackground,
  typeString: 'barBackground',
  aliases: const ['barWithBackground', 'barTrack'],
  fromJson: BarBackgroundChartConfig.fromJson,
  description: 'Bar chart with translucent full-height background track behind each bar',
  tags: const ['bar', 'background', 'track'],
);

final ChartRegistration barRaceRegistration = ChartRegistration(
  type: ChartType.barRace,
  typeString: 'barRace',
  aliases: const ['racing', 'barAnimation', 'rankingBar'],
  fromJson: BarRaceChartConfig.fromJson,
  description: 'Animated bar race — sorted descending, transitions between data frames',
  tags: const ['bar', 'animated', 'race', 'ranking'],
);

final ChartRegistration barGradientRegistration = ChartRegistration(
  type: ChartType.barGradient,
  typeString: 'barGradient',
  aliases: const ['gradientBar', 'clickableBar'],
  fromJson: BarGradientChartConfig.fromJson,
  description: 'Column chart with per-bar gradient fill and tap-to-select interaction',
  tags: const ['bar', 'gradient', 'interactive'],
);

final ChartRegistration barLabelRotationRegistration = ChartRegistration(
  type: ChartType.barLabelRotation,
  typeString: 'barLabelRotation',
  aliases: const ['rotatedLabels', 'barRotated'],
  fromJson: BarLabelRotationConfig.fromJson,
  description: 'Bar chart with configurable X-axis label rotation angle (0–90°)',
  tags: const ['bar', 'labels', 'rotation'],
);

final ChartRegistration barRoundedRegistration = ChartRegistration(
  type: ChartType.barRounded,
  typeString: 'barRounded',
  aliases: const ['roundedStacked', 'stackedRounded'],
  fromJson: BarRoundedStackedConfig.fromJson,
  description: 'Stacked column chart with rounded corners on the topmost segment',
  tags: const ['bar', 'stacked', 'rounded'],
);

final ChartRegistration barNormalizedRegistration = ChartRegistration(
  type: ChartType.barNormalized,
  typeString: 'barNormalized',
  aliases: const ['bar100', 'normalized', 'percentStacked'],
  fromJson: BarNormalizedConfig.fromJson,
  description: '100 %-normalised stacked bar — Y axis shows percentages',
  tags: const ['bar', 'stacked', 'normalized', '100%'],
);

final ChartRegistration negativeBarRegistration = ChartRegistration(
  type: ChartType.negativeBar,
  typeString: 'negativeBar',
  aliases: const ['divergingBar', 'positiveNegativeBar'],
  fromJson: NegativeBarConfig.fromJson,
  description: 'Horizontal diverging bar with shared zero baseline for negative values',
  tags: const ['bar', 'horizontal', 'negative', 'diverging'],
);

final ChartRegistration tangentialPolarBarRegistration = ChartRegistration(
  type: ChartType.tangentialPolarBar,
  typeString: 'tangentialPolarBar',
  aliases: const ['polarBarTangential', 'circularBar'],
  fromJson: TangentialPolarBarConfig.fromJson,
  description: 'Polar bar chart where labels are rotated tangentially along the arc',
  tags: const ['polar', 'bar', 'radial', 'tangential'],
);

final ChartRegistration barBrushRegistration = ChartRegistration(
  type: ChartType.barBrush,
  typeString: 'barBrush',
  aliases: const ['brushSelect', 'brushBar'],
  fromJson: BarBrushConfig.fromJson,
  description: 'Bar chart with drag-to-select brush range overlay',
  tags: const ['bar', 'brush', 'interactive', 'selection'],
);

// ─── LINE / AREA VARIANTS ──────────────────────────────────────────────────

final ChartRegistration areaPiecesRegistration = ChartRegistration(
  type: ChartType.areaPieces,
  typeString: 'areaPieces',
  aliases: const ['thresholdArea', 'coloredArea'],
  fromJson: AreaPiecesChartConfig.fromJson,
  description: 'Area chart split into colour-coded sections by threshold values',
  tags: const ['area', 'threshold', 'colour'],
);

final ChartRegistration lineGradientRegistration = ChartRegistration(
  type: ChartType.lineGradient,
  typeString: 'lineGradient',
  aliases: const ['gradientLine', 'gradientArea'],
  fromJson: LineGradientChartConfig.fromJson,
  description: 'Line with horizontal gradient stroke and optional gradient area fill',
  tags: const ['line', 'area', 'gradient'],
);

final ChartRegistration lineConfidenceBandRegistration = ChartRegistration(
  type: ChartType.lineConfidenceBand,
  typeString: 'lineConfidenceBand',
  aliases: const ['confidenceBand', 'errorBand', 'ribbon'],
  fromJson: LineConfidenceBandConfig.fromJson,
  description: 'Line with symmetric or asymmetric shaded confidence/error band',
  tags: const ['line', 'confidence', 'band', 'statistical'],
);

final ChartRegistration lineMarklineRegistration = ChartRegistration(
  type: ChartType.lineMarkline,
  typeString: 'lineMarkline',
  aliases: const ['markLine', 'referenceLine', 'annotatedLine'],
  fromJson: LineMarklineConfig.fromJson,
  description: 'Line chart with named horizontal reference mark-lines (avg, min, max, fixed)',
  tags: const ['line', 'reference', 'annotation', 'markline'],
);

final ChartRegistration logAxisRegistration = ChartRegistration(
  type: ChartType.logAxis,
  typeString: 'logAxis',
  aliases: const ['logarithmic', 'logScale'],
  fromJson: LogAxisChartConfig.fromJson,
  description: 'Line/area chart on a logarithmic Y-axis (configurable base)',
  tags: const ['line', 'log', 'scale'],
);

final ChartRegistration functionPlotRegistration = ChartRegistration(
  type: ChartType.functionPlot,
  typeString: 'functionPlot',
  aliases: const ['function', 'mathPlot', 'equationPlot'],
  fromJson: FunctionPlotConfig.fromJson,
  description: 'Mathematical y = f(x) function plotter with configurable resolution',
  tags: const ['math', 'function', 'plot', 'equation'],
);

final ChartRegistration sparklineMatrixRegistration = ChartRegistration(
  type: ChartType.sparklineMatrix,
  typeString: 'sparklineMatrix',
  aliases: const ['miniLines', 'sparklineGrid', 'kpiGrid'],
  fromJson: SparklineMatrixConfig.fromJson,
  description: 'Grid of small sparklines — one per cell, ideal for KPI dashboards',
  tags: const ['sparkline', 'matrix', 'grid', 'kpi', 'mini'],
);

final ChartRegistration dynamicTimeSeriesRegistration = ChartRegistration(
  type: ChartType.dynamicTimeSeries,
  typeString: 'dynamicTimeSeries',
  aliases: const ['liveChart', 'streamingChart', 'realtime'],
  fromJson: DynamicTimeSeriesConfig.fromJson,
  description: 'Live-updating sliding-window time-series with configurable data generator',
  tags: const ['line', 'realtime', 'live', 'streaming'],
);

final ChartRegistration intradayLineRegistration = ChartRegistration(
  type: ChartType.intradayLine,
  typeString: 'intradayLine',
  aliases: const ['lineBreaks', 'gappedLine', 'intraday'],
  fromJson: IntradayLineConfig.fromJson,
  description: 'Line chart with explicit data gaps/breaks (null values create discontinuities)',
  tags: const ['line', 'gaps', 'breaks', 'intraday'],
);

final ChartRegistration lineClickAddRegistration = ChartRegistration(
  type: ChartType.lineClickAdd,
  typeString: 'lineClickAdd',
  aliases: const ['clickToAdd', 'interactiveLine'],
  fromJson: LineClickAddConfig.fromJson,
  description: 'Interactive line chart — tap anywhere to add new data points',
  tags: const ['line', 'interactive', 'draw'],
);

// ─── PIE VARIANTS ──────────────────────────────────────────────────────────

final ChartRegistration donutRegistration = ChartRegistration(
  type: ChartType.donut,
  typeString: 'donut',
  aliases: const ['doughnut', 'ring'],
  fromJson: DonutChartConfig.fromJson,
  description: 'Standard donut chart with configurable inner radius and centre label',
  tags: const ['pie', 'donut', 'ring'],
);

final ChartRegistration halfDonutRegistration = ChartRegistration(
  type: ChartType.halfDonut,
  typeString: 'halfDonut',
  aliases: const ['semicircle', 'halfPie', 'gaugeArc'],
  fromJson: HalfDonutChartConfig.fromJson,
  description: '180° semicircle donut — useful as a progress/gauge display',
  tags: const ['pie', 'donut', 'semicircle', 'half'],
);

final ChartRegistration paddedPieRegistration = ChartRegistration(
  type: ChartType.paddedPie,
  typeString: 'paddedPie',
  aliases: const ['gappedPie', 'spacedPie'],
  fromJson: PaddedPieChartConfig.fromJson,
  description: 'Pie chart with configurable gap (pad angle) between each slice',
  tags: const ['pie', 'gap', 'padAngle'],
);

final ChartRegistration nightingaleRegistration = ChartRegistration(
  type: ChartType.nightingale,
  typeString: 'nightingale',
  aliases: const ['rose', 'polarArea', 'coxcomb'],
  fromJson: NightingaleChartConfig.fromJson,
  description: 'Nightingale / rose chart — equal angles, radius or area encodes value',
  tags: const ['polar', 'pie', 'rose', 'nightingale'],
);

final ChartRegistration nestedPieRegistration = ChartRegistration(
  type: ChartType.nestedPie,
  typeString: 'nestedPie',
  aliases: const ['concentric', 'multiRing', 'multiLevelPie'],
  fromJson: NestedPieChartConfig.fromJson,
  description: 'Multiple concentric ring charts sharing the same centre point',
  tags: const ['pie', 'nested', 'rings', 'hierarchy'],
);

final ChartRegistration partitionPieRegistration = ChartRegistration(
  type: ChartType.partitionPie,
  typeString: 'partitionPie',
  aliases: const ['subSlice', 'drilldownPie'],
  fromJson: PartitionPieChartConfig.fromJson,
  description: 'Pie chart where one slice is further subdivided into sub-slices',
  tags: const ['pie', 'partition', 'drilldown', 'hierarchy'],
);

final ChartRegistration calendarPieRegistration = ChartRegistration(
  type: ChartType.calendarPie,
  typeString: 'calendarPie',
  aliases: const ['calendarChart', 'pieCal'],
  fromJson: CalendarPieChartConfig.fromJson,
  description: 'Month-grid calendar where each day cell contains a mini pie chart',
  tags: const ['pie', 'calendar', 'mini', 'grid'],
);

final ChartRegistration pieLabelLineRegistration = ChartRegistration(
  type: ChartType.pie,
  typeString: 'pieLabelLine',
  aliases: const ['labelLine', 'leaderLinePie'],
  fromJson: PieLabelLineConfig.fromJson,
  description: 'Pie chart with configurable leader lines and external label placement',
  tags: const ['pie', 'labels', 'leader-lines'],
);

// ─── Combined bundle ────────────────────────────────────────────────────────

/// Register ALL bar, line/area, and pie variant charts in one call.
///
/// ```dart
/// variantsBundle.register();
/// ```
final RegistrationBundle variantsBundle = RegistrationBundle(
  name: 'variantsBundle',
  description: 'All bar, line/area, and pie variant charts (39 sub-types)',
  registrations: [
    // Bar
    barBackgroundRegistration,
    barRaceRegistration,
    barGradientRegistration,
    barLabelRotationRegistration,
    barRoundedRegistration,
    barNormalizedRegistration,
    negativeBarRegistration,
    tangentialPolarBarRegistration,
    barBrushRegistration,
    // Line / Area
    areaPiecesRegistration,
    lineGradientRegistration,
    lineConfidenceBandRegistration,
    lineMarklineRegistration,
    logAxisRegistration,
    functionPlotRegistration,
    sparklineMatrixRegistration,
    dynamicTimeSeriesRegistration,
    intradayLineRegistration,
    lineClickAddRegistration,
    // Pie
    donutRegistration,
    halfDonutRegistration,
    paddedPieRegistration,
    nightingaleRegistration,
    nestedPieRegistration,
    partitionPieRegistration,
    calendarPieRegistration,
    pieLabelLineRegistration,
  ],
);
