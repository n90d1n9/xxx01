import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

abstract final class SimpleChartsShowcaseStatisticalData {
  static const capabilityParallelAxes = [
    SimpleParallelAxis(label: 'Speed', min: 0, max: 100),
    SimpleParallelAxis(label: 'Quality', min: 0, max: 100),
    SimpleParallelAxis(label: 'Cost', min: 0, max: 100, inverted: true),
    SimpleParallelAxis(label: 'Risk', min: 0, max: 100, inverted: true),
    SimpleParallelAxis(label: 'Reach', min: 0, max: 100),
  ];

  static const capabilityParallel = [
    SimpleParallelSeries(
      label: 'Current',
      values: [82, 76, 64, 58, 72],
      group: 'Baseline',
    ),
    SimpleParallelSeries(
      label: 'Target',
      values: [88, 84, 70, 45, 80],
      group: 'Plan',
    ),
    SimpleParallelSeries(
      label: 'Lean',
      values: [72, 70, 42, 36, 62],
      group: 'Option',
    ),
    SimpleParallelSeries(
      label: 'Scale',
      values: [90, 78, 76, 62, 88],
      group: 'Option',
    ),
  ];

  static const capabilityCorrelationVariables = [
    'Speed',
    'Quality',
    'Cost',
    'Risk',
    'Reach',
  ];

  static const capabilityCorrelations = [
    SimpleCorrelationCell(xLabel: 'Speed', yLabel: 'Quality', value: 0.62),
    SimpleCorrelationCell(xLabel: 'Speed', yLabel: 'Cost', value: -0.48),
    SimpleCorrelationCell(xLabel: 'Speed', yLabel: 'Risk', value: -0.36),
    SimpleCorrelationCell(xLabel: 'Speed', yLabel: 'Reach', value: 0.54),
    SimpleCorrelationCell(xLabel: 'Quality', yLabel: 'Cost', value: -0.22),
    SimpleCorrelationCell(xLabel: 'Quality', yLabel: 'Risk', value: -0.58),
    SimpleCorrelationCell(xLabel: 'Quality', yLabel: 'Reach', value: 0.46),
    SimpleCorrelationCell(xLabel: 'Cost', yLabel: 'Risk', value: 0.44),
    SimpleCorrelationCell(xLabel: 'Cost', yLabel: 'Reach', value: -0.31),
    SimpleCorrelationCell(xLabel: 'Risk', yLabel: 'Reach', value: -0.52),
  ];

  static const capabilityScatterMatrix = [
    SimpleScatterPlotMatrixPoint(
      label: 'Current',
      values: [82, 76, 64, 58],
      group: 'Baseline',
    ),
    SimpleScatterPlotMatrixPoint(
      label: 'Target',
      values: [88, 84, 70, 45],
      group: 'Plan',
    ),
    SimpleScatterPlotMatrixPoint(
      label: 'Lean',
      values: [72, 70, 42, 36],
      group: 'Option',
    ),
    SimpleScatterPlotMatrixPoint(
      label: 'Scale',
      values: [90, 78, 76, 62],
      group: 'Option',
    ),
    SimpleScatterPlotMatrixPoint(
      label: 'Focused',
      values: [68, 88, 48, 30],
      group: 'Option',
    ),
  ];

  static const activityDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  static const activitySegments = ['Morning', 'Midday', 'Evening'];

  static const activityHeatmap = [
    SimpleHeatmapCell(xLabel: 'Mon', yLabel: 'Morning', value: 32),
    SimpleHeatmapCell(xLabel: 'Tue', yLabel: 'Morning', value: 46),
    SimpleHeatmapCell(xLabel: 'Wed', yLabel: 'Morning', value: 39),
    SimpleHeatmapCell(xLabel: 'Thu', yLabel: 'Morning', value: 52),
    SimpleHeatmapCell(xLabel: 'Fri', yLabel: 'Morning', value: 58),
    SimpleHeatmapCell(xLabel: 'Mon', yLabel: 'Midday', value: 41),
    SimpleHeatmapCell(xLabel: 'Tue', yLabel: 'Midday', value: 63),
    SimpleHeatmapCell(xLabel: 'Wed', yLabel: 'Midday', value: 71),
    SimpleHeatmapCell(xLabel: 'Thu', yLabel: 'Midday', value: 66),
    SimpleHeatmapCell(xLabel: 'Fri', yLabel: 'Midday', value: 76),
    SimpleHeatmapCell(xLabel: 'Mon', yLabel: 'Evening', value: 28),
    SimpleHeatmapCell(xLabel: 'Tue', yLabel: 'Evening', value: 36),
    SimpleHeatmapCell(xLabel: 'Wed', yLabel: 'Evening', value: 44),
    SimpleHeatmapCell(xLabel: 'Thu', yLabel: 'Evening', value: 38),
    SimpleHeatmapCell(xLabel: 'Fri', yLabel: 'Evening', value: 49),
  ];

  static const activityPunchCards = [
    SimplePunchCardCell(xLabel: 'Mon', yLabel: 'Morning', value: 32),
    SimplePunchCardCell(xLabel: 'Tue', yLabel: 'Morning', value: 46),
    SimplePunchCardCell(xLabel: 'Wed', yLabel: 'Morning', value: 39),
    SimplePunchCardCell(xLabel: 'Thu', yLabel: 'Morning', value: 52),
    SimplePunchCardCell(xLabel: 'Fri', yLabel: 'Morning', value: 58),
    SimplePunchCardCell(xLabel: 'Mon', yLabel: 'Midday', value: 41),
    SimplePunchCardCell(xLabel: 'Tue', yLabel: 'Midday', value: 63),
    SimplePunchCardCell(xLabel: 'Wed', yLabel: 'Midday', value: 71),
    SimplePunchCardCell(xLabel: 'Thu', yLabel: 'Midday', value: 66),
    SimplePunchCardCell(xLabel: 'Fri', yLabel: 'Midday', value: 76),
    SimplePunchCardCell(xLabel: 'Mon', yLabel: 'Evening', value: 28),
    SimplePunchCardCell(xLabel: 'Tue', yLabel: 'Evening', value: 36),
    SimplePunchCardCell(xLabel: 'Wed', yLabel: 'Evening', value: 44),
    SimplePunchCardCell(xLabel: 'Thu', yLabel: 'Evening', value: 38),
    SimplePunchCardCell(xLabel: 'Fri', yLabel: 'Evening', value: 49),
  ];

  static const activityRadialHeatmap = [
    SimpleRadialHeatmapCell(
      ringLabel: 'Morning',
      segmentLabel: 'Mon',
      value: 32,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Morning',
      segmentLabel: 'Tue',
      value: 46,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Morning',
      segmentLabel: 'Wed',
      value: 39,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Morning',
      segmentLabel: 'Thu',
      value: 52,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Morning',
      segmentLabel: 'Fri',
      value: 58,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Midday',
      segmentLabel: 'Mon',
      value: 41,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Midday',
      segmentLabel: 'Tue',
      value: 63,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Midday',
      segmentLabel: 'Wed',
      value: 71,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Midday',
      segmentLabel: 'Thu',
      value: 66,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Midday',
      segmentLabel: 'Fri',
      value: 76,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Evening',
      segmentLabel: 'Mon',
      value: 28,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Evening',
      segmentLabel: 'Tue',
      value: 36,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Evening',
      segmentLabel: 'Wed',
      value: 44,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Evening',
      segmentLabel: 'Thu',
      value: 38,
    ),
    SimpleRadialHeatmapCell(
      ringLabel: 'Evening',
      segmentLabel: 'Fri',
      value: 49,
    ),
  ];

  static const regionalTileMap = [
    SimpleTileMapData(label: 'North', code: 'N', value: 72, row: 0, column: 0),
    SimpleTileMapData(
      label: 'Central',
      code: 'C',
      value: 88,
      row: 0,
      column: 1,
    ),
    SimpleTileMapData(label: 'East', code: 'E', value: 64, row: 0, column: 2),
    SimpleTileMapData(label: 'West', code: 'W', value: 51, row: 1, column: 0),
    SimpleTileMapData(label: 'South', code: 'S', value: 79, row: 1, column: 1),
    SimpleTileMapData(label: 'Coast', code: 'CO', value: 58, row: 1, column: 2),
    SimpleTileMapData(
      label: 'Islands',
      code: 'I',
      value: 44,
      row: 2,
      column: 2,
    ),
  ];

  static const usageDensityPoints = [
    SimpleHexbinPoint(label: 'Onboard A', x: 18, y: 78, group: 'Core'),
    SimpleHexbinPoint(label: 'Onboard B', x: 21, y: 82, group: 'Core'),
    SimpleHexbinPoint(label: 'Onboard C', x: 24, y: 76, group: 'Core'),
    SimpleHexbinPoint(label: 'Explore A', x: 36, y: 62, group: 'Growth'),
    SimpleHexbinPoint(label: 'Explore B', x: 39, y: 66, group: 'Growth'),
    SimpleHexbinPoint(label: 'Explore C', x: 42, y: 61, group: 'Growth'),
    SimpleHexbinPoint(label: 'Explore D', x: 45, y: 68, group: 'Growth'),
    SimpleHexbinPoint(label: 'Adopt A', x: 58, y: 72, group: 'Product'),
    SimpleHexbinPoint(label: 'Adopt B', x: 61, y: 75, group: 'Product'),
    SimpleHexbinPoint(label: 'Adopt C', x: 64, y: 69, group: 'Product'),
    SimpleHexbinPoint(label: 'Renew A', x: 76, y: 54, group: 'Success'),
    SimpleHexbinPoint(label: 'Renew B', x: 79, y: 58, group: 'Success'),
    SimpleHexbinPoint(label: 'Renew C', x: 82, y: 51, group: 'Success'),
    SimpleHexbinPoint(label: 'Risk A', x: 32, y: 34, group: 'Risk'),
    SimpleHexbinPoint(label: 'Risk B', x: 35, y: 31, group: 'Risk'),
    SimpleHexbinPoint(label: 'Risk C', x: 38, y: 38, group: 'Risk'),
    SimpleHexbinPoint(label: 'Support A', x: 68, y: 42, group: 'Support'),
    SimpleHexbinPoint(label: 'Support B', x: 71, y: 46, group: 'Support'),
    SimpleHexbinPoint(label: 'Support C', x: 74, y: 39, group: 'Support'),
  ];

  static const usageHeatmapPoints = [
    SimpleContinuousHeatmapPoint(
      label: 'Onboard A',
      x: 18,
      y: 78,
      group: 'Core',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Onboard B',
      x: 21,
      y: 82,
      group: 'Core',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Onboard C',
      x: 24,
      y: 76,
      group: 'Core',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Explore A',
      x: 36,
      y: 62,
      group: 'Growth',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Explore B',
      x: 39,
      y: 66,
      group: 'Growth',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Explore C',
      x: 42,
      y: 61,
      group: 'Growth',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Explore D',
      x: 45,
      y: 68,
      group: 'Growth',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Adopt A',
      x: 58,
      y: 72,
      group: 'Product',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Adopt B',
      x: 61,
      y: 75,
      group: 'Product',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Adopt C',
      x: 64,
      y: 69,
      group: 'Product',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Renew A',
      x: 76,
      y: 54,
      group: 'Success',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Renew B',
      x: 79,
      y: 58,
      group: 'Success',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Renew C',
      x: 82,
      y: 51,
      group: 'Success',
    ),
    SimpleContinuousHeatmapPoint(label: 'Risk A', x: 32, y: 34, group: 'Risk'),
    SimpleContinuousHeatmapPoint(label: 'Risk B', x: 35, y: 31, group: 'Risk'),
    SimpleContinuousHeatmapPoint(label: 'Risk C', x: 38, y: 38, group: 'Risk'),
    SimpleContinuousHeatmapPoint(
      label: 'Support A',
      x: 68,
      y: 42,
      group: 'Support',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Support B',
      x: 71,
      y: 46,
      group: 'Support',
    ),
    SimpleContinuousHeatmapPoint(
      label: 'Support C',
      x: 74,
      y: 39,
      group: 'Support',
    ),
  ];

  static const serviceTerritories = [
    SimpleVoronoiSite(
      label: 'North Hub',
      x: 18,
      y: 78,
      value: 72,
      group: 'Care',
    ),
    SimpleVoronoiSite(
      label: 'Academy',
      x: 35,
      y: 62,
      value: 64,
      group: 'Learning',
    ),
    SimpleVoronoiSite(
      label: 'Platform',
      x: 58,
      y: 74,
      value: 88,
      group: 'Product',
    ),
    SimpleVoronoiSite(
      label: 'Field Ops',
      x: 76,
      y: 48,
      value: 55,
      group: 'Care',
    ),
    SimpleVoronoiSite(
      label: 'Growth Lab',
      x: 42,
      y: 34,
      value: 47,
      group: 'Growth',
    ),
    SimpleVoronoiSite(
      label: 'Success',
      x: 82,
      y: 22,
      value: 39,
      group: 'Growth',
    ),
  ];

  static const performanceSurface = [
    SimpleContourPoint(label: 'Quick Win', x: 18, y: 82, value: 78),
    SimpleContourPoint(label: 'Growth', x: 35, y: 72, value: 66),
    SimpleContourPoint(label: 'Platform', x: 58, y: 76, value: 88),
    SimpleContourPoint(label: 'Field Ops', x: 76, y: 54, value: 61),
    SimpleContourPoint(label: 'Cleanup', x: 30, y: 34, value: 38),
    SimpleContourPoint(label: 'Learning', x: 48, y: 46, value: 55),
    SimpleContourPoint(label: 'Scale', x: 70, y: 32, value: 72),
    SimpleContourPoint(label: 'Risk', x: 84, y: 20, value: 44),
  ];

  static final learningCalendar = [
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 5), value: 18),
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 6), value: 24),
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 8), value: 32),
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 12), value: 44),
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 16), value: 28),
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 20), value: 36),
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 23), value: 52),
    SimpleCalendarHeatmapData(date: DateTime(2026, 1, 27), value: 40),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 2), value: 34),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 4), value: 48),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 9), value: 56),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 13), value: 38),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 17), value: 62),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 19), value: 46),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 24), value: 58),
    SimpleCalendarHeatmapData(date: DateTime(2026, 2, 27), value: 42),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 3), value: 50),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 5), value: 66),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 9), value: 54),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 12), value: 72),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 16), value: 64),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 20), value: 78),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 24), value: 60),
    SimpleCalendarHeatmapData(date: DateTime(2026, 3, 27), value: 70),
  ];

  static const scoreDistribution = [
    58.0,
    61.0,
    62.0,
    65.0,
    68.0,
    70.0,
    72.0,
    72.0,
    75.0,
    78.0,
    80.0,
    82.0,
    84.0,
    86.0,
    88.0,
    90.0,
    92.0,
    95.0,
    96.0,
    98.0,
    99.0,
  ];

  static const scoreQQPlot = [
    SimpleQQPlotSeries(
      name: 'Program A',
      referenceName: 'Control',
      referenceValues: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
      sampleValues: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleQQPlotSeries(
      name: 'Program C',
      referenceName: 'Control',
      referenceValues: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
      sampleValues: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const concentrationLorenz = [
    SimpleLorenzSeries(
      name: 'Revenue',
      values: [4, 5, 6, 8, 10, 12, 18, 26, 34, 54],
    ),
    SimpleLorenzSeries(
      name: 'Workload',
      values: [7, 8, 9, 10, 11, 13, 15, 18, 22, 28],
    ),
  ];

  static const measurementAgreement = [
    SimpleBlandAltmanPoint(
      label: 'Sample 1',
      measurementA: 68,
      measurementB: 70,
      group: 'Site A',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 2',
      measurementA: 74,
      measurementB: 73,
      group: 'Site A',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 3',
      measurementA: 80,
      measurementB: 82,
      group: 'Site A',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 4',
      measurementA: 62,
      measurementB: 64,
      group: 'Site A',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 5',
      measurementA: 90,
      measurementB: 93,
      group: 'Site B',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 6',
      measurementA: 78,
      measurementB: 77,
      group: 'Site B',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 7',
      measurementA: 84,
      measurementB: 87,
      group: 'Site B',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 8',
      measurementA: 71,
      measurementB: 74,
      group: 'Site B',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 9',
      measurementA: 88,
      measurementB: 90,
      group: 'Site A',
    ),
    SimpleBlandAltmanPoint(
      label: 'Sample 10',
      measurementA: 65,
      measurementB: 66,
      group: 'Site B',
    ),
  ];

  static const scoreDensity = [
    SimpleDensitySeries(
      name: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleDensitySeries(
      name: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleDensitySeries(
      name: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
  ];

  static const scoreRaincloud = [
    SimpleRaincloudChartData(
      label: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleRaincloudChartData(
      label: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleRaincloudChartData(
      label: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleRaincloudChartData(
      label: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const responseEcdf = [
    SimpleEcdfSeries(
      name: 'Current',
      values: [34, 42, 58, 61, 68, 74, 82, 88, 96, 104, 112, 118],
    ),
    SimpleEcdfSeries(
      name: 'Improved',
      values: [22, 28, 36, 44, 52, 58, 64, 72, 80, 88, 94, 102],
    ),
  ];

  static const scoreSpread = [
    SimpleBoxPlotData(
      label: 'Control',
      min: 42,
      q1: 54,
      median: 64,
      q3: 74,
      max: 88,
      mean: 65,
      outliers: [34, 96],
    ),
    SimpleBoxPlotData(
      label: 'Program A',
      min: 48,
      q1: 62,
      median: 70,
      q3: 82,
      max: 94,
      mean: 71,
      outliers: [98],
    ),
    SimpleBoxPlotData(
      label: 'Program B',
      min: 38,
      q1: 50,
      median: 58,
      q3: 68,
      max: 86,
      mean: 60,
    ),
    SimpleBoxPlotData(
      label: 'Program C',
      min: 52,
      q1: 66,
      median: 78,
      q3: 86,
      max: 96,
      mean: 77,
    ),
  ];

  static const scoreBoxen = [
    SimpleBoxenPlotData(
      label: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleBoxenPlotData(
      label: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleBoxenPlotData(
      label: 'Program B',
      values: [38, 44, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleBoxenPlotData(
      label: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const scoreShape = [
    SimpleViolinChartData(
      label: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleViolinChartData(
      label: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleViolinChartData(
      label: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleViolinChartData(
      label: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const cohortRidges = [
    SimpleRidgelineChartData(
      label: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleRidgelineChartData(
      label: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleRidgelineChartData(
      label: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleRidgelineChartData(
      label: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const scoreRugs = [
    SimpleRugPlotSeries(
      name: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleRugPlotSeries(
      name: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleRugPlotSeries(
      name: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleRugPlotSeries(
      name: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const responseBarcode = [
    SimpleBarcodePlotSeries(
      name: 'Web',
      values: [6, 12, 18, 24, 28, 35, 42, 50, 64, 82],
    ),
    SimpleBarcodePlotSeries(
      name: 'Mobile',
      values: [8, 14, 20, 25, 31, 37, 45, 56, 70, 96],
    ),
    SimpleBarcodePlotSeries(
      name: 'API',
      values: [4, 8, 12, 18, 22, 26, 34, 44, 52, 68],
    ),
    SimpleBarcodePlotSeries(
      name: 'Support',
      values: [18, 28, 36, 42, 55, 62, 78, 90, 104, 118],
    ),
  ];

  static const sampleStrips = [
    SimpleStripPlotData(
      label: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleStripPlotData(
      label: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleStripPlotData(
      label: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleStripPlotData(
      label: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const sampleBeeswarm = [
    SimpleBeeswarmData(
      label: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleBeeswarmData(
      label: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleBeeswarmData(
      label: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleBeeswarmData(
      label: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];

  static const sampleSina = [
    SimpleSinaPlotData(
      label: 'Control',
      values: [34, 42, 54, 58, 64, 68, 72, 74, 88, 96],
    ),
    SimpleSinaPlotData(
      label: 'Program A',
      values: [48, 58, 62, 66, 70, 76, 82, 86, 94, 98],
    ),
    SimpleSinaPlotData(
      label: 'Program B',
      values: [38, 46, 50, 54, 58, 60, 66, 68, 78, 86],
    ),
    SimpleSinaPlotData(
      label: 'Program C',
      values: [52, 60, 66, 72, 78, 82, 86, 90, 94, 98],
    ),
  ];
}
