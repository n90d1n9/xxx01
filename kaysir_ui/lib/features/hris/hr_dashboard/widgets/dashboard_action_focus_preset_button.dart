import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_focus_preset.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_action_urgency.dart';
import 'dashboard_action_style.dart';
import 'dashboard_action_urgency_style.dart';

class DashboardActionFocusPresetButton extends StatelessWidget {
  final DashboardActionFocusPreset preset;
  final bool enabled;
  final String tooltip;
  final VoidCallback onPressed;

  const DashboardActionFocusPresetButton({
    super.key,
    required this.preset,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(preset);
    final foreground =
        enabled || preset.selected ? HrisColors.ink : HrisColors.muted;
    final accent = enabled ? color : HrisColors.muted;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: preset.selected,
        child: Material(
          color:
              preset.selected
                  ? color.withValues(alpha: 0.09)
                  : HrisColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color:
                  preset.selected
                      ? color.withValues(alpha: 0.7)
                      : HrisColors.border,
              width: preset.selected ? 1.4 : 1,
            ),
          ),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 58,
                minWidth: 132,
                maxWidth: 176,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: enabled ? 0.12 : 0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_iconFor(preset), size: 18, color: accent),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preset.metricLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: HrisColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (preset.selected) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_circle_rounded, size: 17, color: color),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(DashboardActionFocusPreset preset) {
    return switch (preset.kind) {
      DashboardActionFocusPresetKind.dueNow => dashboardActionUrgencyIcon(
        DashboardActionUrgencyTier.now,
      ),
      DashboardActionFocusPresetKind.highPriority => Icons.flag_outlined,
      DashboardActionFocusPresetKind.topOwner => Icons.account_circle_outlined,
      DashboardActionFocusPresetKind.activeWork =>
        Icons.visibility_off_outlined,
      DashboardActionFocusPresetKind.clearQueue => Icons.restart_alt_rounded,
    };
  }

  Color _colorFor(DashboardActionFocusPreset preset) {
    return switch (preset.kind) {
      DashboardActionFocusPresetKind.dueNow => dashboardActionUrgencyColor(
        DashboardActionUrgencyTier.now,
      ),
      DashboardActionFocusPresetKind.highPriority =>
        dashboardActionPriorityColor(DashboardActionPriority.high),
      DashboardActionFocusPresetKind.topOwner => HrisColors.primary,
      DashboardActionFocusPresetKind.activeWork => const Color(0xFF0F766E),
      DashboardActionFocusPresetKind.clearQueue => HrisColors.muted,
    };
  }
}
