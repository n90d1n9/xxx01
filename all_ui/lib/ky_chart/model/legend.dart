import 'text_style.dart';

class ChartLegend {
  String? type;
  String? id;
  bool show;
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
  ChartTextStyle? textStyle;
  String backgroundColor;
  String borderColor;
  double? borderWidth;
  double? borderRadius;
  double? shadowBlur;
  String? shadowColor;
  double? shadowOffsetX;
  double? shadowOffsetY;
  int? scrollDataIndex;
  String? pageButtonPosition;
  String pageIconsColor;
  String pageIconsInactiveColor;
  String textColor;
  double fontSize;
  double iconSize;

  ChartLegend({
    this.type,
    this.id,
    this.show = true,
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
    this.backgroundColor = 'transparent',
    this.borderColor = 'black',
    this.borderWidth,
    this.borderRadius,
    this.shadowBlur,
    this.shadowColor,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.scrollDataIndex,
    this.pageButtonPosition,
    this.pageIconsColor = 'black',
    this.pageIconsInactiveColor = 'grey',
    this.textColor = 'black',
    this.fontSize = 12,
    this.iconSize = 10,
    List<String> data = const <String>[],
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
          ? ChartTextStyle.fromJson(json['textStyle'])
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
      data: json['data'] != null ? List<String>.from(json['data']) : <String>[],
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

  @override
  String toString() {
    return 'ChartLegend('
        'type: $type, '
        'id: $id, '
        'show: $show, '
        'zlevel: $zlevel, '
        'z: $z, '
        'left: $left, '
        'top: $top, '
        'right: $right, '
        'bottom: $bottom, '
        'orient: $orient, '
        'align: $align, '
        'padding: $padding, '
        'itemGap: $itemGap, '
        'itemWidth: $itemWidth, '
        'itemHeight: $itemHeight, '
        'formatter: $formatter, '
        'selectedMode: $selectedMode, '
        'selected: $selected, '
        'icon: $icon, '
        'textStyle: $textStyle, '
        'backgroundColor: $backgroundColor, '
        'borderColor: $borderColor, '
        'borderWidth: $borderWidth, '
        'borderRadius: $borderRadius, '
        'shadowBlur: $shadowBlur, '
        'shadowColor: $shadowColor, '
        'shadowOffsetX: $shadowOffsetX, '
        'shadowOffsetY: $shadowOffsetY, '
        'scrollDataIndex: $scrollDataIndex, '
        'pageButtonPosition: $pageButtonPosition, '
        'pageIconsColor: $pageIconsColor, '
        'pageIconsInactiveColor: $pageIconsInactiveColor'
        ')';
  }
}
