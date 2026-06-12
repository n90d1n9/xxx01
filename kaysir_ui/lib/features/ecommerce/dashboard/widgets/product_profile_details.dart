import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile.dart';
import '../models/product_profile_signal_visibility.dart';
import 'capability_chips.dart';
import 'dialog_section.dart';
import 'order_workspace_link.dart';
import 'product_profile_channel_list.dart';
import 'product_profile_coverage_rule_list.dart';
import 'product_profile_summary.dart';
import 'profile_registry_insights.dart';

class ProductProfileDetails extends StatelessWidget {
  final ProductProfile profile;
  final ValueChanged<String>? onOpenOrderWorkspace;

  const ProductProfileDetails({
    super.key,
    required this.profile,
    this.onOpenOrderWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('product_profile_details_${profile.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProductProfileSummary(
          profile: profile,
          chipLimits: ProductProfileChipLimits.active,
          signalVisibility: ProductProfileSignalVisibility.detailed,
          titleMaxLines: 2,
          descriptionMaxLines: 3,
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        DialogSection(
          title: 'Order workspace',
          child: OrderWorkspaceLink(
            profile: profile,
            onOpenOrderWorkspace: onOpenOrderWorkspace,
          ),
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        DialogSection(
          title: 'Capabilities',
          child: CapabilityChips(capabilities: profile.capabilities),
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        DialogSection(
          title: 'Sales channels',
          child: ProductProfileChannelList(channels: profile.salesChannels),
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        DialogSection(
          title: 'Coverage rules',
          child: ProductProfileCoverageRuleList(profile: profile),
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        DialogSection(
          title: 'Registry shape',
          child: ProfileRegistryInsights(
            profile: profile,
            maxKeywords: 12,
            maxModules: 12,
            maxActionRules: 12,
          ),
        ),
      ],
    );
  }
}
