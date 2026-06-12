import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_switch_option_surface.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile.dart';
import '../models/product_profile_search.dart';
import '../models/product_profile_signal_visibility.dart';
import 'current_profile_badge.dart';
import 'order_workspace_chip.dart';
import 'product_profile_icon_badge.dart';
import 'product_profile_summary.dart';
import 'profile_details_button.dart';
import 'profile_search_match_badge.dart';

class ProfileOptionTile extends StatelessWidget {
  final ProductProfile profile;
  final bool selected;
  final VoidCallback? onSelected;
  final VoidCallback? onDetailsRequested;
  final ProductProfileSearchMatch? searchMatch;

  const ProfileOptionTile({
    super.key,
    required this.profile,
    required this.selected,
    required this.onSelected,
    this.onDetailsRequested,
    this.searchMatch,
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchOptionSurface(
      selected: selected,
      onTap: onSelected,
      margin: const EdgeInsets.only(bottom: POSUiTokens.gap),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductProfileIconBadge(profile: profile, selected: selected),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ProductProfileSummary(
                  profile: profile,
                  trailing: selected ? const CurrentProfileBadge() : null,
                  signalVisibility: ProductProfileSignalVisibility.decision,
                  chipLimits: ProductProfileChipLimits.compact,
                ),
                const SizedBox(height: POSUiTokens.gap),
                OrderWorkspaceChip(profile: profile),
                if (searchMatch != null) ...[
                  const SizedBox(height: POSUiTokens.gap),
                  ProfileSearchMatchBadge(match: searchMatch!),
                ],
              ],
            ),
          ),
          if (onDetailsRequested != null) ...[
            const SizedBox(width: POSUiTokens.gap),
            ProfileDetailsButton(
              profileId: profile.id,
              keyPrefix: 'profile_option_details',
              onPressed: onDetailsRequested,
            ),
          ],
        ],
      ),
    );
  }
}
