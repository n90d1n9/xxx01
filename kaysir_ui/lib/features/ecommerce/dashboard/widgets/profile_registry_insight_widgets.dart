import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile.dart';
import 'profile_registry_metric_chip.dart';
import 'profile_registry_text_chip.dart';

class ProfileRegistryMetricWrap extends StatelessWidget {
  const ProfileRegistryMetricWrap({required this.profile, super.key});

  final ProductProfile profile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('profile_registry_metric_wrap'),
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: [
        ProfileRegistryMetricChip(
          icon: Icons.view_agenda_outlined,
          label: profile.presentationProfile.label,
        ),
        ProfileRegistryMetricChip(
          icon: Icons.hub_outlined,
          label: _countLabel(profile.salesChannels.length, 'channel'),
        ),
        ProfileRegistryMetricChip(
          icon: Icons.extension_outlined,
          label: _countLabel(profile.modules.length, 'module'),
        ),
        ProfileRegistryMetricChip(
          icon: Icons.bolt_outlined,
          label: _countLabel(profile.actionRules.length, 'rule'),
        ),
        ProfileRegistryMetricChip(
          icon: Icons.workspace_premium_outlined,
          label: _countLabel(profile.capabilities.length, 'capability'),
        ),
      ],
    );
  }
}

class ProfileRegistryChipSection extends StatelessWidget {
  const ProfileRegistryChipSection({
    required this.title,
    required this.values,
    required this.maxVisible,
    required this.chipKeyPrefix,
    super.key,
  });

  final String title;
  final Iterable<String> values;
  final int maxVisible;
  final String chipKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleValues = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final visibleCount = maxVisible.clamp(0, visibleValues.length);
    final hiddenCount = visibleValues.length - visibleCount;

    if (visibleValues.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in visibleValues.take(visibleCount))
              ProfileRegistryTextChip(
                key: ValueKey('$chipKeyPrefix:$value'),
                label: _humanizeToken(value),
              ),
            if (hiddenCount > 0)
              ProfileRegistryTextChip(label: '+$hiddenCount more'),
          ],
        ),
      ],
    );
  }
}

String _countLabel(int count, String singular) {
  if (count == 1) return '$count $singular';

  final plural =
      singular.endsWith('y')
          ? '${singular.substring(0, singular.length - 1)}ies'
          : '${singular}s';

  return '$count $plural';
}

String _humanizeToken(String value) {
  final words = value
      .trim()
      .split(RegExp(r'[_\-\s]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) return value.trim();

  return words.map(_titleCaseWord).join(' ');
}

String _titleCaseWord(String word) {
  if (word.isEmpty) return word;

  return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}
