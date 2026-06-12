import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';

/// Visual tone used by reusable product field requirement chips.
enum ProductFieldInputRequirementTone { required, optional, locked }

/// Presentation data for reusable product field helper content.
class ProductFieldInputHelperData {
  const ProductFieldInputHelperData({
    required this.description,
    required this.requirementLabel,
    required this.requirementTone,
    required this.typeLabel,
    required this.typeIcon,
    this.unitLabel,
  });

  final String description;
  final String requirementLabel;
  final ProductFieldInputRequirementTone requirementTone;
  final String typeLabel;
  final IconData typeIcon;
  final String? unitLabel;
}

/// Shared helper content for product editor inputs.
class ProductFieldInputHelper extends StatelessWidget {
  const ProductFieldInputHelper({
    super.key,
    required this.data,
    this.maxDescriptionLines = 2,
  });

  final ProductFieldInputHelperData data;
  final int maxDescriptionLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.description,
          maxLines: maxDescriptionLines,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppStatusPill(
              label: data.requirementLabel,
              color: _requirementColor(colorScheme),
              icon: _requirementIcon,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              iconSize: 13,
              maxWidth: 112,
            ),
            AppStatusPill(
              label: data.typeLabel,
              color: colorScheme.primary,
              icon: data.typeIcon,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              iconSize: 13,
              maxWidth: 112,
            ),
            if (data.unitLabel != null)
              AppStatusPill(
                label: data.unitLabel!,
                color: colorScheme.secondary,
                icon: Icons.straighten_rounded,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                iconSize: 13,
                maxWidth: 88,
              ),
          ],
        ),
      ],
    );
  }

  Color _requirementColor(ColorScheme colorScheme) {
    return switch (data.requirementTone) {
      ProductFieldInputRequirementTone.required => colorScheme.error,
      ProductFieldInputRequirementTone.optional => colorScheme.tertiary,
      ProductFieldInputRequirementTone.locked => colorScheme.outline,
    };
  }

  IconData get _requirementIcon {
    return switch (data.requirementTone) {
      ProductFieldInputRequirementTone.required => Icons.task_alt_rounded,
      ProductFieldInputRequirementTone.optional =>
        Icons.radio_button_unchecked_rounded,
      ProductFieldInputRequirementTone.locked => Icons.lock_rounded,
    };
  }
}

@Preview(name: 'Product field input helper')
Widget productFieldInputHelperPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: ProductFieldInputHelper(
          data: ProductFieldInputHelperData(
            description: 'Base selling price used by POS and catalog.',
            requirementLabel: 'Required',
            requirementTone: ProductFieldInputRequirementTone.required,
            typeLabel: 'Money',
            typeIcon: Icons.payments_rounded,
          ),
        ),
      ),
    ),
  );
}
