import '../utils/helper.dart';
import 'chart_type.dart';
import 'grid.dart';
import 'title.dart';
import 'legend.dart';
import 'series.dart';
import 'toolbox_feature.dart';
import 'tooltip.dart';
import 'xyaxis.dart';

class ChartConfig {
  final ChartTitle? title;
  final ChartTooltip? tooltip;
  final ChartLegend? legend;
  final ChartToolbox? toolbox;
  final Grid? grid;
  final List<Series> series;
  final ChartType? type;
  final XYAxis? xAxis;
  final XYAxis? yAxis;
  final double? maxValueY;
  final double? maxY;

  ChartConfig({
    ChartType? type,
    this.maxValueY,
    double? maxY,
    this.title,
    this.tooltip,
    this.legend,
    this.toolbox,
    this.grid,
    this.xAxis,
    this.yAxis,
    this.series = const [],
  })  : maxY = (type != getChartType('pie')) && maxY != null
            ? getMaxSeriesValue(series)
            : 100,
        type = type ?? ChartType.bar;

  factory ChartConfig.fromJson(Map<String, dynamic> json) {
    return ChartConfig(
      title: json['title'] != null ? ChartTitle.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null
          ? ChartTooltip.fromJson(json['tooltip'])
          : null,
      type: json['type'] != null
          ? getChartType(json['type'])
          : getChartType("line"),
      legend:
          json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null
          ? ChartToolbox.fromJson(json['toolbox'])
          : null,
      grid: json['grid'] != null ? Grid.fromJson(json['grid']) : null,
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      series: json['series'] != null
          ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
          : [],
    );
  }

  double getMax() {
    return series
        .map((series) => series.data as List<dynamic>)
        .expand((dataList) => dataList)
        .reduce((curr, next) => curr > next ? curr : next);
  }

  @override
  String toString() {
    return 'ChartConfig('
        'title: $title, '
        'tooltip: $tooltip, '
        'legend: $legend, '
        'toolbox: $toolbox, '
        'grid: $grid, '
        'series: $series, '
        'type: $type, '
        'xAxis: $xAxis, '
        'yAxis: $yAxis, '
        'maxValueY: $maxValueY, '
        'maxY: $maxY'
        ')';
  }
}

class ChartToolbox {
  final ToolboxFeature? feature;
  final bool show;

  ChartToolbox({this.feature, this.show = false});

  factory ChartToolbox.fromJson(Map<String, dynamic> json) {
    return ChartToolbox(feature: json['feature'], show: json['show']);
  }

  Map<String, dynamic> toJson() {
    return {
      'feature': feature,
      'show': show,
    };
  }
}
