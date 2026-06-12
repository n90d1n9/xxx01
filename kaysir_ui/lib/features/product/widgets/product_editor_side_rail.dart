import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import '../models/product_form_save_action.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_editor_guidance_stack.dart';
import 'product_form_save_action_panel.dart';

/// Reusable side rail for product editor guidance and save readiness.
class ProductEditorSideRail extends StatelessWidget {
  const ProductEditorSideRail({
    super.key,
    required this.overview,
    required this.progress,
    required this.groupProgress,
    required this.saveSummary,
    required this.onSubmit,
    this.onSelectAttribute,
    this.onSelectMissingAttribute,
    this.spacing = 16,
    this.maxVisibleMissingAttributes = 4,
  });

  final ProductFormSectionOverview overview;
  final ProductFormSectionProgressOverview progress;
  final ProductManagementPackFieldGroupProgressOverview groupProgress;
  final ProductFormSaveActionSummary saveSummary;
  final VoidCallback onSubmit;
  final ValueChanged<ProductFormAttributeDefinition>? onSelectAttribute;
  final ValueChanged<ProductFormMissingRequiredAttribute>?
  onSelectMissingAttribute;
  final double spacing;
  final int maxVisibleMissingAttributes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductEditorGuidanceStack(
          overview: overview,
          progress: progress,
          groupProgress: groupProgress,
          spacing: spacing,
          maxVisibleMissingAttributes: maxVisibleMissingAttributes,
          onSelectAttribute: onSelectAttribute,
          onSelectMissingAttribute: onSelectMissingAttribute,
        ),
        SizedBox(height: spacing),
        ProductFormSaveActionPanel(
          summary: saveSummary,
          onReviewIssueSelected:
              onSelectMissingAttribute == null
                  ? null
                  : (issue) => onSelectMissingAttribute!(issue.attribute),
          onReviewNext: _reviewNext,
          onSubmit: onSubmit,
        ),
      ],
    );
  }

  VoidCallback? get _reviewNext {
    final nextReviewAttribute = saveSummary.nextReviewAttribute;
    if (!saveSummary.canReviewNext ||
        nextReviewAttribute == null ||
        onSelectMissingAttribute == null) {
      return null;
    }

    return () => onSelectMissingAttribute!(nextReviewAttribute);
  }
}

@Preview(name: 'Product editor side rail')
Widget productEditorSideRailPreview() {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
  final progress = buildProductFormSectionProgressOverview(
    overview: overview,
    values: const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh produce',
      'description': 'Leafy greens',
    },
  );
  final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
    groups: buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    ),
    values: const {'expiry_date': '2026-07-01'},
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductEditorSideRail(
          overview: overview,
          progress: progress,
          groupProgress: groupProgress,
          saveSummary: buildProductFormSaveActionSummary(
            progress: progress,
            submitLabel: 'Add product',
            isEditing: false,
            groupProgress: groupProgress,
          ),
          onSelectAttribute: (_) {},
          onSelectMissingAttribute: (_) {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}
