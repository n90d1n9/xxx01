import 'package:flutter/material.dart';

TextTheme createTextTheme(
    BuildContext context, String bodyFontString, String displayFontString) {
  //TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme =
      TextTheme(displaySmall: TextStyle(fontFamily: bodyFontString));
  TextTheme displayTextTheme =
      TextTheme(displaySmall: TextStyle(fontFamily: displayFontString));
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}
