import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'tone.dart';

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.colors,
    this.tone,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.backgroundAlpha = 0.24,
    this.borderAlpha = 0.18,
    this.backgroundSource = ToneBackgroundSource.container,
    this.size = POSUiTokens.controlHeight,
    this.iconSize = 18,
    this.valueKey,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final ToneColors? colors;
  final VisualTone? tone;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double backgroundAlpha;
  final double borderAlpha;
  final ToneBackgroundSource backgroundSource;
  final double size;
  final double iconSize;
  final String? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueKey = this.valueKey;
    final toneColors = _toneColors(theme.colorScheme);
    final effectiveForeground =
        foregroundColor ??
        toneColors?.foreground ??
        theme.colorScheme.onSurfaceVariant;
    final effectiveBackground =
        backgroundColor ??
        toneColors?.background ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.42);
    final effectiveBorder =
        borderColor ?? toneColors?.border ?? theme.dividerColor;

    return IconButton(
      key: valueKey == null ? null : ValueKey<String>(valueKey),
      tooltip: tooltip,
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(Size.square(size)),
        minimumSize: WidgetStateProperty.all(Size.square(size)),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
          ),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.colorScheme.onSurface.withValues(alpha: 0.38);
          }

          return effectiveForeground;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.24,
            );
          }

          return effectiveBackground;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final color =
              states.contains(WidgetState.disabled)
                  ? theme.dividerColor.withValues(alpha: 0.7)
                  : effectiveBorder;
          return BorderSide(color: color);
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return effectiveForeground.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return effectiveForeground.withValues(alpha: 0.08);
          }

          return null;
        }),
      ),
      icon: Icon(icon, size: iconSize),
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
