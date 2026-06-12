import 'package:flutter/material.dart';

import 'tone.dart';

ToneColors noticeIssueColors(
  ColorScheme scheme,
  VisualTone tone, {
  double backgroundAlpha = 0.08,
  double borderAlpha = 0.2,
}) {
  return toneColors(
    scheme,
    tone,
    backgroundAlpha: backgroundAlpha,
    borderAlpha: borderAlpha,
    backgroundSource: ToneBackgroundSource.foreground,
  );
}
