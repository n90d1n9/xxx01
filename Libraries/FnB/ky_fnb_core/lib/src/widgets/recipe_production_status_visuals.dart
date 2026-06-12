import 'package:flutter/material.dart';

import '../models/menu_availability.dart';
import '../models/recipe_production_entry.dart';

/// Presentation state for a recipe production review row.
class FnbRecipeProductionStatusVisuals {
  const FnbRecipeProductionStatusVisuals({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;
}

/// Resolves shared recipe production review state into reusable UI visuals.
FnbRecipeProductionStatusVisuals fnbRecipeProductionStatusVisuals({
  required ColorScheme colors,
  required FnbRecipeProductionEntry entry,
  IconData readyIcon = Icons.menu_book_outlined,
}) {
  final availability = entry.menuItem?.availability;
  final label = entry.isReviewed ? entry.attentionLabel : entry.menuStatusLabel;

  if (entry.isReviewed) {
    return FnbRecipeProductionStatusVisuals(
      color: colors.primary,
      icon: Icons.check_circle_outline,
      label: label,
    );
  }

  if (!entry.hasMenuItem) {
    return FnbRecipeProductionStatusVisuals(
      color: colors.error,
      icon: Icons.link_off_outlined,
      label: label,
    );
  }

  if (availability == FnbMenuAvailability.soldOut) {
    return FnbRecipeProductionStatusVisuals(
      color: colors.error,
      icon: Icons.remove_shopping_cart_outlined,
      label: label,
    );
  }

  if (availability == FnbMenuAvailability.limited) {
    return FnbRecipeProductionStatusVisuals(
      color: colors.tertiary,
      icon: Icons.inventory_2_outlined,
      label: label,
    );
  }

  if (availability == FnbMenuAvailability.hidden) {
    return FnbRecipeProductionStatusVisuals(
      color: colors.tertiary,
      icon: Icons.visibility_off_outlined,
      label: label,
    );
  }

  if (entry.hasAllergens) {
    return FnbRecipeProductionStatusVisuals(
      color: colors.tertiary,
      icon: Icons.health_and_safety_outlined,
      label: label,
    );
  }

  return FnbRecipeProductionStatusVisuals(
    color: colors.primary,
    icon: readyIcon,
    label: label,
  );
}
