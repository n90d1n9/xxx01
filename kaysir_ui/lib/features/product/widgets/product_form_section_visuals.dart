import 'package:flutter/material.dart';

import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';

/// Shared visual tokens for product editor section surfaces.
class ProductFormSectionVisuals {
  const ProductFormSectionVisuals._();

  static IconData sectionIcon(ProductFormSectionId sectionId) {
    return switch (sectionId) {
      ProductFormSectionId.identity => Icons.badge_rounded,
      ProductFormSectionId.commercial => Icons.sell_rounded,
      ProductFormSectionId.packExtensions => Icons.extension_rounded,
    };
  }

  static Color sectionColor(
    ProductFormSectionId sectionId,
    ColorScheme colorScheme,
  ) {
    return switch (sectionId) {
      ProductFormSectionId.identity => colorScheme.primary,
      ProductFormSectionId.commercial => Colors.teal.shade700,
      ProductFormSectionId.packExtensions => colorScheme.tertiary,
    };
  }

  static Color progressColor(
    ProductFormSectionProgress progress,
    ColorScheme colorScheme,
  ) {
    return switch (progress.readiness) {
      ProductFormSectionReadiness.ready => Colors.teal.shade700,
      ProductFormSectionReadiness.needsRequired => colorScheme.error,
      ProductFormSectionReadiness.optionalOnly => colorScheme.outline,
    };
  }

  static IconData progressIcon(ProductFormSectionProgress progress) {
    return switch (progress.readiness) {
      ProductFormSectionReadiness.ready => Icons.verified_rounded,
      ProductFormSectionReadiness.needsRequired => Icons.error_outline_rounded,
      ProductFormSectionReadiness.optionalOnly => Icons.tune_rounded,
    };
  }
}
