import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../models/sales_channel_readiness.dart';

/// Horizontal comparison strip for switching sales-channel profiles.
class ProductSalesChannelProfileComparisonStrip extends StatelessWidget {
  const ProductSalesChannelProfileComparisonStrip({
    super.key,
    required this.options,
    required this.onSelected,
  });

  final List<ProductSalesChannelProfileReadinessOption> options;
  final ValueChanged<ProductSalesChannelProfileId> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < options.length; index += 1) ...[
            _ProfileComparisonCard(
              option: options[index],
              onPressed:
                  options[index].canSelect
                      ? () => onSelected(options[index].profile.id)
                      : null,
            ),
            if (index != options.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Sales channel profile comparison')
Widget productSalesChannelProfileComparisonStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelProfileComparisonStrip(
          options: _previewOptions,
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Compact selectable card for one profile candidate.
class _ProfileComparisonCard extends StatelessWidget {
  const _ProfileComparisonCard({required this.option, required this.onPressed});

  final ProductSalesChannelProfileReadinessOption option;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _levelColor(option.summary.level);
    final surface =
        option.isSelected
            ? colorScheme.primary.withValues(alpha: 0.06)
            : colorScheme.surface;

    return SizedBox(
      width: 256,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(
            color:
                option.isSelected
                    ? colorScheme.primary.withValues(alpha: 0.28)
                    : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon(option.profile.id), size: 18, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.titleLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    AppStatusPill(
                      label: option.statusLabel,
                      color: option.isSelected ? colorScheme.primary : accent,
                      maxWidth: 112,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  option.detailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  option.summary.blockerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  option.switchImpactLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: option.isSelected ? colorScheme.primary : accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  option.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: option.isSelected ? colorScheme.primary : accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _icon(ProductSalesChannelProfileId id) {
  if (id == ProductSalesChannelProfileId.omniRetail) {
    return Icons.hub_rounded;
  }
  if (id == ProductSalesChannelProfileId.counterService) {
    return Icons.point_of_sale_rounded;
  }
  if (id == ProductSalesChannelProfileId.digitalCommerce) {
    return Icons.language_rounded;
  }

  return Icons.category_rounded;
}

Color _levelColor(ProductSalesChannelProfileReadinessLevel level) {
  switch (level) {
    case ProductSalesChannelProfileReadinessLevel.blocked:
      return Colors.red.shade700;
    case ProductSalesChannelProfileReadinessLevel.improving:
      return Colors.orange.shade700;
    case ProductSalesChannelProfileReadinessLevel.ready:
      return Colors.green.shade700;
  }
}

final _previewOptions = buildProductSalesChannelProfileReadinessOptions(
  const [],
  profiles: defaultProductSalesChannelProfiles,
  selectedProfileId: ProductSalesChannelProfileId.omniRetail,
);
