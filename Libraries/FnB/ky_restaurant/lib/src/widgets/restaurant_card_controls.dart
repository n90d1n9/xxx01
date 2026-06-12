import 'package:flutter/material.dart';

import 'restaurant_signal_chip.dart';

/// Lays out card metric widgets with consistent operational spacing.
class RestaurantCardMetricRow extends StatelessWidget {
  const RestaurantCardMetricRow({
    super.key,
    required this.children,
    this.spacing = 18,
    this.runSpacing = 12,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// Lays out compact card chips with consistent spacing and wrapping.
class RestaurantCardChipRow extends StatelessWidget {
  const RestaurantCardChipRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: spacing, runSpacing: runSpacing, children: children);
  }
}

/// Displays a compact metadata chip sized for operational cards.
class RestaurantCardChip extends StatelessWidget {
  const RestaurantCardChip({
    super.key,
    required this.label,
    required this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RestaurantSignalChip(
      label: label,
      icon: icon,
      foregroundColor: foregroundColor,
      backgroundColor:
          backgroundColor ??
          colors.surfaceContainerHighest.withValues(alpha: .5),
      borderColor: borderColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }
}

/// Displays a compact text action that fits inside card chip rows.
class RestaurantCardActionButton extends StatelessWidget {
  const RestaurantCardActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor ?? colors.primary,
        backgroundColor:
            backgroundColor ?? colors.primaryContainer.withValues(alpha: .46),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
        shape: const StadiumBorder(),
      ),
    );
  }
}
