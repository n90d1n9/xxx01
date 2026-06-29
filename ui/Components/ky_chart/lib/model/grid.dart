import 'package:ky_chart/model/xyaxis.dart';

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
  double horizontalInterval;
  String horizontalColor;
  double horizontalWidth;
  List<int> horizontalDashArray;
  String verticalColor;
  double verticalWidth;
  List<int> verticalDashArray;
  bool showHorizontalLines;
  bool showVerticalLines;
  String color;
  ChartLineStyle lineStyle;

  Grid(
      {this.show,
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
      this.horizontalInterval = 0.5,
      this.horizontalColor = 'rgba(0, 0, 0, 0.1)',
      this.horizontalWidth = 0.5,
      this.horizontalDashArray = const [5, 5],
      this.verticalColor = 'rgba(0, 0, 0, 0.1)',
      this.verticalWidth = 0.5,
      this.verticalDashArray = const [5, 5],
      this.showHorizontalLines = true,
      this.showVerticalLines = true,
      this.color = 'rgba(0, 0, 0, 0.1)',
      ChartLineStyle? lineStyle})
      : lineStyle = ChartLineStyle();

  factory Grid.fromJson(Map<String, dynamic> json) {
    return Grid(
      show: json['show'],
      id: json['id'],
      left: json['left'] is String
          ? double.tryParse(json['left'])
          : json['left']?.toDouble(),
      top: json['top'] is String
          ? double.tryParse(json['top'])
          : json['top']?.toDouble(),
      right: json['right'] is String
          ? double.tryParse(json['right'])
          : json['right']?.toDouble(),
      bottom: json['bottom'] is String
          ? double.tryParse(json['bottom'])
          : json['bottom']?.toDouble(),
      width: json['width'] is String
          ? double.tryParse(json['width'])
          : json['width']?.toDouble(),
      height: json['height'] is String
          ? double.tryParse(json['height'])
          : json['height']?.toDouble(),
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

  @override
  String toString() {
    return 'Grid('
        'show: $show, '
        'id: $id, '
        'left: $left, '
        'top: $top, '
        'right: $right, '
        'bottom: $bottom, '
        'width: $width, '
        'height: $height, '
        'containLabel: $containLabel, '
        'backgroundColor: $backgroundColor, '
        'borderColor: $borderColor, '
        'borderWidth: $borderWidth'
        ')';
  }
}
