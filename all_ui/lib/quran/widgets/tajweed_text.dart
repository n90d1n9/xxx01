import 'package:flutter/material.dart';

import 'tajweed_rules_database.dart';

class TajweedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool inline;
  const TajweedText({
    super.key,
    required this.text,
    required this.fontSize,
    this.inline = false,
  });
  @override
  Widget build(BuildContext context) {
    final spans = _buildTajweedSpans(text);
    return RichText(
      textAlign: inline ? TextAlign.start : TextAlign.justify,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: fontSize,
          height: inline ? 1.5 : 2.0,
          letterSpacing: 0.5,
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
        children: spans,
      ),
    );
  }

  List<TextSpan> _buildTajweedSpans(String text) {
    final List<TextSpan> spans = [];
    final rules = TajweedRulesDatabase.getAllRules();
    int i = 0;
    while (i < text.length) {
      bool matched = false;
      for (var rule in rules) {
        for (var pattern in rule.patterns) {
          final regex = RegExp(pattern);
          final match = regex.matchAsPrefix(text, i);
          if (match != null) {
            final matchedText = match.group(0)!;
            spans.add(
              TextSpan(
                text: matchedText,
                style: TextStyle(
                  color: rule.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            i += matchedText.length;
            matched = true;
            break;
          }
        }
        if (matched) break;
      }
      if (!matched) {
        spans.add(TextSpan(text: text[i]));
        i++;
      }
    }
    return spans;
  }
}
