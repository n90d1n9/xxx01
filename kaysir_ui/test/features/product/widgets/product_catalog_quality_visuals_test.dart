import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_catalog_quality_visuals.dart';

void main() {
  test('catalog quality visuals map score colors', () {
    expect(ProductCatalogQualityVisuals.scoreColor(90), Colors.green.shade700);
    expect(ProductCatalogQualityVisuals.scoreColor(50), Colors.orange.shade700);
    expect(ProductCatalogQualityVisuals.scoreColor(10), Colors.red.shade700);
  });

  test('catalog quality visuals map issue tokens', () {
    expect(
      ProductCatalogQualityVisuals.issueTypeColor(
        ProductCatalogQualityIssueType.missingSku,
      ),
      Colors.blue.shade700,
    );
    expect(
      ProductCatalogQualityVisuals.issueTypeColor(
        ProductCatalogQualityIssueType.missingRequiredPackField,
      ),
      Colors.teal.shade700,
    );
    expect(
      ProductCatalogQualityVisuals.issueIcon(
        ProductCatalogQualityIssueType.missingScanCode,
      ),
      Icons.qr_code_scanner_rounded,
    );
    expect(
      ProductCatalogQualityVisuals.issueIcon(
        ProductCatalogQualityIssueType.missingRequiredPackField,
      ),
      Icons.assignment_late_rounded,
    );
  });

  test('catalog quality visuals map active and clear issue colors', () {
    expect(
      ProductCatalogQualityVisuals.issueColor(_issue(count: 2)),
      Colors.blue.shade700,
    );
    expect(
      ProductCatalogQualityVisuals.issueColor(_issue(count: 0)),
      Colors.green.shade700,
    );
  });

  test('catalog quality visuals map quick fix labels', () {
    expect(
      ProductCatalogQualityVisuals.quickFixLabel(
        _issue(label: 'missing category'),
      ),
      'Fix category',
    );
    expect(
      ProductCatalogQualityVisuals.quickFixLabel(
        _issue(label: 'needs weighing data'),
      ),
      'Fix needs weighing data',
    );
  });
}

ProductCatalogQualityIssue _issue({
  String label = 'missing SKU',
  int count = 1,
}) {
  return ProductCatalogQualityIssue(
    id: 'missingSku',
    type: ProductCatalogQualityIssueType.missingSku,
    label: label,
    count: count,
    reviewTarget: const ProductCatalogReviewTarget(
      query: 'No SKU',
      title: 'Catalog quality',
      reasonLabel: 'missing SKU',
    ),
  );
}
