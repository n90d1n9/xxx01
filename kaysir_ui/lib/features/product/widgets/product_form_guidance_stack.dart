import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_form_required_action_panel.dart';
import 'product_form_section_overview_panel.dart';

/// Reusable guidance stack for product editor setup and required actions.
class ProductFormGuidanceStack extends StatelessWidget {
  const ProductFormGuidanceStack({
    super.key,
    required this.overview,
    required this.progress,
    this.onSelectAttribute,
    this.onSelectMissingAttribute,
    this.spacing = 16,
    this.maxVisibleMissingAttributes = 4,
  });

  final ProductFormSectionOverview overview;
  final ProductFormSectionProgressOverview progress;
  final ValueChanged<ProductFormAttributeDefinition>? onSelectAttribute;
  final ValueChanged<ProductFormMissingRequiredAttribute>?
  onSelectMissingAttribute;
  final double spacing;
  final int maxVisibleMissingAttributes;

  @override
  Widget build(BuildContext context) {
    if (!overview.hasSections) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductFormSectionOverviewPanel(
          overview: overview,
          progress: progress,
          onSelectAttribute: onSelectAttribute,
        ),
        if (progress.hasMissingRequiredAttributes) ...[
          SizedBox(height: spacing),
          ProductFormRequiredActionPanel(
            progress: progress,
            maxVisibleAttributes: maxVisibleMissingAttributes,
            onSelectAttribute: onSelectMissingAttribute,
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Product form guidance stack')
Widget productFormGuidanceStackPreview() {
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
        child: ProductFormGuidanceStack(
          overview: overview,
          progress: progress,
          onSelectAttribute: (_) {},
          onSelectMissingAttribute: (_) {},
        ),
      ),
    ),
  );
}
