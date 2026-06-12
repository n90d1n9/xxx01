import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_surface.dart';
import '../models/management_pack.dart';
import '../models/product_form_save_action.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_form_save_action_visuals.dart';
import 'product_form_save_readiness_meter.dart';
import 'product_form_save_review_issue_strip.dart';

/// Responsive save action panel for product editor readiness and submission.
class ProductFormSaveActionPanel extends StatelessWidget {
  const ProductFormSaveActionPanel({
    super.key,
    required this.summary,
    required this.onSubmit,
    this.onReviewNext,
    this.onReviewIssueSelected,
  });

  final ProductFormSaveActionSummary summary;
  final VoidCallback onSubmit;
  final VoidCallback? onReviewNext;
  final ValueChanged<ProductFormSaveReviewIssue>? onReviewIssueSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = ProductFormSaveActionVisuals.accentColor(
      summary,
      colorScheme,
    );

    return AppSurface(
      elevated: true,
      backgroundColor: Color.alphaBlend(
        accentColor.withValues(alpha: 0.05),
        colorScheme.surface,
      ),
      borderColor: accentColor.withValues(alpha: 0.22),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final summaryBlock = _SaveSummaryBlock(
            summary: summary,
            accentColor: accentColor,
            onReviewIssueSelected: onReviewIssueSelected,
          );
          final actions = _SaveActions(
            summary: summary,
            accentColor: accentColor,
            onReviewNext:
                summary.canReviewNext && onReviewNext != null
                    ? onReviewNext
                    : null,
            onSubmit: onSubmit,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [summaryBlock, const SizedBox(height: 12), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: summaryBlock),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: actions,
              ),
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Product form save action panel')
Widget productFormSaveActionPanelPreview() {
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

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductFormSaveActionPanel(
          summary: buildProductFormSaveActionSummary(
            progress: progress,
            submitLabel: 'Add product',
            isEditing: false,
          ),
          onReviewNext: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

/// Text and status content for the product form save action panel.
class _SaveSummaryBlock extends StatelessWidget {
  const _SaveSummaryBlock({
    required this.summary,
    required this.accentColor,
    this.onReviewIssueSelected,
  });

  final ProductFormSaveActionSummary summary;
  final Color accentColor;
  final ValueChanged<ProductFormSaveReviewIssue>? onReviewIssueSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            ProductFormSaveActionVisuals.summaryIcon(summary),
            color: accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    summary.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  AppStatusPill(
                    label: summary.statusLabel,
                    color: accentColor,
                    icon: ProductFormSaveActionVisuals.statusIcon(summary),
                    maxWidth: 130,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                summary.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ProductFormSaveReadinessMeter(
                summary: summary,
                accentColor: accentColor,
              ),
              if (summary.hasReviewIssues) ...[
                const SizedBox(height: 10),
                ProductFormSaveReviewIssueStrip(
                  summary: summary,
                  onIssueSelected: onReviewIssueSelected,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Review and submit controls for the product form save action panel.
class _SaveActions extends StatelessWidget {
  const _SaveActions({
    required this.summary,
    required this.accentColor,
    required this.onSubmit,
    this.onReviewNext,
  });

  final ProductFormSaveActionSummary summary;
  final Color accentColor;
  final VoidCallback onSubmit;
  final VoidCallback? onReviewNext;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (onReviewNext != null)
          OutlinedButton.icon(
            onPressed: onReviewNext,
            icon: const Icon(Icons.center_focus_strong_rounded),
            label: Text(summary.reviewNextLabel),
          ),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: onSubmit,
            icon: Icon(ProductFormSaveActionVisuals.submitIcon(summary)),
            label: Text(summary.submitLabel),
            style: FilledButton.styleFrom(backgroundColor: accentColor),
          ),
        ),
      ],
    );
  }
}
