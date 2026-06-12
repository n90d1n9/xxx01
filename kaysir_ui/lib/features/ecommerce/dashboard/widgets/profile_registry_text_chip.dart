import 'package:flutter/material.dart';

import 'chip_tone.dart';
import 'text_badge.dart';
import 'tone.dart';

class ProfileRegistryTextChip extends StatelessWidget {
  const ProfileRegistryTextChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tonalChipColors(
      theme.colorScheme,
      VisualTone.primary,
      backgroundAlpha: 0.24,
    );

    return TextBadge(
      label: label,
      colors: colors,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}
