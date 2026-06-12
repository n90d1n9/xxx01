import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';

void main() {
  test('product form save action summary reports missing required action', () {
    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );
    final progress = buildProductFormSectionProgressOverview(
      overview: overview,
      values: const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'description': 'Leafy greens',
      },
    );
    final summary = buildProductFormSaveActionSummary(
      progress: progress,
      submitLabel: 'Add product',
      isEditing: false,
    );

    expect(summary.title, 'Product still needs required data');
    expect(summary.description, 'Complete Price in Commercial before saving.');
    expect(summary.statusLabel, '4/8 ready');
    expect(summary.submitLabel, 'Add product');
    expect(summary.isReady, isFalse);
    expect(summary.filledRequiredAttributeCount, 4);
    expect(summary.requiredAttributeCount, 8);
    expect(summary.readinessFraction, 0.5);
    expect(summary.readinessPercentLabel, '50% ready');
    expect(summary.requiredReadinessCountLabel, '4/8 required');
    expect(summary.canReviewNext, isTrue);
    expect(summary.reviewNextLabel, 'Review Price');
    expect(summary.nextMissingAttribute?.fieldId, 'price');
    expect(summary.reviewIssues, hasLength(4));
    expect(
      summary.reviewIssues.first.severity,
      ProductFormSaveReviewIssueSeverity.missingRequired,
    );
    expect(summary.reviewIssues.first.label, 'Missing Price');
    expect(summary.reviewIssues.first.tooltip, 'Missing Price in Commercial');
  });

  test('product form save action summary reports ready add action', () {
    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );
    final progress = buildProductFormSectionProgressOverview(
      overview: overview,
      values: const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'price': '12',
        'initial_stock': '8',
        'description': 'Leafy greens',
        'expiry_date': '2026-07-01',
        'batch_number': 'B-01',
      },
    );
    final summary = buildProductFormSaveActionSummary(
      progress: progress,
      submitLabel: 'Add product',
      isEditing: false,
    );

    expect(summary.title, 'Ready to add product');
    expect(summary.description, 'All required product data is complete.');
    expect(summary.statusLabel, '8/8 ready');
    expect(summary.isReady, isTrue);
    expect(summary.filledRequiredAttributeCount, 8);
    expect(summary.requiredAttributeCount, 8);
    expect(summary.readinessFraction, 1);
    expect(summary.readinessPercentLabel, '100% ready');
    expect(summary.requiredReadinessCountLabel, '8/8 required');
    expect(summary.canReviewNext, isFalse);
    expect(summary.reviewIssues, isEmpty);
  });

  test('product form save action summary blocks invalid pack values', () {
    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );
    const values = {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': 'soon',
      'batch_number': 'B-01',
    };
    final progress = buildProductFormSectionProgressOverview(
      overview: overview,
      values: values,
    );
    final summary = buildProductFormSaveActionSummary(
      progress: progress,
      submitLabel: 'Add product',
      isEditing: false,
      groupProgress: _groupProgressFor(values),
    );

    expect(summary.title, 'Review product data');
    expect(
      summary.description,
      'Fix Expiry date in Pack extensions before saving.',
    );
    expect(summary.statusLabel, '1 invalid');
    expect(summary.isReady, isFalse);
    expect(summary.invalidAttributeCount, 1);
    expect(summary.filledRequiredAttributeCount, 8);
    expect(summary.requiredAttributeCount, 8);
    expect(summary.readinessFraction, 1);
    expect(summary.readinessPercentLabel, 'Needs review');
    expect(summary.requiredReadinessCountLabel, '8/8 required');
    expect(summary.canReviewNext, isTrue);
    expect(summary.reviewNextLabel, 'Review Expiry date');
    expect(summary.nextMissingAttribute, isNull);
    expect(summary.nextInvalidAttribute?.fieldId, 'expiry_date');
    expect(summary.nextReviewAttribute?.fieldId, 'expiry_date');
    expect(summary.reviewIssues, hasLength(1));
    expect(
      summary.reviewIssues.single.severity,
      ProductFormSaveReviewIssueSeverity.invalid,
    );
    expect(summary.reviewIssues.single.label, 'Invalid Expiry date');
    expect(
      summary.reviewIssues.single.tooltip,
      'Invalid Expiry date in Pack extensions',
    );
  });

  test(
    'product form save action summary prioritizes invalid review issues',
    () {
      final overview = buildProductFormSectionOverview(
        pack: groceryFreshGoodsProductManagementPack,
        isEditing: false,
      );
      const values = {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'price': '12',
        'initial_stock': '8',
        'description': 'Leafy greens',
        'expiry_date': 'soon',
      };
      final progress = buildProductFormSectionProgressOverview(
        overview: overview,
        values: values,
      );
      final summary = buildProductFormSaveActionSummary(
        progress: progress,
        submitLabel: 'Add product',
        isEditing: false,
        groupProgress: _groupProgressFor(values),
      );

      expect(summary.statusLabel, '1 invalid');
      expect(summary.reviewIssues, hasLength(2));
      expect(summary.reviewIssues[0].label, 'Invalid Expiry date');
      expect(summary.reviewIssues[1].label, 'Missing Batch number');
      expect(summary.nextReviewAttribute?.fieldId, 'expiry_date');
      expect(summary.nextMissingAttribute?.fieldId, 'batch_number');
    },
  );
}

ProductManagementPackFieldGroupProgressOverview _groupProgressFor(
  Map<String, String> values,
) {
  return buildProductManagementPackFieldGroupProgressOverview(
    groups: buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    ),
    values: values,
  );
}
