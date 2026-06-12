import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_form_section.dart';

/// Reusable chip for product form attributes across editor guidance surfaces.
class ProductFormAttributeChip extends StatelessWidget {
  const ProductFormAttributeChip({
    super.key,
    required this.attribute,
    required this.accentColor,
    this.onSelected,
    this.maxWidth = 150,
  });

  final ProductFormAttributeDefinition attribute;
  final Color accentColor;
  final VoidCallback? onSelected;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final chip = AppStatusPill(
      label: attribute.required ? '${attribute.label} *' : attribute.label,
      color: accentColor,
      tooltip:
          '${attribute.typeLabel} | ${attribute.requirementLabel} | '
          '${attribute.sourceLabel}',
      showDot: true,
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

@Preview(name: 'Product form attribute chip')
Widget productFormAttributeChipPreview() {
  const attribute = ProductFormAttributeDefinition(
    id: 'expiry_date',
    label: 'Expiry date',
    description: 'Sell-by date used by fresh goods workflows.',
    typeLabel: 'Date',
    required: true,
    sourceLabel: 'Grocery Fresh Goods',
  );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) {
            return ProductFormAttributeChip(
              attribute: attribute,
              accentColor: Theme.of(context).colorScheme.primary,
              onSelected: () {},
            );
          },
        ),
      ),
    ),
  );
}
