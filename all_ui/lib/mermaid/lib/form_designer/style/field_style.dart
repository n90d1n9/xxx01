import 'package:flutter/widgets.dart';

class FieldStyle {
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? borderWidth;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? iconColor;
  final BoxShadow? shadow;
  final double? elevation;
  final String? customCssClass;

  const FieldStyle({
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.margin,
    this.prefixIcon,
    this.suffixIcon,
    this.iconColor,
    this.shadow,
    this.elevation,
    this.customCssClass,
  });

  FieldStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
    double? borderWidth,
    double? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? iconColor,
    BoxShadow? shadow,
    double? elevation,
    String? customCssClass,
  }) {
    return FieldStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      iconColor: iconColor ?? this.iconColor,
      shadow: shadow ?? this.shadow,
      elevation: elevation ?? this.elevation,
      customCssClass: customCssClass ?? this.customCssClass,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
      if (borderColor != null) 'borderColor': borderColor!.value,
      if (textColor != null) 'textColor': textColor!.value,
      if (borderWidth != null) 'borderWidth': borderWidth,
      if (borderRadius != null) 'borderRadius': borderRadius,
      if (padding != null)
        'padding':
            '${padding!.left},${padding!.top},${padding!.right},${padding!.bottom}',
      if (margin != null)
        'margin':
            '${margin!.left},${margin!.top},${margin!.right},${margin!.bottom}',
      if (prefixIcon != null) 'prefixIcon': prefixIcon!.codePoint,
      if (suffixIcon != null) 'suffixIcon': suffixIcon!.codePoint,
      if (iconColor != null) 'iconColor': iconColor!.value,
      if (elevation != null) 'elevation': elevation,
      if (customCssClass != null) 'customCssClass': customCssClass,
    };
  }
}
