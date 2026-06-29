import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class DashboardActionVisibilityToggle extends StatelessWidget {
  final bool hideCompleted;
  final ValueChanged<bool>? onChanged;

  const DashboardActionVisibilityToggle({
    super.key,
    required this.hideCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hideCompleted
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
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
                  'Hide done',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Focus the queue on open and active work',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Hide completed actions',
            child: Switch(value: hideCompleted, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
