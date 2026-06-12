import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/sales_channel_readiness.dart';
import 'sales_channel_issue_breakdown.dart';

/// Compact readiness strip for active product sales channels.
class ProductSalesChannelReadinessStrip extends StatelessWidget {
  const ProductSalesChannelReadinessStrip({
    super.key,
    required this.readiness,
    required this.onSelected,
    this.onIssueSelected,
  });

  final List<ProductSalesChannelReadiness> readiness;
  final ValueChanged<ProductSalesChannelReadiness> onSelected;
  final ProductSalesChannelReadinessIssueSelection? onIssueSelected;

  @override
  Widget build(BuildContext context) {
    if (readiness.isEmpty) return const SizedBox.shrink();

    return AppContentPanel(
      title: 'Channel readiness',
      subtitle: 'Quick review queues for active selling channels',
      leadingIcon: Icons.hub_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              constraints.maxWidth >= 980
                  ? 4
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
          const gap = 10.0;
          final cardWidth =
              (constraints.maxWidth - (gap * (columns - 1))) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final item in readiness)
                SizedBox(
                  width: cardWidth,
                  child: _ProductSalesChannelReadinessStripItem(
                    readiness: item,
                    onPressed: () => onSelected(item),
                    onIssueSelected: onIssueSelected,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Sales channel readiness strip')
Widget productSalesChannelReadinessStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelReadinessStrip(
          readiness: buildProductSalesChannelReadiness(const []),
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Compact sales-channel readiness tile used inside the strip.
class _ProductSalesChannelReadinessStripItem extends StatelessWidget {
  const _ProductSalesChannelReadinessStripItem({
    required this.readiness,
    required this.onPressed,
    this.onIssueSelected,
  });

  final ProductSalesChannelReadiness readiness;
  final VoidCallback onPressed;
  final ProductSalesChannelReadinessIssueSelection? onIssueSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _accentColor(readiness.channel);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: SizedBox(
          height: 122,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon(readiness.channel), size: 20, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        readiness.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    AppStatusPill(
                      label: readiness.percentLabel,
                      color: accent,
                      maxWidth: 62,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  readiness.countLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ProductSalesChannelIssueBreakdown(
                      readiness: readiness,
                      accentColor: accent,
                      maxVisibleIssues: 1,
                      onIssueSelected: onIssueSelected,
                    ),
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

IconData _icon(ProductSalesChannel channel) {
  switch (channel) {
    case ProductSalesChannel.posCheckout:
      return Icons.point_of_sale_rounded;
    case ProductSalesChannel.onlineStore:
      return Icons.language_rounded;
    case ProductSalesChannel.marketplace:
      return Icons.storefront_rounded;
    case ProductSalesChannel.kiosk:
      return Icons.qr_code_scanner_rounded;
  }
}

Color _accentColor(ProductSalesChannel channel) {
  switch (channel) {
    case ProductSalesChannel.posCheckout:
      return Colors.teal.shade700;
    case ProductSalesChannel.onlineStore:
      return Colors.blue.shade700;
    case ProductSalesChannel.marketplace:
      return Colors.deepPurple.shade600;
    case ProductSalesChannel.kiosk:
      return Colors.indigo.shade700;
  }
}
