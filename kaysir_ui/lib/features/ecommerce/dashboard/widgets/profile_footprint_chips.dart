import 'package:flutter/material.dart';

import '../models/product_profile.dart';
import '../models/profile_comparison.dart';
import 'chip_tone.dart';
import 'text_badge.dart';

class ProfileFootprintChips extends StatelessWidget {
  final int salesChannelCount;
  final int capabilityCount;
  final int moduleCount;
  final int actionRuleCount;
  final int searchKeywordCount;
  final double spacing;
  final double runSpacing;

  const ProfileFootprintChips({
    super.key,
    required this.salesChannelCount,
    required this.capabilityCount,
    required this.moduleCount,
    required this.actionRuleCount,
    required this.searchKeywordCount,
    this.spacing = 6,
    this.runSpacing = 6,
  }) : assert(salesChannelCount >= 0),
       assert(capabilityCount >= 0),
       assert(moduleCount >= 0),
       assert(actionRuleCount >= 0),
       assert(searchKeywordCount >= 0);

  factory ProfileFootprintChips.forProfile({
    Key? key,
    required ProductProfile profile,
    double spacing = 6,
    double runSpacing = 6,
  }) {
    return ProfileFootprintChips(
      key: key,
      salesChannelCount: profile.salesChannels.length,
      capabilityCount: profile.capabilities.length,
      moduleCount: profile.modules.length,
      actionRuleCount: profile.actionRules.length,
      searchKeywordCount: profile.searchKeywords.length,
      spacing: spacing,
      runSpacing: runSpacing,
    );
  }

  factory ProfileFootprintChips.forComparisonRow({
    Key? key,
    required ProfileComparisonRow row,
    double spacing = 6,
    double runSpacing = 6,
  }) {
    return ProfileFootprintChips(
      key: key,
      salesChannelCount: row.salesChannelCount,
      capabilityCount: row.capabilityCount,
      moduleCount: row.moduleCount,
      actionRuleCount: row.actionRuleCount,
      searchKeywordCount: row.searchKeywordCount,
      spacing: spacing,
      runSpacing: runSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        _ProfileFootprintChip(label: _shortCount(salesChannelCount, 'ch')),
        _ProfileFootprintChip(label: _shortCount(capabilityCount, 'cap')),
        _ProfileFootprintChip(label: _shortCount(moduleCount, 'mod')),
        _ProfileFootprintChip(label: _shortCount(actionRuleCount, 'rule')),
        _ProfileFootprintChip(label: _shortCount(searchKeywordCount, 'kw')),
      ],
    );
  }
}

class _ProfileFootprintChip extends StatelessWidget {
  final String label;

  const _ProfileFootprintChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = mutedChipColors(Theme.of(context), backgroundAlpha: 0.55);

    return TextBadge(
      label: label,
      colors: colors,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}

String _shortCount(int count, String suffix) {
  return '$count $suffix';
}
