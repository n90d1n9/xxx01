import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_focus_state.dart';
import 'dashboard_action_focus_chips.dart';

class DashboardActionFocusSummary extends StatelessWidget {
  final DashboardActionFocusState focus;
  final VoidCallback? onClear;
  final VoidCallback? onClearHideCompleted;
  final VoidCallback? onClearUrgency;
  final VoidCallback? onClearPriority;
  final VoidCallback? onClearOwner;

  const DashboardActionFocusSummary({
    super.key,
    required this.focus,
    this.onClear,
    this.onClearHideCompleted,
    this.onClearUrgency,
    this.onClearPriority,
    this.onClearOwner,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;
          final summary = _FocusSummaryCopy(
            focus: focus,
            onClearHideCompleted: onClearHideCompleted,
            onClearUrgency: onClearUrgency,
            onClearPriority: onClearPriority,
            onClearOwner: onClearOwner,
          );
          final clearButton = TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Clear focus'),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: clearButton),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 12),
              clearButton,
            ],
          );
        },
      ),
    );
  }
}

class _FocusSummaryCopy extends StatelessWidget {
  final DashboardActionFocusState focus;
  final VoidCallback? onClearHideCompleted;
  final VoidCallback? onClearUrgency;
  final VoidCallback? onClearPriority;
  final VoidCallback? onClearOwner;

  const _FocusSummaryCopy({
    required this.focus,
    this.onClearHideCompleted,
    this.onClearUrgency,
    this.onClearPriority,
    this.onClearOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: HrisColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.filter_alt_outlined,
            color: HrisColors.primary,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus applied',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                focus.resultLabel,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 8),
              DashboardActionFocusChips(
                focus: focus,
                onClearHideCompleted: onClearHideCompleted,
                onClearUrgency: onClearUrgency,
                onClearPriority: onClearPriority,
                onClearOwner: onClearOwner,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
