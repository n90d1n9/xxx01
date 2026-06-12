import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import '../models/product_form_save_action.dart';
import '../models/product_form_save_review_issue_strip_state.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_form_save_action_visuals.dart';

/// Compact review queue for save-blocking product form issues.
class ProductFormSaveReviewIssueStrip extends StatefulWidget {
  const ProductFormSaveReviewIssueStrip({
    super.key,
    required this.summary,
    this.maxVisibleIssues = 3,
    this.onIssueSelected,
  });

  final ProductFormSaveActionSummary summary;
  final int maxVisibleIssues;
  final ValueChanged<ProductFormSaveReviewIssue>? onIssueSelected;

  @override
  State<ProductFormSaveReviewIssueStrip> createState() =>
      _ProductFormSaveReviewIssueStripState();
}

class _ProductFormSaveReviewIssueStripState
    extends State<ProductFormSaveReviewIssueStrip> {
  var _showAllIssues = false;

  @override
  void didUpdateWidget(ProductFormSaveReviewIssueStrip oldWidget) {
    super.didUpdateWidget(oldWidget);

    final viewState = ProductFormSaveReviewIssueStripViewState.from(
      summary: widget.summary,
      maxVisibleIssues: widget.maxVisibleIssues,
      isExpanded: _showAllIssues,
    );
    if (!viewState.canCollapse) {
      _showAllIssues = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ProductFormSaveReviewIssueStripViewState.from(
      summary: widget.summary,
      maxVisibleIssues: widget.maxVisibleIssues,
      isExpanded: _showAllIssues,
    );
    if (!viewState.hasVisibleIssues) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final issue in viewState.visibleIssues)
          _ProductFormSaveReviewIssueChip(
            issue: issue,
            color: ProductFormSaveActionVisuals.reviewIssueColor(
              issue.severity,
              colorScheme,
            ),
            icon: ProductFormSaveActionVisuals.reviewIssueIcon(issue.severity),
            onSelected:
                widget.onIssueSelected == null
                    ? null
                    : () => widget.onIssueSelected!(issue),
          ),
        if (viewState.canExpand)
          _ProductFormSaveReviewOverflowChip(
            label: viewState.expandLabel,
            tooltip: viewState.expandTooltip,
            color: colorScheme.secondary,
            icon: Icons.more_horiz_rounded,
            onSelected: () => setState(() => _showAllIssues = true),
          ),
        if (viewState.canCollapse)
          _ProductFormSaveReviewOverflowChip(
            label: viewState.collapseLabel,
            tooltip: viewState.collapseTooltip,
            color: colorScheme.secondary,
            icon: Icons.expand_less_rounded,
            onSelected: () => setState(() => _showAllIssues = false),
          ),
      ],
    );
  }
}

@Preview(name: 'Product form save review issue strip')
Widget productFormSaveReviewIssueStripPreview() {
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
  final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
    groups: buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    ),
    values: values,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductFormSaveReviewIssueStrip(
          summary: buildProductFormSaveActionSummary(
            progress: progress,
            submitLabel: 'Add product',
            isEditing: false,
            groupProgress: groupProgress,
          ),
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

/// One compact save-review issue chip, optionally actionable.
class _ProductFormSaveReviewIssueChip extends StatelessWidget {
  const _ProductFormSaveReviewIssueChip({
    required this.issue,
    required this.color,
    required this.icon,
    this.onSelected,
  });

  final ProductFormSaveReviewIssue issue;
  final Color color;
  final IconData icon;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final pill = AppStatusPill(
      label: issue.label,
      tooltip: issue.tooltip,
      color: color,
      icon: icon,
      maxWidth: 180,
    );
    final onSelected = this.onSelected;
    if (onSelected == null) return pill;

    return Tooltip(
      message: 'Review ${issue.attribute.label}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(999),
          child: pill,
        ),
      ),
    );
  }
}

/// Compact overflow control for expanding or collapsing save-review issues.
class _ProductFormSaveReviewOverflowChip extends StatelessWidget {
  const _ProductFormSaveReviewOverflowChip({
    required this.label,
    required this.tooltip,
    required this.color,
    required this.icon,
    required this.onSelected,
  });

  final String label;
  final String tooltip;
  final Color color;
  final IconData icon;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(999),
          child: AppStatusPill(
            label: label,
            color: color,
            icon: icon,
            maxWidth: 116,
          ),
        ),
      ),
    );
  }
}
