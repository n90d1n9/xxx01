import 'chart_type.dart';
import 'series.dart';
import 'xyaxis.dart';

class LineSeries extends Series {
  bool? smooth;
  double? sampling;
  ChartLineStyle? lineStyle;

  LineSeries({
    super.type = ChartType.line,
    super.name,
    super.data,
    super.stack,
    super.xAxisIndex,
    super.yAxisIndex,
    super.label,
    super.tooltip,
    super.itemStyle,
    super.emphasis,
    this.smooth,
    this.sampling,
    this.lineStyle,
  });

  factory LineSeries.fromJson(Map<String, dynamic> json) {
    return LineSeries(
      name: json['name'],
      data: json['data']?.map((e) => e).toList(),
      smooth: json['smooth'],
      sampling: json['sampling']?.toDouble(),
      lineStyle: json['lineStyle'] != null
          ? ChartLineStyle.fromJson(json['lineStyle'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'smooth': smooth,
      'sampling': sampling,
      'lineStyle': lineStyle?.toJson(),
    });
    return map;
  }
}
