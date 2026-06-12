import 'package:flutter/material.dart';

import 'chip_tone.dart';
import 'text_badge.dart';
import 'tone.dart';

class CurrentProfileBadge extends StatelessWidget {
  final String label;

  const CurrentProfileBadge({super.key, this.label = 'Current'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tonalChipColors(
      theme.colorScheme,
      VisualTone.primary,
      backgroundAlpha: 0.1,
      borderAlpha: 0.18,
      backgroundSource: ToneBackgroundSource.foreground,
    );

    return TextBadge(label: label, colors: colors, fontWeight: FontWeight.w900);
  }
}
