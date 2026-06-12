import 'package:flutter/material.dart';

import '../models/product_form_save_action.dart';

/// Shared visual tokens for product form save and review actions.
class ProductFormSaveActionVisuals {
  const ProductFormSaveActionVisuals._();

  static Color accentColor(
    ProductFormSaveActionSummary summary,
    ColorScheme colorScheme,
  ) {
    return summary.isReady ? Colors.teal.shade700 : colorScheme.error;
  }

  static IconData summaryIcon(ProductFormSaveActionSummary summary) {
    return summary.isReady
        ? Icons.verified_rounded
        : Icons.pending_actions_rounded;
  }

  static IconData statusIcon(ProductFormSaveActionSummary summary) {
    return summary.isReady
        ? Icons.task_alt_rounded
        : Icons.playlist_add_check_rounded;
  }

  static IconData submitIcon(ProductFormSaveActionSummary summary) {
    return summary.isReady ? Icons.check_rounded : Icons.save_rounded;
  }

  static Color reviewIssueColor(
    ProductFormSaveReviewIssueSeverity severity,
    ColorScheme colorScheme,
  ) {
    return switch (severity) {
      ProductFormSaveReviewIssueSeverity.invalid => colorScheme.error,
      ProductFormSaveReviewIssueSeverity.missingRequired =>
        colorScheme.tertiary,
    };
  }

  static IconData reviewIssueIcon(ProductFormSaveReviewIssueSeverity severity) {
    return switch (severity) {
      ProductFormSaveReviewIssueSeverity.invalid => Icons.error_outline_rounded,
      ProductFormSaveReviewIssueSeverity.missingRequired =>
        Icons.rule_folder_rounded,
    };
  }
}
