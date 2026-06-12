import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import '../models/product_editor_section_navigator_view_state.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_editor_section_navigator.dart';
import 'product_form_guidance_stack.dart';

/// Reusable workflow guidance stack for product editor readiness navigation.
class ProductEditorGuidanceStack extends StatelessWidget {
  const ProductEditorGuidanceStack({
    super.key,
    required this.overview,
    required this.progress,
    required this.groupProgress,
    this.onSelectAttribute,
    this.onSelectMissingAttribute,
    this.spacing = 16,
    this.maxVisibleMissingAttributes = 4,
  });

  final ProductFormSectionOverview overview;
  final ProductFormSectionProgressOverview progress;
  final ProductManagementPackFieldGroupProgressOverview groupProgress;
  final ValueChanged<ProductFormAttributeDefinition>? onSelectAttribute;
  final ValueChanged<ProductFormMissingRequiredAttribute>?
  onSelectMissingAttribute;
  final double spacing;
  final int maxVisibleMissingAttributes;

  @override
  Widget build(BuildContext context) {
    final navigatorState = ProductEditorSectionNavigatorViewState.from(
      progress: progress,
      groupProgress: groupProgress,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductEditorSectionNavigator(
          viewState: navigatorState,
          onSelectItem: _canHandleNavigatorItem ? _handleNavigatorItem : null,
        ),
        if (overview.hasSections) ...[
          SizedBox(height: spacing),
          ProductFormGuidanceStack(
            overview: overview,
            progress: progress,
            spacing: spacing,
            maxVisibleMissingAttributes: maxVisibleMissingAttributes,
            onSelectAttribute: onSelectAttribute,
            onSelectMissingAttribute: onSelectMissingAttribute,
          ),
        ],
      ],
    );
  }

  bool get _canHandleNavigatorItem {
    return onSelectMissingAttribute != null || onSelectAttribute != null;
  }

  void _handleNavigatorItem(ProductEditorSectionNavigatorItem item) {
    final attribute = item.reviewAttribute;
    if (attribute != null) {
      if (onSelectMissingAttribute != null) {
        onSelectMissingAttribute!(attribute);
        return;
      }

      onSelectAttribute?.call(attribute.attribute);
      return;
    }

    final primaryAttribute = item.primaryAttribute;
    if (primaryAttribute == null) return;

    onSelectAttribute?.call(primaryAttribute);
  }
}

@Preview(name: 'Product editor guidance stack')
Widget productEditorGuidanceStackPreview() {
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
        child: ProductEditorGuidanceStack(
          overview: overview,
          progress: progress,
          groupProgress: groupProgress,
          onSelectAttribute: (_) {},
          onSelectMissingAttribute: (_) {},
        ),
      ),
    ),
  );
}
