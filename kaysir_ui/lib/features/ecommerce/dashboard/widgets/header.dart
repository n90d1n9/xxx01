import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/overview.dart';
import '../models/product_profile.dart';
import 'header_actions.dart';
import 'header_summary.dart';
import 'panel_surface.dart';
import 'product_profile_summary.dart';

class Header extends StatelessWidget {
  final Overview overview;
  final ProductProfile productProfile;
  final VoidCallback onOpenCheckout;
  final VoidCallback onOpenOrders;

  const Header({
    super.key,
    required this.overview,
    required this.productProfile,
    required this.onOpenCheckout,
    required this.onOpenOrders,
  });

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(16),
      elevated: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedActions = constraints.maxWidth < 760;

          final summary = HeaderSummary(
            overview: overview,
            productProfile: productProfile,
            chipLimits: ProductProfileChipLimits(
              channels: useStackedActions ? 3 : 4,
              capabilities: useStackedActions ? 3 : 5,
              requirements: useStackedActions ? 3 : 5,
            ),
          );

          final actions = HeaderActions(
            onOpenCheckout: onOpenCheckout,
            onOpenOrders: onOpenOrders,
          );

          if (useStackedActions) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: POSUiTokens.gapLarge),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: summary),
              const SizedBox(width: POSUiTokens.gapLarge),
              actions,
            ],
          );
        },
      ),
    );
  }
}
