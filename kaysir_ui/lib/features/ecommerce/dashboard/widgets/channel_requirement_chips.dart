import 'package:flutter/material.dart';

import '../models/channel_requirement.dart';
import 'chip_tone.dart';
import 'icon_label_chip.dart';
import 'text_badge.dart';
import 'tone.dart';

class ChannelRequirementChips extends StatelessWidget {
  final List<ChannelCoverageRequirement> requirements;
  final int? maxVisible;

  const ChannelRequirementChips({
    super.key,
    required this.requirements,
    this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (requirements.isEmpty) return const SizedBox.shrink();

    final visibleCount =
        maxVisible == null
            ? requirements.length
            : maxVisible!.clamp(0, requirements.length);
    final hiddenCount = requirements.length - visibleCount;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...requirements
            .take(visibleCount)
            .map(
              (requirement) => ChannelRequirementChip(requirement: requirement),
            ),
        if (hiddenCount > 0)
          _ChannelRequirementOverflowChip(hiddenCount: hiddenCount),
      ],
    );
  }
}

class ChannelRequirementChip extends StatelessWidget {
  final ChannelCoverageRequirement requirement;

  const ChannelRequirementChip({super.key, required this.requirement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tonalChipColors(theme.colorScheme, VisualTone.success);

    return IconLabelChip(
      key: ValueKey('channel_requirement_${requirement.id}'),
      icon: _iconForRequirement(requirement.type),
      label: requirement.label,
      colors: colors,
    );
  }
}

class _ChannelRequirementOverflowChip extends StatelessWidget {
  final int hiddenCount;

  const _ChannelRequirementOverflowChip({required this.hiddenCount});

  @override
  Widget build(BuildContext context) {
    final colors = mutedChipColors(Theme.of(context));

    return TextBadge(
      label: '+$hiddenCount rules',
      colors: colors,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
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
