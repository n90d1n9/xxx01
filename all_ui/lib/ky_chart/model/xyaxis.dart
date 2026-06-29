import 'text_style.dart';

enum AxisType { category, value }

class XYAxis {
  String? id;
  AxisType? type;
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
  String nameColor;
  double nameSize;
  double fontSize;
  String color;
  bool? show;
  Function? formatter;
  int? precision;

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
    this.nameColor = 'rgba(0, 0, 0, 0.1)',
    this.nameSize = 12,
    this.fontSize = 10,
    this.color = 'rgba(0, 0, 0, 0.1)',
    this.show,
    this.formatter,
    this.precision,
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
      axisLine:
          json['axisLine'] != null ? AxisLine.fromJson(json['axisLine']) : null,
      axisTick:
          json['axisTick'] != null ? AxisTick.fromJson(json['axisTick']) : null,
      axisLabel: json['axisLabel'] != null
          ? AxisLabel.fromJson(json['axisLabel'])
          : null,
      splitLine: json['splitLine'] != null
          ? SplitLine.fromJson(json['splitLine'])
          : null,
      splitArea: json['splitArea'] != null
          ? SplitArea.fromJson(json['splitArea'])
          : null,
      data: json['data']?.map((e) => e).toList(),
      axisPointer: json['axisPointer'] != null
          ? AxisPointer.fromJson(json['axisPointer'])
          : null,
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

  @override
  String toString() {
    return 'XYAxis('
        'id: $id, '
        'type: $type, '
        'name: $name, '
        'position: $position, '
        'inverse: $inverse, '
        'boundaryGap: $boundaryGap, '
        'min: $min, '
        'max: $max, '
        'scale: $scale, '
        'splitNumber: $splitNumber, '
        'minInterval: $minInterval, '
        'interval: $interval, '
        'maxInterval: $maxInterval, '
        'logBase: $logBase, '
        'silent: $silent, '
        'triggerEvent: $triggerEvent, '
        'axisLine: $axisLine, '
        'axisTick: $axisTick, '
        'axisLabel: $axisLabel, '
        'splitLine: $splitLine, '
        'splitArea: $splitArea, '
        'data: $data, '
        'axisPointer: $axisPointer'
        ')';
  }
}

class AxisLine {
  bool? show;
  ChartLineStyle? lineStyle;

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
  bool show;
  ChartTextStyle? textStyle;
  AxisLabel({this.formatter, this.show = true, this.textStyle});

  factory AxisLabel.fromJson(Map<String, dynamic> json) {
    return AxisLabel(
      formatter: json['formatter'],
      show: json['show'],
      textStyle: json['textStyle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatter': formatter,
      'show': show,
      'textStyle': textStyle,
    };
  }
}

class ChartLineStyle {
  String color;
  double width;

  ChartLineStyle({this.color = 'grey', this.width = 1.0});

  factory ChartLineStyle.fromJson(Map<String, dynamic> json) {
    return ChartLineStyle(
      color: json['color'],
      width: json['width']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'width': width,
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

class AxisPointer {
  String? type;

  AxisPointer({this.type});

  factory AxisPointer.fromJson(Map<String, dynamic> json) {
    return AxisPointer(
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}
