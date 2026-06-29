import 'chart_type.dart';
import 'series.dart';

class BarSeries extends Series {
  double? barWidth;
  double? barMaxWidth;

  BarSeries({
    super.type = ChartType.bar,
    super.name,
    super.data,
    super.stack,
    super.xAxisIndex,
    super.yAxisIndex,
    super.label,
    super.tooltip,
    super.itemStyle,
    super.emphasis,
    this.barWidth,
    this.barMaxWidth,
  });

  factory BarSeries.fromJson(Map<String, dynamic> json) {
    return BarSeries(
      name: json['name'],
      data: json['data']?.map((e) => e).toList(),
      barWidth: json['barWidth']?.toDouble(),
      barMaxWidth: json['barMaxWidth']?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'barWidth': barWidth,
      'barMaxWidth': barMaxWidth,
    });
    return map;
  }
}
