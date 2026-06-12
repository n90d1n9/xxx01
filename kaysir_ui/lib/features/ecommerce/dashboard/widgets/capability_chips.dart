import 'package:flutter/material.dart';

import '../models/product_profile.dart';
import 'chip_tone.dart';
import 'text_badge.dart';
import 'tone.dart';

class CapabilityChips extends StatelessWidget {
  final List<ProductCapability> capabilities;
  final int? maxVisible;

  const CapabilityChips({
    super.key,
    required this.capabilities,
    this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (capabilities.isEmpty) return const SizedBox.shrink();

    final visibleCount =
        maxVisible == null
            ? capabilities.length
            : maxVisible!.clamp(0, capabilities.length);
    final hiddenCount = capabilities.length - visibleCount;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...capabilities
            .take(visibleCount)
            .map((capability) => CapabilityChip(capability: capability)),
        if (hiddenCount > 0) _CapabilityOverflowChip(hiddenCount: hiddenCount),
      ],
    );
  }
}

class CapabilityChip extends StatelessWidget {
  final ProductCapability capability;

  const CapabilityChip({super.key, required this.capability});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tonalChipColors(theme.colorScheme, VisualTone.primary);

    return TextBadge(
      key: ValueKey('capability_${capability.name}'),
      label: capability.label,
      colors: colors,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}

class _CapabilityOverflowChip extends StatelessWidget {
  final int hiddenCount;

  const _CapabilityOverflowChip({required this.hiddenCount});

  @override
  Widget build(BuildContext context) {
    final colors = mutedChipColors(Theme.of(context));

    return TextBadge(
      label: '+$hiddenCount more',
      colors: colors,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}
