enum FontStyle { normal, italic, oblique }

enum FontWeight {
  normal,
  bold,
  bolder,
  lighter,
  w100,
  w200,
  w300,
  w400,
  w500,
  w600,
  w700,
  w800,
  w900
}

enum Align { top, middle, bottom }

class ChartTextStyle {
  final String color;
  final FontStyle? fontStyle;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double? fontSize;
  final Align? align;
  final Align? verticalAlign;
  final double? lineHeight;
  final String? backgroundColor;
  final String? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? padding;

  ChartTextStyle({
    this.color = 'black',
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'sans-serif',
    this.fontSize = 12.0,
    this.align = Align.middle,
    this.verticalAlign = Align.middle,
    this.lineHeight = 1.2,
    this.backgroundColor = 'transparent',
    this.borderColor = 'black',
    this.borderWidth = 0.0,
    this.borderRadius = 0.0,
    this.padding = 0.0,
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

  @override
  String toString() {
    return 'ChartTextStyle('
        'color: $color, '
        'fontStyle: $fontStyle, '
        'fontWeight: $fontWeight, '
        'fontFamily: $fontFamily, '
        'fontSize: $fontSize, '
        'align: $align, '
        'verticalAlign: $verticalAlign, '
        'lineHeight: $lineHeight, '
        'backgroundColor: $backgroundColor, '
        'borderColor: $borderColor, '
        'borderWidth: $borderWidth, '
        'borderRadius: $borderRadius, '
        'padding: $padding'
        ')';
  }
}
