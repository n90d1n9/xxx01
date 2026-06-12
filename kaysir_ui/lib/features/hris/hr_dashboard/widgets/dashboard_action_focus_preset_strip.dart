import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_focus_preset.dart';
import '../models/dashboard_action_owner_summary.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_action_urgency.dart';
import 'dashboard_action_focus_preset_button.dart';

class DashboardActionFocusPresetStrip extends StatelessWidget {
  final List<DashboardActionFocusPreset> presets;
  final ValueChanged<bool>? onHideCompletedChanged;
  final ValueChanged<String>? onOwnerChanged;
  final ValueChanged<DashboardActionPriority?>? onPriorityChanged;
  final ValueChanged<DashboardActionUrgencyTier?>? onUrgencyChanged;

  const DashboardActionFocusPresetStrip({
    super.key,
    required this.presets,
    this.onHideCompletedChanged,
    this.onOwnerChanged,
    this.onPriorityChanged,
    this.onUrgencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final visiblePresets = presets.where(_hasControlFor).toList();
    if (visiblePresets.isEmpty) {
      return const SizedBox.shrink();
    }

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: HrisColors.primary),
              const SizedBox(width: 8),
              Text(
                'Focus presets',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in visiblePresets)
                DashboardActionFocusPresetButton(
                  preset: preset,
                  enabled: _isEnabled(preset),
                  tooltip: _tooltipFor(preset),
                  onPressed: () => _applyPreset(preset),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasControlFor(DashboardActionFocusPreset preset) {
    return switch (preset.kind) {
      DashboardActionFocusPresetKind.dueNow => onUrgencyChanged != null,
      DashboardActionFocusPresetKind.highPriority => onPriorityChanged != null,
      DashboardActionFocusPresetKind.topOwner => onOwnerChanged != null,
      DashboardActionFocusPresetKind.activeWork =>
        onHideCompletedChanged != null,
      DashboardActionFocusPresetKind.clearQueue =>
        onHideCompletedChanged != null ||
            onUrgencyChanged != null ||
            onPriorityChanged != null ||
            onOwnerChanged != null,
    };
  }

  bool _isEnabled(DashboardActionFocusPreset preset) {
    return _hasControlFor(preset) && preset.hasActions;
  }

  void _applyPreset(DashboardActionFocusPreset preset) {
    switch (preset.kind) {
      case DashboardActionFocusPresetKind.dueNow:
        onUrgencyChanged?.call(preset.selected ? null : preset.urgency);
      case DashboardActionFocusPresetKind.highPriority:
        onPriorityChanged?.call(preset.selected ? null : preset.priority);
      case DashboardActionFocusPresetKind.topOwner:
        onOwnerChanged?.call(
          preset.selected
              ? dashboardActionAllOwners
              : preset.ownerLabel ?? dashboardActionAllOwners,
        );
      case DashboardActionFocusPresetKind.activeWork:
        onHideCompletedChanged?.call(!preset.selected);
      case DashboardActionFocusPresetKind.clearQueue:
        onHideCompletedChanged?.call(false);
        onUrgencyChanged?.call(null);
        onPriorityChanged?.call(null);
        onOwnerChanged?.call(dashboardActionAllOwners);
    }
  }

  String _tooltipFor(DashboardActionFocusPreset preset) {
    if (!_isEnabled(preset)) {
      return 'No ${preset.label.toLowerCase()} actions';
    }

    return switch (preset.kind) {
      DashboardActionFocusPresetKind.dueNow =>
        preset.selected ? 'Clear Due now preset' : 'Apply Due now preset',
      DashboardActionFocusPresetKind.highPriority =>
        preset.selected
            ? 'Clear High priority preset'
            : 'Apply High priority preset',
      DashboardActionFocusPresetKind.topOwner =>
        preset.selected
            ? 'Clear ${preset.ownerLabel} owner preset'
            : 'Apply ${preset.ownerLabel} owner preset',
      DashboardActionFocusPresetKind.activeWork =>
        preset.selected
            ? 'Show completed from preset'
            : 'Apply Active work preset',
      DashboardActionFocusPresetKind.clearQueue =>
        'Clear all action queue focus',
    };
  }
}
