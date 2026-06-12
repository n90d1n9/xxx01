import 'package:flutter/material.dart';

import 'chip_tone.dart';
import 'icon_label_chip.dart';

class ProfileRegistryMetricChip extends StatelessWidget {
  const ProfileRegistryMetricChip({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = mutedChipColors(Theme.of(context), backgroundAlpha: 0.55);

    return IconLabelChip(icon: icon, label: label, colors: colors);
  }
}
