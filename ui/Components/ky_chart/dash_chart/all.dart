import 'dart:math';
import 'dart:ui';

import 'grid.dart';
import 'title.dart';
import 'legend.dart';
import 'series.dart';
import 'tooltip.dart';
import 'xyaxis.dart';

enum ChartType { bar, line, pie, area, radar }

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
    this.type,
    this.maxValueY,
    this.maxY,
    this.title,
    this.tooltip,
    this.legend,
    this.toolbox,
    this.grid,
    this.xAxis,
    this.yAxis,
    this.series = const [],
  });

  factory ChartConfig.fromJson(Map<String, dynamic> json) {
    return ChartConfig(
      title: json['title'] != null ? ChartTitle.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null
          ? ChartTooltip.fromJson(json['tooltip'])
          : null,
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
}

class ChartToolbox {
  final Map<String, dynamic>? feature;

  ChartToolbox({this.feature});

  factory ChartToolbox.fromJson(Map<String, dynamic> json) {
    return ChartToolbox(feature: json['feature']);
  }
}

class BarSeries extends Series {
  double? barWidth;
  double? barMaxWidth;

  BarSeries({
    super.type = "bar",
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

class Grid {
  bool? show;
  String? id;
  double? left;
  double? top;
  double? right;
  double? bottom;
  double? width;
  double? height;
  bool? containLabel;
  String? backgroundColor;
  String? borderColor;
  double? borderWidth;

  Grid({
    this.show,
    this.id,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.containLabel,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
  });

  factory Grid.fromJson(Map<String, dynamic> json) {
    return Grid(
      show: json['show'],
      id: json['id'],
      left: json['left'] is String ? double.tryParse(json['left']) : json['left']?.toDouble(),
      top: json['top'] is String ? double.tryParse(json['top']) : json['top']?.toDouble(),
      right: json['right'] is String ? double.tryParse(json['right']) : json['right']?.toDouble(),
      bottom: json['bottom'] is String ? double.tryParse(json['bottom']) : json['bottom']?.toDouble(),
      width: json['width'] is String ? double.tryParse(json['width']) : json['width']?.toDouble(),
      height: json['height'] is String ? double.tryParse(json['height']) : json['height']?.toDouble(),
      containLabel: json['containLabel'],
      backgroundColor: json['backgroundColor'],
      borderColor: json['borderColor'],
      borderWidth: json['borderWidth']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'id': id,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
      'width': width,
      'height': height,
      'containLabel': containLabel,
      'backgroundColor': backgroundColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
    };
  }
}


class Label {
  bool? show;
  String? position;
  ChartTextStyle? textStyle;

  Label({this.show, this.position, this.textStyle});

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      show: json['show'],
      position: json['position'],
      textStyle: json['textStyle'] != null ? ChartTextStyle.fromJson(json['textStyle']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'position': position,
      'textStyle': textStyle?.toJson(),
    };
  }
}

class Tooltip {
  String? trigger;
  String? formatter;

  Tooltip({this.trigger, this.formatter});

  factory Tooltip.fromJson(Map<String, dynamic> json) {
    return Tooltip(
      trigger: json['trigger'],
      formatter: json['formatter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'formatter': formatter,
    };
  }
}

class ItemStyle {
  Color? color;
  String? borderColor;

  ItemStyle({this.color, this.borderColor});

  factory ItemStyle.fromJson(Map<String, dynamic> json) {
    return ItemStyle(
      color: json['color'],
      borderColor: json['borderColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'borderColor': borderColor,
    };
  }
}



class ChartTextStyle {
  String? color;
  String? fontStyle;
  String? fontWeight;
  String? fontFamily;
  double? fontSize;
  String? align;
  String? verticalAlign;
  String? lineHeight;
  String? backgroundColor;
  String? borderColor;
  double? borderWidth;
  double? borderRadius;
  double? padding;

  ChartTextStyle({
    this.color,
    this.fontStyle,
    this.fontWeight,
    this.fontFamily,
    this.fontSize,
    this.align,
    this.verticalAlign,
    this.lineHeight,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
  });

  factory ChartTextStyle.fromJson(Map<String, dynamic> json) {
    return ChartTextStyle(
      color: json['color'],
      fontStyle: json['fontStyle'],
      fontWeight: json['fontWeight'],
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize']?.toDouble(),
      align: json['align'],
      verticalAlign: json['verticalAlign'],
      lineHeight: json['lineHeight'],
      backgroundColor: json['backgroundColor'],
      borderColor: json['borderColor'],
      borderWidth: json['borderWidth']?.toDouble(),
      borderRadius: json['borderRadius']?.toDouble(),
      padding: json['padding']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'fontStyle': fontStyle,
      'fontWeight': fontWeight,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'align': align,
      'verticalAlign': verticalAlign,
      'lineHeight': lineHeight,
      'backgroundColor': backgroundColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'padding': padding,
    };
  }
}


class Emphasis {
  Label? label;
  ItemStyle? itemStyle;

  Emphasis({this.label, this.itemStyle});

  factory Emphasis.fromJson(Map<String, dynamic> json) {
    return Emphasis(
      label: json['label'] != null ? Label.fromJson(json['label']) : null,
      itemStyle: json['itemStyle'] != null ? ItemStyle.fromJson(json['itemStyle']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label?.toJson(),
      'itemStyle': itemStyle?.toJson(),
    };
  }
}


class ChartLegend {
  String? type;
  String? id;
  bool? show;
  int? zlevel;
  int? z;
  String? left;
  String? top;
  String? right;
  String? bottom;
  String? orient;
  String? align;
  List<dynamic>? padding; // Can be a single value or array
  double? itemGap;
  double? itemWidth;
  double? itemHeight;
  dynamic formatter; // Can be a string or a function
  dynamic selectedMode; // Can be a string or boolean
  Map<String, bool>? selected;
  String? icon;
  EChartsTextStyle? textStyle;
  String? backgroundColor;
  String? borderColor;
  double? borderWidth;
  double? borderRadius;
  double? shadowBlur;
  String? shadowColor;
  double? shadowOffsetX;
  double? shadowOffsetY;
  int? scrollDataIndex;
  String? pageButtonPosition;
  String? pageIconsColor;
  String? pageIconsInactiveColor;

  ChartLegend({
    this.type,
    this.id,
    this.show,
    this.zlevel,
    this.z,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.orient,
    this.align,
    this.padding,
    this.itemGap,
    this.itemWidth,
    this.itemHeight,
    this.formatter,
    this.selectedMode,
    this.selected,
    this.icon,
    this.textStyle,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadowBlur,
    this.shadowColor,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.scrollDataIndex,
    this.pageButtonPosition,
    this.pageIconsColor,
    this.pageIconsInactiveColor,
  });

  factory ChartLegend.fromJson(Map<String, dynamic> json) {
    return ChartLegend(
      type: json['type'],
      id: json['id'],
      show: json['show'],
      zlevel: json['zlevel']?.toInt(),
      z: json['z']?.toInt(),
      left: json['left'],
      top: json['top'],
      right: json['right'],
      bottom: json['bottom'],
      orient: json['orient'],
      align: json['align'],
      padding: (json['padding'] is List)
          ? (json['padding'] as List).map((e) => e.toDouble()).toList()
          : null,
      itemGap: json['itemGap']?.toDouble(),
      itemWidth: json['itemWidth']?.toDouble(),
      itemHeight: json['itemHeight']?.toDouble(),
      formatter: json['formatter'], // Assumes dynamic; handle as needed
      selectedMode: json['selectedMode'], // Assumes dynamic; handle as needed
      selected: json['selected'] != null
          ? Map<String, bool>.from(json['selected'])
          : null,
      icon: json['icon'],
      textStyle: json['textStyle'] != null
          ? EChartsTextStyle.fromJson(json['textStyle'])
          : null,
      backgroundColor: json['backgroundColor'],
      borderColor: json['borderColor'],
      borderWidth: json['borderWidth']?.toDouble(),
      borderRadius: json['borderRadius']?.toDouble(),
      shadowBlur: json['shadowBlur']?.toDouble(),
      shadowColor: json['shadowColor'],
      shadowOffsetX: json['shadowOffsetX']?.toDouble(),
      shadowOffsetY: json['shadowOffsetY']?.toDouble(),
      scrollDataIndex: json['scrollDataIndex']?.toInt(),
      pageButtonPosition: json['pageButtonPosition'],
      pageIconsColor: json['pageIconsColor'],
      pageIconsInactiveColor: json['pageIconsInactiveColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'show': show,
      'zlevel': zlevel,
      'z': z,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
      'orient': orient,
      'align': align,
      'padding': padding,
      'itemGap': itemGap,
      'itemWidth': itemWidth,
      'itemHeight': itemHeight,
      'formatter': formatter,
      'selectedMode': selectedMode,
      'selected': selected,
      'icon': icon,
      'textStyle': textStyle?.toJson(),
      'backgroundColor': backgroundColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'shadowBlur': shadowBlur,
      'shadowColor': shadowColor,
      'shadowOffsetX': shadowOffsetX,
      'shadowOffsetY': shadowOffsetY,
      'scrollDataIndex': scrollDataIndex,
      'pageButtonPosition': pageButtonPosition,
      'pageIconsColor': pageIconsColor,
      'pageIconsInactiveColor': pageIconsInactiveColor,
    };
  }
}

class EChartsTextStyle {
  String? color;
  String? fontStyle;
  String? fontWeight;
  String? fontFamily;
  double? fontSize;

  EChartsTextStyle({
    this.color,
    this.fontStyle,
    this.fontWeight,
    this.fontFamily,
    this.fontSize,
  });

  factory EChartsTextStyle.fromJson(Map<String, dynamic> json) {
    return EChartsTextStyle(
      color: json['color'],
      fontStyle: json['fontStyle'],
      fontWeight: json['fontWeight'],
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'fontStyle': fontStyle,
      'fontWeight': fontWeight,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
    };
  }
}

class LineSeries extends Series {
  bool? smooth;
  double? sampling;
  LineStyle? lineStyle;

  LineSeries({
    super.type = "line",
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
      lineStyle: json['lineStyle'] != null ? LineStyle.fromJson(json['lineStyle']) : null,
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

class Series {
  String? type; // Common property to identify series type
  String? name;
  List<dynamic>? data;
  String? stack;
  int? xAxisIndex;
  int? yAxisIndex;
  Label? label;
  Tooltip? tooltip;
  ItemStyle? itemStyle;
  Emphasis? emphasis;

  Series({
    this.type,
    this.name,
    this.data,
    this.stack,
    this.xAxisIndex,
    this.yAxisIndex,
    this.label,
    this.tooltip,
    this.itemStyle ,
    this.emphasis,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      type: json['type'],
      name: json['name'],
      data: json['data']?.map((e) => e).toList(),
      stack: json['stack'],
      xAxisIndex: json['xAxisIndex'],
      yAxisIndex: json['yAxisIndex'],
      label: json['label'] != null
          ? ((json['label'] is String)
              ? json['label']
              : Label.fromJson(json['label']))
          : null,
      tooltip:
          json['tooltip'] != null ? Tooltip.fromJson(json['tooltip']) : null,
      itemStyle: json['itemStyle'] != null
          ? ItemStyle.fromJson(json['itemStyle'])
          : ItemStyle(color: getRandomColor()),
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
}

class ChartTitle {
  String? text;
  String? link;
  String? target;
  String? subtext;
  String? sublink;
  String? subtarget;
  String? textAlign;
  String? textVerticalAlign;
  String? textBaseline;
  String? subtextAlign;
  String? subtextVerticalAlign;
  String? subtextBaseline;
  String? backgroundColor;
  String? borderColor;
  double? borderWidth;
  double? borderRadius;
  double? padding;
  double? itemGap;
  ChartTextStyle? textStyle;
  ChartTextStyle? subtextStyle;

  ChartTitle({
    this.text,
    this.link,
    this.target,
    this.subtext,
    this.sublink,
    this.subtarget,
    this.textAlign,
    this.textVerticalAlign,
    this.textBaseline,
    this.subtextAlign,
    this.subtextVerticalAlign,
    this.subtextBaseline,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.itemGap,
    this.textStyle,
    this.subtextStyle,
  });

  factory ChartTitle.fromJson(Map<String, dynamic> json) {
    return ChartTitle(
      text: json['text'],
      link: json['link'],
      target: json['target'],
      subtext: json['subtext'],
      sublink: json['sublink'],
      subtarget: json['subtarget'],
      textAlign: json['textAlign'],
      textVerticalAlign: json['textVerticalAlign'],
      textBaseline: json['textBaseline'],
      subtextAlign: json['subtextAlign'],
      subtextVerticalAlign: json['subtextVerticalAlign'],
      subtextBaseline: json['subtextBaseline'],
      backgroundColor: json['backgroundColor'],
      borderColor: json['borderColor'],
      borderWidth: json['borderWidth']?.toDouble(),
      borderRadius: json['borderRadius']?.toDouble(),
      padding: json['padding']?.toDouble(),
      itemGap: json['itemGap']?.toDouble(),
      textStyle: json['textStyle'] != null
          ? ChartTextStyle.fromJson(json['textStyle'])
          : null,
      subtextStyle: json['subtextStyle'] != null
          ? ChartTextStyle.fromJson(json['subtextStyle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'link': link,
      'target': target,
      'subtext': subtext,
      'sublink': sublink,
      'subtarget': subtarget,
      'textAlign': textAlign,
      'textVerticalAlign': textVerticalAlign,
      'textBaseline': textBaseline,
      'subtextAlign': subtextAlign,
      'subtextVerticalAlign': subtextVerticalAlign,
      'subtextBaseline': subtextBaseline,
      'backgroundColor': backgroundColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'padding': padding,
      'itemGap': itemGap,
      'textStyle': textStyle?.toJson(),
      'subtextStyle': subtextStyle?.toJson(),
    };
  }
}

class ChartTooltip {
  bool? show;
  String? trigger; // 'item', 'axis', or 'none'
  AxisPointer? axisPointer;
  String? formatter; // Can be a string or function
  double? showDelay;
  double? hideDelay;
  double? transitionDuration;
  bool? enterable;
  bool? confine;
  bool? renderMode; // 'html' or 'richText'
  String? backgroundColor;
  String? borderColor;
  double? borderWidth;
  double? borderRadius;
  double? padding;
  String? textStyle;
  String? extraCssText;

  ChartTooltip({
    this.show,
    this.trigger,
    this.axisPointer,
    this.formatter,
    this.showDelay,
    this.hideDelay,
    this.transitionDuration,
    this.enterable,
    this.confine,
    this.renderMode,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.extraCssText,
  });

  factory ChartTooltip.fromJson(Map<String, dynamic> json) {
    return ChartTooltip(
      show: json['show'],
      trigger: json['trigger'],
      axisPointer: json['axisPointer'] != null
          ? AxisPointer.fromJson(json['axisPointer'])
          : null,
      formatter: json['formatter'],
      showDelay: json['showDelay']?.toDouble(),
      hideDelay: json['hideDelay']?.toDouble(),
      transitionDuration: json['transitionDuration']?.toDouble(),
      enterable: json['enterable'],
      confine: json['confine'],
      renderMode: json['renderMode'],
      backgroundColor: json['backgroundColor'],
      borderColor: json['borderColor'],
      borderWidth: json['borderWidth']?.toDouble(),
      borderRadius: json['borderRadius']?.toDouble(),
      padding: json['padding']?.toDouble(),
      textStyle: json['textStyle'],
      extraCssText: json['extraCssText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'trigger': trigger,
      'axisPointer': axisPointer?.toJson(),
      'formatter': formatter,
      'showDelay': showDelay,
      'hideDelay': hideDelay,
      'transitionDuration': transitionDuration,
      'enterable': enterable,
      'confine': confine,
      'renderMode': renderMode,
      'backgroundColor': backgroundColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'padding': padding,
      'textStyle': textStyle,
      'extraCssText': extraCssText,
    };
  }
}

class AxisPointer {
  String? type; // 'line', 'shadow', 'cross', or 'none'
  LineStyle? lineStyle;
  ShadowStyle? shadowStyle;

  AxisPointer({
    this.type,
    this.lineStyle,
    this.shadowStyle,
  });

  factory AxisPointer.fromJson(Map<String, dynamic> json) {
    return AxisPointer(
      type: json['type'],
      lineStyle: json['lineStyle'] != null
          ? LineStyle.fromJson(json['lineStyle'])
          : null,
      shadowStyle: json['shadowStyle'] != null
          ? ShadowStyle.fromJson(json['shadowStyle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lineStyle': lineStyle?.toJson(),
      'shadowStyle': shadowStyle?.toJson(),
    };
  }
}

class LineStyle {
  String? color;
  double? width;
  String? type; // 'solid', 'dashed', or 'dotted'

  LineStyle({this.color, this.width, this.type});

  factory LineStyle.fromJson(Map<String, dynamic> json) {
    return LineStyle(
      color: json['color'],
      width: json['width']?.toDouble(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'width': width,
      'type': type,
    };
  }
}

class ShadowStyle {
  String? color;
  double? shadowBlur;
  double? shadowOffsetX;
  double? shadowOffsetY;

  ShadowStyle({
    this.color,
    this.shadowBlur,
    this.shadowOffsetX,
    this.shadowOffsetY,
  });

  factory ShadowStyle.fromJson(Map<String, dynamic> json) {
    return ShadowStyle(
      color: json['color'],
      shadowBlur: json['shadowBlur']?.toDouble(),
      shadowOffsetX: json['shadowOffsetX']?.toDouble(),
      shadowOffsetY: json['shadowOffsetY']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'shadowBlur': shadowBlur,
      'shadowOffsetX': shadowOffsetX,
      'shadowOffsetY': shadowOffsetY,
    };
  }
}

class XYAxis {
  String? id;
  String? type;
  String? name;
  String? position;
  bool? inverse;
  dynamic boundaryGap; // Can be a boolean or a list
  dynamic min; // Can be a number, "dataMin", or null
  dynamic max; // Can be a number, "dataMax", or null
  bool? scale;
  int? splitNumber;
  int? minInterval;
  int? interval;
  int? maxInterval;
  double? logBase;
  bool? silent;
  bool? triggerEvent;
  AxisLine? axisLine;
  AxisTick? axisTick;
  AxisLabel? axisLabel;
  SplitLine? splitLine;
  SplitArea? splitArea;
  List<dynamic>? data; // Can contain mixed types (string, number, etc.)
  AxisPointer? axisPointer;

  XYAxis({
    this.id,
    this.type,
    this.name,
    this.position,
    this.inverse,
    this.boundaryGap,
    this.min,
    this.max,
    this.scale,
    this.splitNumber,
    this.minInterval,
    this.interval,
    this.maxInterval,
    this.logBase,
    this.silent,
    this.triggerEvent,
    this.axisLine,
    this.axisTick,
    this.axisLabel,
    this.splitLine,
    this.splitArea,
    this.data,
    this.axisPointer,
  });

  factory XYAxis.fromJson(Map<String, dynamic> json) {
    return XYAxis(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      position: json['position'],
      inverse: json['inverse'],
      boundaryGap: json['boundaryGap'],
      min: json['min'],
      max: json['max'],
      scale: json['scale'],
      splitNumber: json['splitNumber'],
      minInterval: json['minInterval'],
      interval: json['interval'],
      maxInterval: json['maxInterval'],
      logBase: json['logBase']?.toDouble(),
      silent: json['silent'],
      triggerEvent: json['triggerEvent'],
      axisLine: json['axisLine'] != null ? AxisLine.fromJson(json['axisLine']) : null,
      axisTick: json['axisTick'] != null ? AxisTick.fromJson(json['axisTick']) : null,
      axisLabel: json['axisLabel'] != null ? AxisLabel.fromJson(json['axisLabel']) : null,
      splitLine: json['splitLine'] != null ? SplitLine.fromJson(json['splitLine']) : null,
      splitArea: json['splitArea'] != null ? SplitArea.fromJson(json['splitArea']) : null,
      data: json['data']?.map((e) => e).toList(),
      axisPointer: json['axisPointer'] != null ? AxisPointer.fromJson(json['axisPointer']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'position': position,
      'inverse': inverse,
      'boundaryGap': boundaryGap,
      'min': min,
      'max': max,
      'scale': scale,
      'splitNumber': splitNumber,
      'minInterval': minInterval,
      'interval': interval,
      'maxInterval': maxInterval,
      'logBase': logBase,
      'silent': silent,
      'triggerEvent': triggerEvent,
      'axisLine': axisLine?.toJson(),
      'axisTick': axisTick?.toJson(),
      'axisLabel': axisLabel?.toJson(),
      'splitLine': splitLine?.toJson(),
      'splitArea': splitArea?.toJson(),
      'data': data,
      'axisPointer': axisPointer?.toJson(),
    };
  }
}

class AxisLine {
  bool? show;
  String? lineStyle;

  AxisLine({this.show, this.lineStyle});

  factory AxisLine.fromJson(Map<String, dynamic> json) {
    return AxisLine(
      show: json['show'],
      lineStyle: json['lineStyle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'lineStyle': lineStyle,
    };
  }
}

class AxisTick {
  bool? alignWithLabel;

  AxisTick({this.alignWithLabel});

  factory AxisTick.fromJson(Map<String, dynamic> json) {
    return AxisTick(
      alignWithLabel: json['alignWithLabel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alignWithLabel': alignWithLabel,
    };
  }
}

class AxisLabel {
  String? formatter;

  AxisLabel({this.formatter});

  factory AxisLabel.fromJson(Map<String, dynamic> json) {
    return AxisLabel(
      formatter: json['formatter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatter': formatter,
    };
  }
}

class SplitLine {
  bool? show;

  SplitLine({this.show});

  factory SplitLine.fromJson(Map<String, dynamic> json) {
    return SplitLine(
      show: json['show'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show': show,
    };
  }
}

class SplitArea {
  bool? show;

  SplitArea({this.show});

  factory SplitArea.fromJson(Map<String, dynamic> json) {
    return SplitArea(
      show: json['show'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show': show,
    };
  }
}



Color getRandomColor() {
  final random = Random();
  final r = random.nextInt(256);
  final g = random.nextInt(256);
  final b = random.nextInt(256);

  return Color.fromARGB(255, r, g, b);
}