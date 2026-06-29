import 'dart:ui';

import 'text_style.dart';

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
  ChartTextStyle textStyle;
  ChartTextStyle subtextStyle;
  Color? color;
  double? fontSize;

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
    ChartTextStyle? textStyle,
    ChartTextStyle? subtextStyle,
    this.color,
    this.fontSize,
  })  : textStyle = textStyle ?? ChartTextStyle(),
        subtextStyle = subtextStyle ?? ChartTextStyle();

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
      'textStyle': textStyle.toJson(),
      'subtextStyle': subtextStyle.toJson(),
    };
  }

  @override
  String toString() {
    return 'ChartTitle('
        'text: $text, '
        'link: $link, '
        'target: $target, '
        'subtext: $subtext, '
        'sublink: $sublink, '
        'subtarget: $subtarget, '
        'textAlign: $textAlign, '
        'textVerticalAlign: $textVerticalAlign, '
        'textBaseline: $textBaseline, '
        'subtextAlign: $subtextAlign, '
        'subtextVerticalAlign: $subtextVerticalAlign, '
        'subtextBaseline: $subtextBaseline, '
        'backgroundColor: $backgroundColor, '
        'borderColor: $borderColor, '
        'borderWidth: $borderWidth, '
        'borderRadius: $borderRadius, '
        'padding: $padding, '
        'itemGap: $itemGap, '
        'textStyle: $textStyle, '
        'subtextStyle: $subtextStyle'
        ')';
  }
}
