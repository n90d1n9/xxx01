import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_save_review_issue_strip_state.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';

void main() {
  test('save review issue strip state caps collapsed issues', () {
    final state = ProductFormSaveReviewIssueStripViewState.from(
      summary: _summaryFor(const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'description': 'Leafy greens',
      }),
      maxVisibleIssues: 2,
      isExpanded: false,
    );

    expect(state.hasVisibleIssues, isTrue);
    expect(state.visibleIssues.map((issue) => issue.label), [
      'Missing Price',
      'Missing Initial Stock',
    ]);
    expect(state.hiddenIssueCount, 2);
    expect(state.canExpand, isTrue);
    expect(state.canCollapse, isFalse);
    expect(state.expandLabel, '+2 more');
    expect(state.expandTooltip, '2 more save issues');
  });

  test('save review issue strip state expands and collapses issues', () {
    final state = ProductFormSaveReviewIssueStripViewState.from(
      summary: _summaryFor(const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'description': 'Leafy greens',
      }),
      maxVisibleIssues: 2,
      isExpanded: true,
    );

    expect(state.isExpanded, isTrue);
    expect(state.visibleIssues, hasLength(4));
    expect(state.hiddenIssueCount, 0);
    expect(state.canExpand, isFalse);
    expect(state.canCollapse, isTrue);
    expect(state.collapseLabel, 'Show less');
    expect(state.collapseTooltip, 'Collapse save issues');
  });

  test('save review issue strip state hides empty and disabled strips', () {
    final readyState = ProductFormSaveReviewIssueStripViewState.from(
      summary: _summaryFor(const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'price': '12',
        'initial_stock': '8',
        'description': 'Leafy greens',
        'expiry_date': '2026-07-01',
        'batch_number': 'B-01',
      }),
      maxVisibleIssues: 2,
      isExpanded: true,
    );
    final disabledState = ProductFormSaveReviewIssueStripViewState.from(
      summary: _summaryFor(const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'description': 'Leafy greens',
      }),
      maxVisibleIssues: 0,
      isExpanded: true,
    );

    expect(readyState.hasVisibleIssues, isFalse);
    expect(readyState.isExpanded, isFalse);
    expect(disabledState.hasVisibleIssues, isFalse);
    expect(disabledState.maxVisibleIssues, 0);
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
