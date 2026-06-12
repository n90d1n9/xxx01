import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/product_core_information_field_ids.dart';
import '../models/product_core_information_field_summary.dart';

/// Inline action notice for the next core product information field to review.
class ProductCoreInformationReadinessNotice extends StatelessWidget {
  const ProductCoreInformationReadinessNotice({
    super.key,
    required this.summary,
    this.onReviewField,
  });

  final ProductCoreInformationFieldSummary summary;
  final ValueChanged<String>? onReviewField;

  @override
  Widget build(BuildContext context) {
    final field = summary.nextReviewField;
    if (field == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final accentColor =
        summary.hasInvalidFields ? colorScheme.error : colorScheme.tertiary;
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_icon, color: accentColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.nextReviewTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                summary.nextReviewDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final action =
        onReviewField == null
            ? null
            : OutlinedButton.icon(
              onPressed: () => onReviewField!(field.fieldId),
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: Text(summary.nextReviewActionLabel),
            );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: 0.06),
          colorScheme.surface,
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 720 || action == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  if (action != null) ...[const SizedBox(height: 10), action],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 12),
                action,
              ],
            );
          },
        ),
      ),
    );
  }

  IconData get _icon {
    if (summary.hasInvalidFields) return Icons.error_outline_rounded;

    return Icons.pending_actions_rounded;
  }
}

@Preview(name: 'Product core information readiness notice')
Widget productCoreInformationReadinessNoticePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductCoreInformationReadinessNotice(
          summary: ProductCoreInformationFieldSummary.forEditor(
            isEditing: false,
            values: const {
              ProductCoreInformationFieldIds.name: 'Spinach',
              ProductCoreInformationFieldIds.sku: 'SP-001',
              ProductCoreInformationFieldIds.category: 'Fresh',
              ProductCoreInformationFieldIds.price: 'abc',
              ProductCoreInformationFieldIds.initialStock: '8',
            },
          ),
          onReviewField: (_) {},
        ),
      ),
    ),
  );
}
