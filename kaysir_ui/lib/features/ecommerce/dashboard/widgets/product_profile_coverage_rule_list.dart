import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/channel_requirement.dart';
import '../models/product_profile.dart';
import 'detail_row.dart';
import 'empty_state.dart';
import 'profile_detail_line.dart';
import 'tone.dart';

class ProductProfileCoverageRuleList extends StatelessWidget {
  const ProductProfileCoverageRuleList({required this.profile, super.key});

  final ProductProfile profile;

  @override
  Widget build(BuildContext context) {
    final requirements = profile.channelCoverageRequirements;

    if (requirements.isEmpty) {
      return const EmptyState(
        message: 'No channel coverage rules are registered for this profile.',
        prominent: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < requirements.length; index++) ...[
          if (index > 0) const SizedBox(height: POSUiTokens.gapLarge),
          _ProductProfileCoverageRuleRow(
            requirement: requirements[index],
            capabilities: profile.capabilities,
            channels: profile.salesChannels,
          ),
        ],
      ],
    );
  }
}

class _ProductProfileCoverageRuleRow extends StatelessWidget {
  const _ProductProfileCoverageRuleRow({
    required this.requirement,
    required this.capabilities,
    required this.channels,
  });

  final ChannelCoverageRequirement requirement;
  final List<ProductCapability> capabilities;
  final List<POSCommerceChannel> channels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = toneColors(
      theme.colorScheme,
      VisualTone.success,
      backgroundAlpha: 0.32,
    );
    final isRequired = requirement.isRequiredFor(capabilities);
    final coveredCount = requirement.coveredChannelCount(channels);
    final recommendation = requirement.recommendation;

    return DetailRow(
      icon: _iconForRequirement(requirement.type),
      title: requirement.label,
      description: _coverageDescription(
        requirement: requirement,
        isRequired: isRequired,
        coveredCount: coveredCount,
      ),
      iconColors: colors,
      iconBackgroundSource: ToneBackgroundSource.container,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileDetailLine(
            label: isRequired ? 'Required' : 'Optional',
            value: '$coveredCount matching channels',
          ),
          if (recommendation != null)
            ProfileDetailLine(label: 'Playbook', value: recommendation.title),
        ],
      ),
    );
  }
}

String _coverageDescription({
  required ChannelCoverageRequirement requirement,
  required bool isRequired,
  required int coveredCount,
}) {
  if (!isRequired) return requirement.optionalDetail;
  if (coveredCount > 0) return requirement.coveredDetail;

  return requirement.missingDetail;
}

IconData _iconForRequirement(ChannelCoverageRequirementType type) {
  return switch (type) {
    ChannelCoverageRequirementType.payments => Icons.payments_outlined,
    ChannelCoverageRequirementType.customers => Icons.account_circle_outlined,
    ChannelCoverageRequirementType.fulfillmentTracking =>
      Icons.track_changes_outlined,
    ChannelCoverageRequirementType.custom => Icons.fact_check_outlined,
  };
}
