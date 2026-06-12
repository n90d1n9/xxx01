import 'package:flutter/material.dart';

import 'restaurant_section_surface.dart';
import 'restaurant_status_styles.dart';

/// Applies the shared status-aware surface treatment used by operating cards.
class RestaurantStatusCardSurface extends StatelessWidget {
  const RestaurantStatusCardSurface({
    super.key,
    required this.statusStyle,
    required this.child,
    this.surfaceAlpha = .82,
    this.borderAlpha = .2,
    this.isFocused = false,
  });

  final RestaurantStatusStyle statusStyle;
  final Widget child;
  final double surfaceAlpha;
  final double borderAlpha;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RestaurantSectionSurface(
      backgroundColor: colors.surface.withValues(alpha: surfaceAlpha),
      borderColor: isFocused
          ? colors.primary.withValues(alpha: .58)
          : statusStyle.foreground.withValues(alpha: borderAlpha),
      borderWidth: isFocused ? 1.6 : 1,
      child: child,
    );
  }
}
