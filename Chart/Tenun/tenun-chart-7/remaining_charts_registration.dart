/// Registration bundle for the 9 remaining chart types that complete
/// the full requested set (rainfall, multiXAxes, lineStyleItem,
/// largeScaleArea, areaTimeAxis, polarLine, customizedPie,
/// pieLabelAlign, pieSpecialLabel).
library remaining_charts_registration;

import '../core/config/chart_type.dart';
import '../core/registry/chart_registry.dart';
import '../core/registry/chart_registration.dart';
import '../charts/remaining_charts.dart';

final ChartRegistration rainfallRegistration = ChartRegistration(
  type: ChartType.rainfall,
  typeString: 'rainfall',
  aliases: const ['rain', 'precipitation', 'combinedBar'],
  fromJson: RainfallChartConfig.fromJson,
  description: 'Bar chart styled as rainfall columns with wavy tops; optional line overlay for secondary axis',
  tags: const ['bar', 'rainfall', 'combo'],
);

final ChartRegistration multiXAxesRegistration = ChartRegistration(
  type: ChartType.multiXAxes,
  typeString: 'multiXAxes',
  aliases: const ['dualXAxis', 'twoXAxes', 'multiAxis'],
  fromJson: MultiXAxesChartConfig.fromJson,
  description: 'Line chart with two independent X-axis category sets (top and bottom)',
  tags: const ['line', 'axis', 'multiple'],
);

final ChartRegistration lineStyleItemRegistration = ChartRegistration(
  type: ChartType.lineStyleItem,
  typeString: 'lineStyleItem',
  aliases: const ['styledLine', 'lineStyles', 'dashedLine'],
  fromJson: LineStyleItemConfig.fromJson,
  description: 'Line chart with per-series dash/dot/solid styles and custom dot shapes',
  tags: const ['line', 'style', 'dash', 'dot'],
);

final ChartRegistration largeScaleAreaRegistration = ChartRegistration(
  type: ChartType.largeScaleArea,
  typeString: 'largeScaleArea',
  aliases: const ['bigData', 'lttbArea', 'highPerformanceArea'],
  fromJson: LargeScaleAreaConfig.fromJson,
  description: 'Performance-optimised area chart using LTTB downsampling for large datasets',
  tags: const ['area', 'performance', 'large-scale', 'lttb'],
);

final ChartRegistration areaTimeAxisRegistration = ChartRegistration(
  type: ChartType.areaTimeAxis,
  typeString: 'areaTimeAxis',
  aliases: const ['timeArea', 'datetimeArea', 'timeSeriesArea'],
  fromJson: AreaTimeAxisConfig.fromJson,
  description: 'Area/line chart with a DateTime-based X axis and auto time label formatting',
  tags: const ['area', 'time', 'datetime', 'timeseries'],
);

final ChartRegistration polarLineRegistration = ChartRegistration(
  type: ChartType.polarLine,
  typeString: 'polarLine',
  aliases: const ['spiderLine', 'radarLine', 'angularLine'],
  fromJson: PolarLineChartConfig.fromJson,
  description: 'Line chart on polar coordinates — closed polygon overlaid on a radial grid',
  tags: const ['polar', 'line', 'radar', 'spider'],
);

final ChartRegistration customizedPieRegistration = ChartRegistration(
  type: ChartType.customizedPie,
  typeString: 'customizedPie',
  aliases: const ['styledPie', 'explodedPie', 'customPie'],
  fromJson: CustomizedPieConfig.fromJson,
  description: 'Pie chart with per-slice custom styles (border, color, explode offset, selected state)',
  tags: const ['pie', 'custom', 'explode', 'style'],
);

final ChartRegistration pieLabelAlignRegistration = ChartRegistration(
  type: ChartType.pieLabelAlign,
  typeString: 'pieLabelAlign',
  aliases: const ['alignedLabels', 'polylinePie'],
  fromJson: PieLabelAlignConfig.fromJson,
  description: 'Pie chart with polyline leader lines to edge-aligned left/right external labels',
  tags: const ['pie', 'labels', 'align', 'polyline'],
);

final ChartRegistration pieSpecialLabelRegistration = ChartRegistration(
  type: ChartType.pieSpecialLabel,
  typeString: 'pieSpecialLabel',
  aliases: const ['richLabelPie', 'emojiPie', 'customLabelPie'],
  fromJson: PieSpecialLabelConfig.fromJson,
  description: 'Donut chart with multi-line rich labels (emoji, percentage, sub-label) per slice',
  tags: const ['pie', 'donut', 'label', 'rich', 'emoji'],
);

/// Register all 9 remaining chart types.
final RegistrationBundle remainingChartsBundle = RegistrationBundle(
  name: 'remainingChartsBundle',
  description: 'Remaining charts: rainfall, multiXAxes, lineStyleItem, '
      'largeScaleArea, areaTimeAxis, polarLine, customizedPie, pieLabelAlign, pieSpecialLabel',
  registrations: [
    rainfallRegistration,
    multiXAxesRegistration,
    lineStyleItemRegistration,
    largeScaleAreaRegistration,
    areaTimeAxisRegistration,
    polarLineRegistration,
    customizedPieRegistration,
    pieLabelAlignRegistration,
    pieSpecialLabelRegistration,
  ],
);
