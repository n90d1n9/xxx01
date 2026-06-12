import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_form_save_action_panel.dart';

void main() {
  testWidgets('product form save action panel renders missing action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(820, 420));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final summary = _summaryFor(const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });
    var reviewCount = 0;
    ProductFormSaveReviewIssue? selectedIssue;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormSaveActionPanel(
            summary: summary,
            onReviewIssueSelected: (issue) {
              selectedIssue = issue;
            },
            onReviewNext: () => reviewCount++,
            onSubmit: () => submitCount++,
          ),
        ),
      ),
    );

    expect(find.text('Product still needs required data'), findsOneWidget);
    expect(
      find.text('Complete Price in Commercial before saving.'),
      findsOneWidget,
    );
    expect(find.text('4/8 ready'), findsOneWidget);
    expect(find.text('50% ready'), findsOneWidget);
    expect(find.text('4/8 required'), findsOneWidget);
    expect(find.text('Missing Price'), findsOneWidget);
    expect(find.text('Missing Initial Stock'), findsOneWidget);
    expect(find.text('Missing Expiry date'), findsOneWidget);
    expect(find.text('+1 more'), findsOneWidget);
    expect(find.text('Review Price'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add product'), findsOneWidget);

    await tester.tap(find.text('Missing Initial Stock'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Review Price'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));

    expect(selectedIssue?.attribute.fieldId, 'initial_stock');
    expect(reviewCount, 1);
    expect(submitCount, 1);
  });

  testWidgets('product form save action panel renders ready action', (
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
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormSaveActionPanel(
            summary: summary,
            onSubmit: () => submitCount++,
          ),
        ),
      ),
    );

    expect(find.text('Ready to add product'), findsOneWidget);
    expect(find.text('All required product data is complete.'), findsOneWidget);
    expect(find.text('8/8 ready'), findsOneWidget);
    expect(find.text('100% ready'), findsOneWidget);
    expect(find.text('8/8 required'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));

    expect(submitCount, 1);
  });

  testWidgets('product form save action panel renders invalid pack action', (
    tester,
  ) async {
    final summary = _summaryFor(const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': 'soon',
      'batch_number': 'B-01',
    });
    var reviewCount = 0;
    ProductFormSaveReviewIssue? selectedIssue;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductFormSaveActionPanel(
            summary: summary,
            onReviewIssueSelected: (issue) {
              selectedIssue = issue;
            },
            onReviewNext: () => reviewCount++,
            onSubmit: () => submitCount++,
          ),
        ),
      ),
    );

    expect(find.text('Review product data'), findsOneWidget);
    expect(
      find.text('Fix Expiry date in Pack extensions before saving.'),
      findsOneWidget,
    );
    expect(find.text('1 invalid'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('8/8 required'), findsOneWidget);
    expect(find.text('Invalid Expiry date'), findsOneWidget);
    expect(find.text('+1 more'), findsNothing);
    expect(find.text('Review Expiry date'), findsOneWidget);

    await tester.tap(find.text('Invalid Expiry date'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Review Expiry date'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));

    expect(selectedIssue?.attribute.fieldId, 'expiry_date');
    expect(reviewCount, 1);
    expect(submitCount, 1);
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
    groupProgress: _groupProgressFor(values),
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
