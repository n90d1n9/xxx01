import 'package:flutter/material.dart' hide ActionChip;
import 'package:flutter/material.dart' as material;

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';

class EcommerceWorkspaceActionChip extends StatelessWidget {
  const EcommerceWorkspaceActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.colors,
    this.tone,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.tooltip,
    this.backgroundAlpha = 0.24,
    this.borderAlpha = 0.18,
    this.backgroundSource = ToneBackgroundSource.container,
    this.iconSize = 15,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? tooltip;
  final ToneColors? colors;
  final VisualTone? tone;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;
  final double backgroundAlpha;
  final double borderAlpha;
  final ToneBackgroundSource backgroundSource;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toneColors = _toneColors(theme.colorScheme);
    final effectiveForeground =
        foregroundColor ?? toneColors?.foreground ?? theme.colorScheme.primary;
    final effectiveBackground =
        backgroundColor ??
        toneColors?.background ??
        theme.colorScheme.primaryContainer;
    final effectiveBorder =
        borderColor ?? toneColors?.border ?? theme.colorScheme.outlineVariant;

    return material.ActionChip(
      avatar: Icon(icon, size: iconSize, color: effectiveForeground),
      label: Text(label),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: effectiveBorder),
      backgroundColor: effectiveBackground,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: effectiveForeground,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      onPressed: onPressed,
    );
  }

  ToneColors? _toneColors(ColorScheme scheme) {
    final existingColors = colors;
    if (existingColors != null) return existingColors;

    final selectedTone = tone;
    if (selectedTone == null) return null;

    return toneColors(
      scheme,
      selectedTone,
      backgroundAlpha: backgroundAlpha,
      borderAlpha: borderAlpha,
      backgroundSource: backgroundSource,
    );
  }
}
