import 'text_shadow.dart';

class Typography {
  final String? fontFamily;
  final String? fontSize;
  final String? fontWeight;
  final String? fontStyle;
  final String? lineHeight;
  final String? letterSpacing;
  final String? textAlign;
  final String? textDecoration;
  final String? textTransform;
  final String? color;
  final TextShadow? textShadow;
  final String? wordSpacing;
  final String? whiteSpace;

  Typography({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
    this.letterSpacing,
    this.textAlign,
    this.textDecoration,
    this.textTransform,
    this.color,
    this.textShadow,
    this.wordSpacing,
    this.whiteSpace,
  });

  factory Typography.fromJson(Map<String, dynamic> json) {
    return Typography(
      fontFamily: json['fontFamily'] as String?,
      fontSize: json['fontSize'] as String?,
      fontWeight: json['fontWeight'] as String?,
      fontStyle: json['fontStyle'] as String?,
      lineHeight: json['lineHeight'] as String?,
      letterSpacing: json['letterSpacing'] as String?,
      textAlign: json['textAlign'] as String?,
      textDecoration: json['textDecoration'] as String?,
      textTransform: json['textTransform'] as String?,
      color: json['color'] as String?,
      textShadow:
          json['textShadow'] != null
              ? TextShadow.fromJson(json['textShadow'] as Map<String, dynamic>)
              : null,
      wordSpacing: json['wordSpacing'] as String?,
      whiteSpace: json['whiteSpace'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (fontFamily != null) 'fontFamily': fontFamily,
    if (fontSize != null) 'fontSize': fontSize,
    if (fontWeight != null) 'fontWeight': fontWeight,
    if (fontStyle != null) 'fontStyle': fontStyle,
    if (lineHeight != null) 'lineHeight': lineHeight,
    if (letterSpacing != null) 'letterSpacing': letterSpacing,
    if (textAlign != null) 'textAlign': textAlign,
    if (textDecoration != null) 'textDecoration': textDecoration,
    if (textTransform != null) 'textTransform': textTransform,
    if (color != null) 'color': color,
    if (textShadow != null) 'textShadow': textShadow!.toJson(),
    if (wordSpacing != null) 'wordSpacing': wordSpacing,
    if (whiteSpace != null) 'whiteSpace': whiteSpace,
  };

  Typography copyWith({
    String? fontFamily,
    String? fontSize,
    String? fontWeight,
    String? fontStyle,
    String? lineHeight,
    String? letterSpacing,
    String? textAlign,
    String? textDecoration,
    String? textTransform,
    String? color,
    TextShadow? textShadow,
    String? wordSpacing,
    String? whiteSpace,
  }) {
    return Typography(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      textAlign: textAlign ?? this.textAlign,
      textDecoration: textDecoration ?? this.textDecoration,
      textTransform: textTransform ?? this.textTransform,
      color: color ?? this.color,
      textShadow: textShadow ?? this.textShadow,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      whiteSpace: whiteSpace ?? this.whiteSpace,
    );
  }
}
