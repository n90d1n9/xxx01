import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/overview.dart';
import '../models/product_profile.dart';
import 'header_status_pills.dart';
import 'product_profile_summary.dart';
import 'tonal_icon_badge.dart';

class HeaderSummary extends StatelessWidget {
  const HeaderSummary({
    required this.overview,
    required this.productProfile,
    required this.chipLimits,
    super.key,
  });

  final Overview overview;
  final ProductProfile productProfile;
  final ProductProfileChipLimits chipLimits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TonalIconBadge(
              icon: Icons.storefront_outlined,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: POSUiTokens.gapLarge),
            Flexible(
              child: Text(
                'Commerce Workspace',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: POSUiTokens.gap),
        Text(
          'Omnichannel checkout, fulfillment, and order health in one operational view.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        HeaderStatusPills(overview: overview, productProfile: productProfile),
        if (productProfileHasHighlights(productProfile)) ...[
          const SizedBox(height: POSUiTokens.gap),
          ProductProfileHighlights(
            profile: productProfile,
            chipLimits: chipLimits,
          ),
        ],
      ],
    );
  }
}
