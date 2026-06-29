import 'package:flutter/material.dart';

class ComponentStyle {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final double? opacity;
  final double? blur;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  const ComponentStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.shadows,
    this.gradient,
    this.opacity,
    this.blur,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
  });

  ComponentStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    List<BoxShadow>? shadows,
    Gradient? gradient,
    double? opacity,
    double? blur,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
  }) {
    return ComponentStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      shadows: shadows ?? this.shadows,
      gradient: gradient ?? this.gradient,
      opacity: opacity ?? this.opacity,
      blur: blur ?? this.blur,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}
