import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_focus_state.dart';
import '../models/dashboard_action_urgency.dart';

class DashboardActionFocusChips extends StatelessWidget {
  final DashboardActionFocusState focus;
  final VoidCallback? onClearHideCompleted;
  final VoidCallback? onClearUrgency;
  final VoidCallback? onClearPriority;
  final VoidCallback? onClearOwner;

  const DashboardActionFocusChips({
    super.key,
    required this.focus,
    this.onClearHideCompleted,
    this.onClearUrgency,
    this.onClearPriority,
    this.onClearOwner,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = [
      if (focus.hideCompleted)
        _FocusToken(
          label: 'Done hidden',
          onClear: onClearHideCompleted,
          clearTooltip: 'Show done actions',
        ),
      if (focus.hasUrgencyFocus)
        _FocusToken(
          label: 'Urgency: ${dashboardActionUrgencyLabel(focus.urgency!)}',
          onClear: onClearUrgency,
          clearTooltip: 'Clear urgency focus',
        ),
      if (focus.hasPriorityFocus)
        _FocusToken(
          label: 'Priority: ${focus.priority!.label}',
          onClear: onClearPriority,
          clearTooltip: 'Clear priority focus',
        ),
      if (focus.hasOwnerFocus)
        _FocusToken(
          label: 'Owner: ${focus.ownerLabel}',
          onClear: onClearOwner,
          clearTooltip: 'Clear owner focus',
        ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          tokens
              .map(
                (token) => DashboardActionFocusChip(
                  label: token.label,
                  onClear: token.onClear,
                  clearTooltip: token.clearTooltip,
                ),
              )
              .toList(),
    );
  }
}

class DashboardActionFocusChip extends StatelessWidget {
  final String label;
  final VoidCallback? onClear;
  final String clearTooltip;

  const DashboardActionFocusChip({
    super.key,
    required this.label,
    required this.onClear,
    required this.clearTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label, overflow: TextOverflow.ellipsis),
      onDeleted: onClear,
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      deleteButtonTooltipMessage: clearTooltip,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: HrisColors.surface,
      side: const BorderSide(color: HrisColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: HrisColors.ink,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FocusToken {
  final String label;
  final VoidCallback? onClear;
  final String clearTooltip;

  const _FocusToken({
    required this.label,
    required this.onClear,
    required this.clearTooltip,
  });
}
