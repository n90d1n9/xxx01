import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/overview.dart';
import '../models/product_profile.dart';
import 'metric_pill.dart';

class HeaderStatusPills extends StatelessWidget {
  const HeaderStatusPills({
    required this.overview,
    required this.productProfile,
    super.key,
  });

  final Overview overview;
  final ProductProfile productProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: [
        MetricPill(
          icon: const Icon(Icons.view_quilt_outlined),
          label: 'Profile',
          value: productProfile.label,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          foregroundColor: theme.colorScheme.onSurfaceVariant,
        ),
        MetricPill(
          icon: const Icon(Icons.receipt_long_outlined),
          label: 'Orders',
          value: '${overview.orderInsights.orderCount}',
        ),
        MetricPill(
          icon: const Icon(Icons.shopping_cart_outlined),
          label: 'Cart',
          value: overview.cartLabel,
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
        ),
        MetricPill(
          icon: const Icon(Icons.rule_folder_outlined),
          label: 'Policy',
          value: overview.policyHealthLabel,
          backgroundColor:
              overview.hasPolicyIssues
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.tertiaryContainer,
          foregroundColor:
              overview.hasPolicyIssues
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onTertiaryContainer,
        ),
      ],
    );
  }
}
