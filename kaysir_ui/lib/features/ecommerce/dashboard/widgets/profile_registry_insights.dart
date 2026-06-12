import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile.dart';
import 'profile_registry_insight_widgets.dart';

class ProfileRegistryInsights extends StatelessWidget {
  final ProductProfile profile;
  final int maxKeywords;
  final int maxModules;
  final int maxActionRules;

  const ProfileRegistryInsights({
    super.key,
    required this.profile,
    this.maxKeywords = 5,
    this.maxModules = 4,
    this.maxActionRules = 4,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      ProfileRegistryMetricWrap(profile: profile),
      if (profile.searchKeywords.isNotEmpty)
        ProfileRegistryChipSection(
          title: 'Search keywords',
          values: profile.searchKeywords,
          maxVisible: maxKeywords,
          chipKeyPrefix: 'profile_registry_keyword_chip',
        ),
      if (profile.modules.isNotEmpty)
        ProfileRegistryChipSection(
          title: 'Modules',
          values: profile.modules.map((module) => module.id),
          maxVisible: maxModules,
          chipKeyPrefix: 'profile_registry_module_chip',
        ),
      if (profile.actionRules.isNotEmpty)
        ProfileRegistryChipSection(
          title: 'Action rules',
          values: profile.actionRules.map((rule) => rule.id),
          maxVisible: maxActionRules,
          chipKeyPrefix: 'profile_registry_action_rule_chip',
        ),
    ];

    return Column(
      key: const ValueKey('profile_registry_insights'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          if (index > 0) const SizedBox(height: POSUiTokens.gapLarge),
          sections[index],
        ],
      ],
    );
  }
}
