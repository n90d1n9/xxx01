import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_core_information_field_summary.dart';

/// Compact status pills for the core product information editor section.
class ProductCoreInformationSummaryPills extends StatelessWidget {
  const ProductCoreInformationSummaryPills({super.key, required this.summary});

  final ProductCoreInformationFieldSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: summary.fieldCountLabel,
          color: colorScheme.primary,
          icon: Icons.view_list_rounded,
          maxWidth: 116,
        ),
        AppStatusPill(
          label: summary.readyProgressLabel,
          color: summary.isReady ? Colors.teal.shade700 : colorScheme.primary,
          icon: summary.isReady ? Icons.task_alt_rounded : Icons.speed_rounded,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: summary.readinessLabel,
          color:
              summary.isReady
                  ? Colors.teal.shade700
                  : summary.hasInvalidFields
                  ? colorScheme.error
                  : colorScheme.tertiary,
          icon:
              summary.isReady
                  ? Icons.verified_rounded
                  : summary.hasInvalidFields
                  ? Icons.error_outline_rounded
                  : Icons.pending_actions_rounded,
          maxWidth: 116,
        ),
        if (summary.hasLockedFields)
          AppStatusPill(
            label: summary.lockedFieldCountLabel,
            color: colorScheme.outline,
            icon: Icons.lock_rounded,
            maxWidth: 116,
          ),
      ],
    );
  }
}

@Preview(name: 'Product core information summary pills')
Widget productCoreInformationSummaryPillsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductCoreInformationSummaryPills(
          summary: ProductCoreInformationFieldSummary.forEditor(
            isEditing: true,
          ),
        ),
      ),
    ),
  );
}
