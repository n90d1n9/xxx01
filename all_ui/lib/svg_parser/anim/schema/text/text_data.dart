import 'package:flutter/material.dart';

@immutable
class TextData {
  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign align;

  const TextData({
    required this.text,
    this.fontSize = 16,
    this.fontFamily = 'sans-serif',
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.align = TextAlign.left,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'fontSize': fontSize,
    'fontFamily': fontFamily,
    'fontWeight': fontWeight.index,
    'color': color.value,
    'align': align.index,
  };

  factory TextData.fromJson(Map<String, dynamic> json) {
    return TextData(
      text: json['text'] ?? '',
      fontSize: (json['fontSize'] ?? 16).toDouble(),
      fontFamily: json['fontFamily'] ?? 'sans-serif',
      fontWeight: FontWeight.values[json['fontWeight'] ?? 3],
      color: Color(json['color'] ?? 0xFF000000),
      align: TextAlign.values[json['align'] ?? 0],
    );
  }
}
