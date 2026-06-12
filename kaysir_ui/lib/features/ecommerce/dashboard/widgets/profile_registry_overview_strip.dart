import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/profile_registry_overview.dart';
import 'chip_tone.dart';
import 'icon_label_chip.dart';
import 'tone.dart';

class ProfileRegistryOverviewStrip extends StatelessWidget {
  final ProfileRegistryOverview overview;

  const ProfileRegistryOverviewStrip({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('profile_registry_overview_strip'),
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: [
        _RegistryOverviewMetricChip(
          icon: Icons.view_quilt_outlined,
          label: _countLabel(overview.profileCount, 'profile'),
        ),
        _RegistryOverviewMetricChip(
          icon: Icons.hub_outlined,
          label: _countLabel(overview.salesChannelCount, 'channel'),
        ),
        _RegistryOverviewMetricChip(
          icon: Icons.workspace_premium_outlined,
          label: _countLabel(overview.capabilityCount, 'capability'),
        ),
        _RegistryOverviewMetricChip(
          icon: Icons.extension_outlined,
          label: _countLabel(overview.moduleCount, 'module'),
        ),
        _RegistryOverviewMetricChip(
          icon: Icons.bolt_outlined,
          label: _countLabel(overview.actionRuleCount, 'rule'),
        ),
        _RegistryOverviewMetricChip(
          icon: Icons.manage_search_outlined,
          label: _countLabel(overview.searchKeywordCount, 'keyword'),
        ),
      ],
    );
  }
}

class _RegistryOverviewMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RegistryOverviewMetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tonalChipColors(
      theme.colorScheme,
      VisualTone.secondary,
      backgroundAlpha: 0.24,
    );

    return IconLabelChip(icon: icon, label: label, colors: colors);
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
