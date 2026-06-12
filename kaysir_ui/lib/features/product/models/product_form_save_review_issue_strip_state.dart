import 'product_form_save_action.dart';

/// Presentation state for the product form save review issue strip.
class ProductFormSaveReviewIssueStripViewState {
  ProductFormSaveReviewIssueStripViewState._({
    required List<ProductFormSaveReviewIssue> visibleIssues,
    required this.totalIssueCount,
    required this.maxVisibleIssues,
    required this.isExpanded,
  }) : visibleIssues = List.unmodifiable(visibleIssues);

  factory ProductFormSaveReviewIssueStripViewState.from({
    required ProductFormSaveActionSummary summary,
    required int maxVisibleIssues,
    required bool isExpanded,
  }) {
    final safeMaxVisibleIssues = maxVisibleIssues < 0 ? 0 : maxVisibleIssues;
    final canShowIssues = summary.hasReviewIssues && safeMaxVisibleIssues > 0;
    final shouldExpand =
        canShowIssues &&
        isExpanded &&
        summary.reviewIssues.length > safeMaxVisibleIssues;
    final visibleIssueCount =
        canShowIssues
            ? shouldExpand
                ? summary.reviewIssues.length
                : safeMaxVisibleIssues
            : 0;

    return ProductFormSaveReviewIssueStripViewState._(
      visibleIssues: summary.reviewIssues.take(visibleIssueCount).toList(),
      totalIssueCount: summary.reviewIssues.length,
      maxVisibleIssues: safeMaxVisibleIssues,
      isExpanded: shouldExpand,
    );
  }

  final List<ProductFormSaveReviewIssue> visibleIssues;
  final int totalIssueCount;
  final int maxVisibleIssues;
  final bool isExpanded;

  bool get hasVisibleIssues => visibleIssues.isNotEmpty;
  int get hiddenIssueCount => totalIssueCount - visibleIssues.length;
  bool get canExpand => hiddenIssueCount > 0;
  bool get canCollapse => isExpanded && totalIssueCount > maxVisibleIssues;

  String get expandLabel => '+$hiddenIssueCount more';
  String get expandTooltip => '$hiddenIssueCount more save issues';
  String get collapseLabel => 'Show less';
  String get collapseTooltip => 'Collapse save issues';
}
