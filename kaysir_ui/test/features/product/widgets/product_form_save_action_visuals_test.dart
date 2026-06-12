import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/widgets/product_form_save_action_visuals.dart';

void main() {
  test('product form save action visuals map review issue tokens', () {
    const colorScheme = ColorScheme.light();

    expect(
      ProductFormSaveActionVisuals.reviewIssueColor(
        ProductFormSaveReviewIssueSeverity.invalid,
        colorScheme,
      ),
      colorScheme.error,
    );
    expect(
      ProductFormSaveActionVisuals.reviewIssueColor(
        ProductFormSaveReviewIssueSeverity.missingRequired,
        colorScheme,
      ),
      colorScheme.tertiary,
    );
    expect(
      ProductFormSaveActionVisuals.reviewIssueIcon(
        ProductFormSaveReviewIssueSeverity.invalid,
      ),
      Icons.error_outline_rounded,
    );
    expect(
      ProductFormSaveActionVisuals.reviewIssueIcon(
        ProductFormSaveReviewIssueSeverity.missingRequired,
      ),
      Icons.rule_folder_rounded,
    );
  });
}
