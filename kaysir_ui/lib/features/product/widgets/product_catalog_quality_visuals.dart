import 'package:flutter/material.dart';

import '../models/product_catalog_quality.dart';

/// Shared visual tokens for catalog quality review surfaces.
class ProductCatalogQualityVisuals {
  const ProductCatalogQualityVisuals._();

  static Color scoreColor(int percent) {
    if (percent >= 80) return Colors.green.shade700;
    if (percent >= 50) return Colors.orange.shade700;

    return Colors.red.shade700;
  }

  static Color issueColor(ProductCatalogQualityIssue issue) {
    if (!issue.isActive) return Colors.green.shade700;

    return issueTypeColor(issue.type);
  }

  static Color issueTypeColor(ProductCatalogQualityIssueType type) {
    return switch (type) {
      ProductCatalogQualityIssueType.missingSku => Colors.blue.shade700,
      ProductCatalogQualityIssueType.missingCategory =>
        Colors.deepPurple.shade600,
      ProductCatalogQualityIssueType.missingDescription =>
        Colors.indigo.shade700,
      ProductCatalogQualityIssueType.missingPrice => Colors.red.shade700,
      ProductCatalogQualityIssueType.missingScanCode => Colors.orange.shade700,
      ProductCatalogQualityIssueType.missingRequiredPackField =>
        Colors.teal.shade700,
    };
  }

  static IconData issueIcon(ProductCatalogQualityIssueType type) {
    return switch (type) {
      ProductCatalogQualityIssueType.missingSku => Icons.tag_rounded,
      ProductCatalogQualityIssueType.missingCategory => Icons.category_rounded,
      ProductCatalogQualityIssueType.missingDescription => Icons.notes_rounded,
      ProductCatalogQualityIssueType.missingPrice => Icons.sell_rounded,
      ProductCatalogQualityIssueType.missingScanCode =>
        Icons.qr_code_scanner_rounded,
      ProductCatalogQualityIssueType.missingRequiredPackField =>
        Icons.assignment_late_rounded,
    };
  }

  static String quickFixLabel(ProductCatalogQualityIssue issue) {
    final label = issue.label;
    if (label.startsWith('missing ')) {
      return 'Fix ${label.substring('missing '.length)}';
    }

    return 'Fix $label';
  }
}
