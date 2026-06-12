import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_switch_option_surface.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/profile_comparison.dart';
import 'current_profile_badge.dart';
import 'profile_decision_signals.dart';
import 'profile_details_button.dart';
import 'profile_footprint_chips.dart';

class ProfileComparisonRowTile extends StatelessWidget {
  const ProfileComparisonRowTile({
    required this.row,
    required this.selected,
    required this.onSelected,
    this.onDetailsRequested,
    super.key,
  });

  final ProfileComparisonRow row;
  final bool selected;
  final VoidCallback? onSelected;
  final VoidCallback? onDetailsRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSwitchOptionSurface(
      selected: selected,
      onTap: onSelected,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: POSUiTokens.gap),
                const CurrentProfileBadge(),
              ],
              if (onDetailsRequested != null) ...[
                const SizedBox(width: POSUiTokens.gap),
                ProfileDetailsButton(
                  profileId: row.profileId,
                  keyPrefix: 'profile_comparison_details',
                  onPressed: onDetailsRequested,
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            row.presentationLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: POSUiTokens.gap),
          ProfileDecisionSignals(
            businessMotion: row.businessMotion,
            launchComplexity: row.launchComplexity,
            launchComplexityScore: row.launchComplexityScore,
          ),
          const SizedBox(height: POSUiTokens.gap),
          ProfileFootprintChips.forComparisonRow(row: row),
        ],
      ),
    );
  }
}
