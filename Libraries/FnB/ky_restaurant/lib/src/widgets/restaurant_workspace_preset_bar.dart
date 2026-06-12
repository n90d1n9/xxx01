import 'package:flutter/material.dart';

import '../models/restaurant_workspace_preset.dart';

class RestaurantWorkspacePresetBar extends StatelessWidget {
  const RestaurantWorkspacePresetBar({
    super.key,
    required this.presets,
    required this.onPresetSelected,
    this.selectedPreset,
  });

  final List<RestaurantWorkspacePreset> presets;
  final RestaurantWorkspacePreset? selectedPreset;
  final ValueChanged<RestaurantWorkspacePreset> onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      container: true,
      label: _presetBarSemanticsLabel(selectedPreset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .65),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_motion_rounded,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick views',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in presets)
                    _RestaurantWorkspacePresetChip(
                      preset: preset,
                      selected: preset == selectedPreset,
                      onSelected: onPresetSelected,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _presetBarSemanticsLabel(RestaurantWorkspacePreset? selectedPreset) {
  final selectedLabel = selectedPreset?.label ?? 'Custom view';
  return 'Quick views. Selected $selectedLabel.';
}

class _RestaurantWorkspacePresetChip extends StatelessWidget {
  const _RestaurantWorkspacePresetChip({
    required this.preset,
    required this.selected,
    required this.onSelected,
  });

  final RestaurantWorkspacePreset preset;
  final bool selected;
  final ValueChanged<RestaurantWorkspacePreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Tooltip(
      message: preset.description,
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onSelected(preset),
        avatar: Icon(
          preset.icon,
          size: 16,
          color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
        ),
        label: Text(preset.label),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
        selectedColor: colors.primaryContainer.withValues(alpha: .76),
        backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .42),
        shape: const StadiumBorder(),
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
