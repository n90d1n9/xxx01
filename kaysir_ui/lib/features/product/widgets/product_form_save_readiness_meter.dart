import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import '../models/product_form_save_action.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_form_save_action_visuals.dart';

/// Compact readiness meter for product form save progress.
class ProductFormSaveReadinessMeter extends StatelessWidget {
  const ProductFormSaveReadinessMeter({
    super.key,
    required this.summary,
    required this.accentColor,
  });

  final ProductFormSaveActionSummary summary;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                summary.readinessPercentLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              summary.requiredReadinessCountLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: summary.readinessFraction,
            color: accentColor,
            backgroundColor: accentColor.withValues(alpha: 0.14),
            semanticsLabel: 'Product form readiness',
            semanticsValue:
                (summary.readinessFraction * 100).round().toString(),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Product form save readiness meter')
Widget productFormSaveReadinessMeterPreview() {
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
  final summary = buildProductFormSaveActionSummary(
    progress: progress,
    submitLabel: 'Add product',
    isEditing: false,
  );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Builder(
            builder: (context) {
              return ProductFormSaveReadinessMeter(
                summary: summary,
                accentColor: ProductFormSaveActionVisuals.accentColor(
                  summary,
                  Theme.of(context).colorScheme,
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
