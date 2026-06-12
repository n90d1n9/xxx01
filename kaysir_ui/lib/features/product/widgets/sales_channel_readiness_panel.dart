import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/sales_channel_readiness.dart';
import 'sales_channel_issue_breakdown.dart';

/// Full readiness board for product sales channels.
class ProductSalesChannelReadinessPanel extends StatelessWidget {
  const ProductSalesChannelReadinessPanel({
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
    return AppContentPanel(
      title: 'Channel readiness',
      subtitle: 'Product coverage across checkout and selling channels',
      leadingIcon: Icons.hub_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount =
              constraints.maxWidth >= 980
                  ? 4
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
          const gap = 12.0;
          final cardWidth =
              (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final item in readiness)
                SizedBox(
                  width: cardWidth,
                  child: _SalesChannelReadinessCard(
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

@Preview(name: 'Sales channel readiness panel')
Widget productSalesChannelReadinessPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelReadinessPanel(
          readiness: buildProductSalesChannelReadiness(const []),
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Single sales-channel readiness card.
class _SalesChannelReadinessCard extends StatelessWidget {
  const _SalesChannelReadinessCard({
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
          height: 234,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon(readiness.channel), color: accent, size: 22),
                    const Spacer(),
                    AppStatusPill(
                      label: readiness.actionLabel,
                      color: accent,
                      maxWidth: 94,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  readiness.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  readiness.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ProductSalesChannelIssueBreakdown(
                      readiness: readiness,
                      accentColor: accent,
                      onIssueSelected: onIssueSelected,
                    ),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: readiness.readyPercent / 100,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        readiness.countLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
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
