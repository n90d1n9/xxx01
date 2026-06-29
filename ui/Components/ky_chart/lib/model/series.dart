import 'dart:ui';

import '../utils/helper.dart';
import 'chart_type.dart';
import 'label.dart';
import 'pie_series.dart';
import 'tooltip.dart';

class Series {
  ChartType? type; // Common property to identify series type
  String? name;
  List<dynamic>? data;
  String? stack;
  int? xAxisIndex;
  int? yAxisIndex;
  Label? label;
  ChartTooltip? tooltip;
  ItemStyle? itemStyle;
  Emphasis? emphasis;
  List<String>? dataLabels;
  Color? color;
  double? width;

  Series({
    this.type,
    this.name,
    this.data,
    this.stack,
    this.xAxisIndex,
    this.yAxisIndex,
    this.label,
    this.tooltip,
    this.itemStyle,
    this.emphasis,
    this.dataLabels,
    this.color,
    this.width,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      type: json['type'] != null
          ? getChartType(json['type'])
          : getChartType("line"),
      name: json['name'],
      data: json['data']
          ?.map((e) => e['value'] != null ? getPieSeries(e) : e.toDouble())
          .toList(),
      stack: json['stack'],
      xAxisIndex: json['xAxisIndex'],
      yAxisIndex: json['yAxisIndex'],
      /* label: json['label'] != null
          ? ((json['label'] is String)
              ? json['label']
              : Label.fromJson(json['label']))
          : null, */
      tooltip: json['tooltip'] != null
          ? ChartTooltip.fromJson(json['tooltip'])
          : null,
      itemStyle: json['itemStyle'] != null
          ? ItemStyle.fromJson(json['itemStyle'])
          : ItemStyle(color: getStringRandomColor()),
      emphasis:
          json['emphasis'] != null ? Emphasis.fromJson(json['emphasis']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'data': data,
      'stack': stack,
      'xAxisIndex': xAxisIndex,
      'yAxisIndex': yAxisIndex,
      'label': label?.toJson(),
      'tooltip': tooltip?.toJson(),
      'itemStyle': itemStyle?.toJson(),
      'emphasis': emphasis?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Series('
        'type: $type, '
        'name: $name, '
        'data: $data, '
        'stack: $stack, '
        'xAxisIndex: $xAxisIndex, '
        'yAxisIndex: $yAxisIndex, '
        'label: $label, '
        'tooltip: $tooltip, '
        'itemStyle: $itemStyle, '
        'emphasis: $emphasis'
        ')';
  }
}

PieSeries getPieSeries(dynamic data) => PieSeries.fromJson(data);
