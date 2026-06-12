import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/utils/pos_formatters.dart';
import '../models/overview.dart';
import 'kpi_card.dart';
import 'responsive_wrap_grid.dart';

class KpiGrid extends StatelessWidget {
  final Overview overview;

  const KpiGrid({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final insights = overview.orderInsights;
    final cards = [
      (
        label: 'Order volume',
        value: '${insights.orderCount}',
        detail: '${insights.paidOrderCount} paid orders',
        icon: Icons.receipt_long_outlined,
        tone: KpiTone.primary,
      ),
      (
        label: 'Net revenue',
        value: formatPOSCurrency(insights.revenue),
        detail: '${formatPOSCurrency(insights.averageOrderValue)} avg',
        icon: Icons.payments_outlined,
        tone: KpiTone.success,
      ),
      (
        label: 'Active checkout',
        value: overview.cartLabel,
        detail:
            overview.cartLineCount == 0
                ? 'Ready for a new basket'
                : formatPOSCurrency(overview.cartTotal),
        icon: Icons.shopping_cart_outlined,
        tone: KpiTone.secondary,
      ),
      (
        label: 'Ops alerts',
        value: '${overview.operationalAlertCount}',
        detail:
            overview.promisePolicyIssueCount == 0
                ? '${insights.attentionOrderCount} order review'
                : '${overview.promisePolicyIssueCount} policy review',
        icon: Icons.crisis_alert_outlined,
        tone:
            overview.operationalAlertCount == 0
                ? KpiTone.success
                : KpiTone.danger,
      ),
    ];

    return ResponsiveWrapGrid(
      itemCount: cards.length,
      columnsForWidth: _columnsForWidth,
      itemBuilder: (context, index, width) {
        final card = cards[index];

        return KpiCard(
          width: width,
          label: card.label,
          value: card.value,
          detail: card.detail,
          icon: card.icon,
          tone: card.tone,
        );
      },
    );
  }
}

int _columnsForWidth(double width) {
  if (width >= 1040) return 4;
  if (width >= 640) return 2;
  return 1;
}
