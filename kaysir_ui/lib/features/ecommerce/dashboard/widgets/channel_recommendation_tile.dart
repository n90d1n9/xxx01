import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/channel_recommendation.dart';
import 'detail_row.dart';
import 'inset_surface.dart';
import 'text_badge.dart';
import 'tone.dart';

class ChannelRecommendationTile extends StatelessWidget {
  const ChannelRecommendationTile({required this.recommendation, super.key});

  final ChannelRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = channelRecommendationToneColors(
      theme.colorScheme,
      recommendation.tone,
    );

    return Padding(
      key: ValueKey(
        'channel_recommendation_'
        '${recommendation.coverageRequirementId ?? recommendation.type.name}',
      ),
      padding: const EdgeInsets.only(bottom: POSUiTokens.gap),
      child: InsetSurface(
        color: colors.background,
        border: Border.all(color: colors.border),
        child: DetailRow(
          icon: channelRecommendationIcon(recommendation.type),
          title: recommendation.title,
          description: recommendation.detail,
          iconBadgeSize: 30,
          iconSize: 17,
          iconColors: colors,
          footer: TextBadge(
            label: recommendation.actionLabel,
            tone: VisualTone.primary,
            backgroundAlpha: 0.42,
            borderAlpha: 0.16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

IconData channelRecommendationIcon(ChannelRecommendationType type) {
  return switch (type) {
    ChannelRecommendationType.registerChannels => Icons.hub_outlined,
    ChannelRecommendationType.addFulfillmentModes =>
      Icons.local_shipping_outlined,
    ChannelRecommendationType.addPaymentChannel => Icons.payments_outlined,
    ChannelRecommendationType.addCustomerIdentityChannel =>
      Icons.account_circle_outlined,
    ChannelRecommendationType.addFulfillmentTrackingChannel =>
      Icons.track_changes_outlined,
    ChannelRecommendationType.addChannelRequirementCoverage =>
      Icons.fact_check_outlined,
  };
}

ToneColors channelRecommendationToneColors(
  ColorScheme scheme,
  ChannelRecommendationTone tone,
) {
  return switch (tone) {
    ChannelRecommendationTone.attention => toneColors(
      scheme,
      VisualTone.danger,
      backgroundAlpha: 0.16,
    ),
  };
}
