import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';

/// Reusable chip for missing required product form attributes.
class ProductFormMissingAttributeChip extends StatelessWidget {
  const ProductFormMissingAttributeChip({
    super.key,
    required this.attribute,
    required this.color,
    this.onSelected,
    this.maxWidth = 180,
  });

  final ProductFormMissingRequiredAttribute attribute;
  final Color color;
  final VoidCallback? onSelected;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final chip = AppStatusPill(
      label: attribute.label,
      color: color,
      icon: Icons.radio_button_unchecked_rounded,
      tooltip: attribute.helperLabel,
      maxWidth: maxWidth,
    );
    if (onSelected == null) return chip;

    return Semantics(
      button: true,
      label: attribute.label,
      hint: 'Focus field',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(999),
          child: chip,
        ),
      ),
    );
  }
}

@Preview(name: 'Product form missing attribute chip')
Widget productFormMissingAttributeChipPreview() {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
  final progress = buildProductFormSectionProgressOverview(
    overview: overview,
    values: const {'name': 'Spinach'},
  );
  final attribute = progress.missingRequiredAttributes.first;

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) {
            return ProductFormMissingAttributeChip(
              attribute: attribute,
              color: Theme.of(context).colorScheme.error,
              onSelected: () {},
            );
          },
        ),
      ),
    ),
  );
}
