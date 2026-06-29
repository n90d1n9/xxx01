import 'text_style.dart';

enum TooltipTrigger { item, axis, none }

enum TooltipRenderMode { html, richText }

class ChartTooltip {
  bool show;
  TooltipTrigger? trigger; // 'item', 'axis', or 'none'
  AxisPointer? axisPointer;
  String? formatter; // Can be a string or function
  double? showDelay;
  double? hideDelay;
  double? transitionDuration;
  bool? enterable;
  bool? confine;
  TooltipRenderMode? renderMode; // 'html' or 'richText'
  String? backgroundColor;
  String? borderColor;
  double? borderWidth;
  double? borderRadius;
  double? padding;
  ChartTextStyle? textStyle;
  String? extraCssText;
  bool numberFormat;
  String textColor;
  int? precision;
  double? fontSize;

  ChartTooltip({
    this.show = true,
    this.trigger = TooltipTrigger.item,
    this.axisPointer,
    this.formatter,
    this.showDelay,
    this.hideDelay,
    this.transitionDuration,
    this.enterable,
    this.confine,
    this.renderMode = TooltipRenderMode.html,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.extraCssText,
    this.numberFormat = false,
    this.textColor = 'black',
    this.precision,
    this.fontSize,
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

  get valueFormatter => null;

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

  @override
  String toString() {
    return 'ChartTooltip('
        'show: $show, '
        'trigger: $trigger, '
        'axisPointer: $axisPointer, '
        'formatter: $formatter, '
        'showDelay: $showDelay, '
        'hideDelay: $hideDelay, '
        'transitionDuration: $transitionDuration, '
        'enterable: $enterable, '
        'confine: $confine, '
        'renderMode: $renderMode, '
        'backgroundColor: $backgroundColor, '
        'borderColor: $borderColor, '
        'borderWidth: $borderWidth, '
        'borderRadius: $borderRadius, '
        'padding: $padding, '
        'textStyle: $textStyle, '
        'extraCssText: $extraCssText'
        ')';
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
