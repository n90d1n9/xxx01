import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_form_attribute_chip.dart';
import 'product_form_section_visuals.dart';

/// Responsive overview of the product editor sections and required fields.
class ProductFormSectionOverviewPanel extends StatelessWidget {
  const ProductFormSectionOverviewPanel({
    super.key,
    required this.overview,
    this.progress,
    this.onSelectAttribute,
  });

  final ProductFormSectionOverview overview;
  final ProductFormSectionProgressOverview? progress;
  final ValueChanged<ProductFormAttributeDefinition>? onSelectAttribute;

  @override
  Widget build(BuildContext context) {
    if (!overview.hasSections) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: 'Product setup sections',
      subtitle: overview.pack.operatorFocusLabel,
      leadingIcon: Icons.view_quilt_rounded,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: overview.attributeCountLabel,
            color: colorScheme.primary,
            icon: Icons.tune_rounded,
            maxWidth: 126,
          ),
          AppStatusPill(
            label: overview.requiredAttributeCountLabel,
            color: colorScheme.tertiary,
            icon: Icons.task_alt_rounded,
            maxWidth: 160,
          ),
          if (progress != null)
            AppStatusPill(
              label: progress!.readinessLabel,
              color:
                  progress!.isReady ? Colors.teal.shade700 : colorScheme.error,
              icon:
                  progress!.isReady
                      ? Icons.verified_rounded
                      : Icons.error_outline_rounded,
              maxWidth: 170,
            ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount =
              constraints.maxWidth >= 920
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
          const gap = 12.0;
          final itemWidth =
              (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final section in overview.sections)
                SizedBox(
                  width: itemWidth,
                  child: _ProductFormSectionCard(
                    section: section,
                    progress: progress?.progressFor(section.id),
                    onSelectAttribute: onSelectAttribute,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Product form section overview panel')
Widget productFormSectionOverviewPanelPreview() {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductFormSectionOverviewPanel(
          overview: overview,
          progress: buildProductFormSectionProgressOverview(
            overview: overview,
            values: const {
              'name': 'Spinach',
              'sku': 'SP-001',
              'category': 'Fresh',
              'price': '12',
              'description': 'Leafy greens',
              'expiry_date': '2026-07-01',
            },
          ),
        ),
      ),
    ),
  );
}

/// Card for one logical product editor form section.
class _ProductFormSectionCard extends StatelessWidget {
  const _ProductFormSectionCard({
    required this.section,
    this.progress,
    this.onSelectAttribute,
  });

  final ProductFormSectionDefinition section;
  final ProductFormSectionProgress? progress;
  final ValueChanged<ProductFormAttributeDefinition>? onSelectAttribute;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = ProductFormSectionVisuals.sectionColor(
      section.id,
      colorScheme,
    );
    final visibleAttributes = section.attributes.take(4).toList();
    final hiddenCount = section.attributeCount - visibleAttributes.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: 0.06),
          colorScheme.surface,
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ProductFormSectionVisuals.sectionIcon(section.id),
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        section.subtitle,
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
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusPill(
                  label: section.attributeCountLabel,
                  color: accentColor,
                  icon: Icons.list_alt_rounded,
                  maxWidth: 112,
                ),
                AppStatusPill(
                  label: section.requiredAttributeCountLabel,
                  color: colorScheme.primary,
                  icon: Icons.task_alt_rounded,
                  maxWidth: 150,
                ),
                if (progress != null)
                  AppStatusPill(
                    label: progress!.readinessLabel,
                    color: ProductFormSectionVisuals.progressColor(
                      progress!,
                      colorScheme,
                    ),
                    icon: ProductFormSectionVisuals.progressIcon(progress!),
                    maxWidth: 170,
                  ),
                if (progress != null && progress!.hasRequiredAttributes)
                  AppStatusPill(
                    label: progress!.requiredProgressLabel,
                    color: colorScheme.secondary,
                    icon: Icons.speed_rounded,
                    maxWidth: 150,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final attribute in visibleAttributes)
                  ProductFormAttributeChip(
                    attribute: attribute,
                    accentColor: accentColor,
                    onSelected:
                        onSelectAttribute == null
                            ? null
                            : () => onSelectAttribute!(attribute),
                  ),
                if (hiddenCount > 0)
                  AppStatusPill(
                    label: '+$hiddenCount more',
                    color: colorScheme.outline,
                    maxWidth: 96,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
