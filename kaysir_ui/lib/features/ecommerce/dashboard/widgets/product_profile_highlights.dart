import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile.dart';
import 'capability_chips.dart';
import 'channel_chips.dart';
import 'channel_requirement_chips.dart';

class ProductProfileChipLimits {
  final int? channels;
  final int? capabilities;
  final int? requirements;

  const ProductProfileChipLimits({
    this.channels,
    this.capabilities,
    this.requirements,
  });

  static const compact = ProductProfileChipLimits(
    channels: 3,
    capabilities: 4,
    requirements: 4,
  );

  static const active = ProductProfileChipLimits(
    channels: 4,
    capabilities: 5,
    requirements: 4,
  );
}

class ProductProfileHighlights extends StatelessWidget {
  final ProductProfile profile;
  final ProductProfileChipLimits chipLimits;

  const ProductProfileHighlights({
    super.key,
    required this.profile,
    this.chipLimits = ProductProfileChipLimits.compact,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (profile.salesChannels.isNotEmpty)
        ChannelChips(
          channels: profile.salesChannels,
          maxVisible: chipLimits.channels,
        ),
      if (profile.capabilities.isNotEmpty)
        CapabilityChips(
          capabilities: profile.capabilities,
          maxVisible: chipLimits.capabilities,
        ),
      if (profile.channelCoverageRequirements.isNotEmpty)
        ChannelRequirementChips(
          requirements: profile.channelCoverageRequirements,
          maxVisible: chipLimits.requirements,
        ),
    ];

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      key: ValueKey('product_profile_highlights_${profile.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _withSpacing(children),
    );
  }
}

bool productProfileHasHighlights(ProductProfile profile) {
  return profile.salesChannels.isNotEmpty ||
      profile.capabilities.isNotEmpty ||
      profile.channelCoverageRequirements.isNotEmpty;
}

List<Widget> _withSpacing(List<Widget> children) {
  return [
    for (var index = 0; index < children.length; index++) ...[
      if (index > 0) const SizedBox(height: POSUiTokens.gap),
      children[index],
    ],
  ];
}
