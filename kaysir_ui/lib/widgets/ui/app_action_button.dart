import 'package:flutter/material.dart';

enum AppActionButtonVariant { primary, secondary, destructive, text }

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppActionButtonVariant.primary,
    this.height = 40,
    this.minWidth = 0,
    this.borderRadius = 8,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppActionButtonVariant variant;
  final double height;
  final double minWidth;
  final double borderRadius;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(context);

    switch (variant) {
      case AppActionButtonVariant.primary:
      case AppActionButtonVariant.destructive:
        return icon == null
            ? FilledButton(
              style: style,
              onPressed: onPressed,
              child: Text(label),
            )
            : FilledButton.icon(
              style: style,
              icon: Icon(icon),
              label: Text(label),
              onPressed: onPressed,
            );
      case AppActionButtonVariant.secondary:
        return icon == null
            ? OutlinedButton(
              style: style,
              onPressed: onPressed,
              child: Text(label),
            )
            : OutlinedButton.icon(
              style: style,
              icon: Icon(icon),
              label: Text(label),
              onPressed: onPressed,
            );
      case AppActionButtonVariant.text:
        return icon == null
            ? TextButton(style: style, onPressed: onPressed, child: Text(label))
            : TextButton.icon(
              style: style,
              icon: Icon(icon),
              label: Text(label),
              onPressed: onPressed,
            );
    }
  }

  ButtonStyle _styleFor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
    final padding = EdgeInsets.symmetric(horizontal: compact ? 10 : 14);
    final minimumSize = Size(minWidth, height);
    final textStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800);

    switch (variant) {
      case AppActionButtonVariant.primary:
        return FilledButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: shape,
          textStyle: textStyle,
        );
      case AppActionButtonVariant.destructive:
        return FilledButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          shape: shape,
          textStyle: textStyle,
        );
      case AppActionButtonVariant.secondary:
        return OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: shape,
          textStyle: textStyle,
        );
      case AppActionButtonVariant.text:
        return TextButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: colorScheme.onSurfaceVariant,
          shape: shape,
          textStyle: textStyle,
        );
    }
  }
}
