
import 'package:flutter/material.dart';

enum GChartType { bar, line, pie, area, radar }

class ChartConfig {
  final GTooltip? tooltip;
  final Legend? legend;
  final GChartType? type;
  final List<Series>? series;
  final XAxis? xAxis;
  final YAxis? yAxis;
  final double? maxValueY;
  final double? maxY;

  ChartConfig(
      {this.type,
      this.maxValueY,
      this.maxY,
      this.xAxis,
      this.yAxis,
      this.tooltip,
      this.legend,
      this.series});
}

class YAxis {
  final String? type;
  final List<String>? data;
  YAxis({this.data, this.type});
}

class XAxis {
  final String? type;
  final List<String>? data;
  XAxis({this.data, this.type});
}

class Legend {
  final String? top;
  final String? left;
  final List<dynamic>? data;
  Legend({this.top, this.left, this.data});
}

class GTooltip {
  final String? trigger;
  AxixPointer? axisPointer;
  GTooltip({this.trigger, this.axisPointer});
}

class AxixPointer {
  final String? type;
  final ItemStyle? label;
  AxixPointer({this.label, this.type});
}

class ItemStyle {
  final double? borderRadius;
  final Color? backgroundColor;
  final String? borderColor;
  final double? borderWidth;
  final Color? color;
  const ItemStyle(
      {this.color,
      this.borderRadius,
      this.backgroundColor,
      this.borderColor,
      this.borderWidth});
}

enum ChartType { bar, line, pie, radar }

class Series {
  final String? name;
  final String? type;
  final List<String>? radius;
  final bool? avoidLabelOverlap;
  final ItemStyle itemStyle;
  final Label? label;
  final Label? emphasis;
  final Label? labelLine;
  final List<ChartData>? data;
  Series(
      {this.type,
      this.radius,
      this.avoidLabelOverlap,
      this.itemStyle = const ItemStyle(borderRadius: 40),
      this.label,
      this.emphasis,
      this.labelLine,
      this.data,
      this.name});
}

class Label {
  final bool show;
  final String? position;
  final int? fontSize;
  final String? fontWeight;
  Label({this.position, this.fontSize, this.fontWeight, this.show = true});
}

class ChartData {
  final double? value;
  final String? name;
  final Color? color;
  ChartData({required this.value, this.name, this.color});

  static ChartData fromMap(data) {
    return ChartData(
        value: data['value'], name: data['name'], color: data['color']);
  }

  static List<ChartData> fromMapList(List data) {
    return data
        .map((d) => ChartData(
            value: double.parse('${d['value']}'),
            name: d['name'],
            color: d['color']))
        .toList();
  }
}
