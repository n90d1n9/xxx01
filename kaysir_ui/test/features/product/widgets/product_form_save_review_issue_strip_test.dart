import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_form_save_review_issue_strip.dart';

void main() {
  testWidgets('product form save review issue strip caps visible issues', (
    tester,
  ) async {
    final summary = _summaryFor(const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormSaveReviewIssueStrip(
            summary: summary,
            maxVisibleIssues: 2,
          ),
        ),
      ),
    );

    expect(find.text('Missing Price'), findsOneWidget);
    expect(find.text('Missing Initial Stock'), findsOneWidget);
    expect(find.text('Missing Expiry date'), findsNothing);
    expect(find.text('+2 more'), findsOneWidget);

    await tester.tap(find.text('+2 more'));
    await tester.pumpAndSettle();

    expect(find.text('Missing Expiry date'), findsOneWidget);
    expect(find.text('Missing Batch number'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();

    expect(find.text('Missing Expiry date'), findsNothing);
    expect(find.text('+2 more'), findsOneWidget);
  });

  testWidgets('product form save review issue strip selects visible issues', (
    tester,
  ) async {
    final summary = _summaryFor(const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });
    ProductFormSaveReviewIssue? selectedIssue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormSaveReviewIssueStrip(
            summary: summary,
            onIssueSelected: (issue) {
              selectedIssue = issue;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Missing Price'));
    await tester.pump();

    expect(selectedIssue?.attribute.fieldId, 'price');
    expect(
      selectedIssue?.severity,
      ProductFormSaveReviewIssueSeverity.missingRequired,
    );
  });

  testWidgets('product form save review issue strip selects expanded issues', (
    tester,
  ) async {
    final summary = _summaryFor(const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });
    ProductFormSaveReviewIssue? selectedIssue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormSaveReviewIssueStrip(
            summary: summary,
            maxVisibleIssues: 2,
            onIssueSelected: (issue) {
              selectedIssue = issue;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('+2 more'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Missing Batch number'));
    await tester.pump();

    expect(selectedIssue?.attribute.fieldId, 'batch_number');
  });

  testWidgets('product form save review issue strip hides when ready', (
    tester,
  ) async {
    final summary = _summaryFor(const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': '2026-07-01',
      'batch_number': 'B-01',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductFormSaveReviewIssueStrip(summary: summary)),
      ),
    );

    expect(find.byType(ProductFormSaveReviewIssueStrip), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.text('Missing Price'), findsNothing);
  });
}

ProductFormSaveActionSummary _summaryFor(Map<String, String> values) {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
  final progress = buildProductFormSectionProgressOverview(
    overview: overview,
    values: values,
  );

  return buildProductFormSaveActionSummary(
    progress: progress,
    submitLabel: 'Add product',
    isEditing: false,
    groupProgress: buildProductManagementPackFieldGroupProgressOverview(
      groups: buildProductManagementPackFieldGroups(
        groceryFreshGoodsProductManagementPack,
      ),
      values: values,
    ),
  );
}
