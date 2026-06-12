import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile.dart';
import '../models/product_profile_signal_visibility.dart';
import 'product_profile_highlights.dart';
import 'profile_decision_signals.dart';
import 'profile_footprint_chips.dart';

export 'product_profile_highlights.dart';

class ProductProfileSummary extends StatelessWidget {
  final ProductProfile profile;
  final String? eyebrow;
  final Widget? trailing;
  final ProductProfileChipLimits chipLimits;
  final ProductProfileSignalVisibility signalVisibility;
  final bool showDescription;
  final int titleMaxLines;
  final int descriptionMaxLines;
  final TextStyle? eyebrowStyle;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  const ProductProfileSummary({
    super.key,
    required this.profile,
    this.eyebrow,
    this.trailing,
    this.chipLimits = ProductProfileChipLimits.compact,
    this.signalVisibility = ProductProfileSignalVisibility.none,
    this.showDescription = true,
    this.titleMaxLines = 1,
    this.descriptionMaxLines = 2,
    this.eyebrowStyle,
    this.titleStyle,
    this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eyebrow = this.eyebrow;

    return Column(
      key: ValueKey('product_profile_summary_${profile.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                eyebrowStyle ??
                theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                profile.label,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style:
                    titleStyle ??
                    theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: POSUiTokens.gap),
              trailing!,
            ],
          ],
        ),
        if (showDescription) ...[
          const SizedBox(height: 3),
          Text(
            profile.description,
            maxLines: descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
            style:
                descriptionStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        if (signalVisibility.hasDecisionSignals) ...[
          const SizedBox(height: POSUiTokens.gap),
          ProfileDecisionSignals.forProfile(
            profile: profile,
            showBusinessMotion: signalVisibility.businessMotion,
            showLaunchComplexity: signalVisibility.launchComplexity,
          ),
        ],
        if (signalVisibility.hasFootprint) ...[
          const SizedBox(height: POSUiTokens.gap),
          ProfileFootprintChips.forProfile(profile: profile),
        ],
        if (productProfileHasHighlights(profile)) ...[
          const SizedBox(height: POSUiTokens.gap),
          ProductProfileHighlights(profile: profile, chipLimits: chipLimits),
        ],
      ],
    );
  }
}
