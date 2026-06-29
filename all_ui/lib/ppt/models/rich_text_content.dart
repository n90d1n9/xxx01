import 'package:flutter/material.dart';

class RichTextContent {
  final String text;
  final TextStyle style;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final TextAlign alignment;

  RichTextContent({
    required this.text,
    required this.style,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.alignment = TextAlign.left,
  });

  RichTextContent copyWith({
    String? text,
    TextStyle? style,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    TextAlign? alignment,
  }) {
    return RichTextContent(
      text: text ?? this.text,
      style: style ?? this.style,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      alignment: alignment ?? this.alignment,
    );
  }
}
