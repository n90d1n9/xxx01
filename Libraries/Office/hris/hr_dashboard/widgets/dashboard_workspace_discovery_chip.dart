import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class DashboardWorkspaceDiscoveryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onClear;
  final String? clearTooltip;
  final bool emphasized;

  const DashboardWorkspaceDiscoveryChip({
    super.key,
    required this.icon,
    required this.label,
    this.onClear,
    this.clearTooltip,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = emphasized ? HrisColors.primary : HrisColors.ink;
    final iconColor = emphasized ? HrisColors.primary : HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(minHeight: 34, maxWidth: 280),
      padding: EdgeInsets.only(
        left: 10,
        right: onClear == null ? 10 : 4,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color:
            emphasized
                ? HrisColors.primary.withValues(alpha: 0.08)
                : HrisColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              emphasized
                  ? HrisColors.primary.withValues(alpha: 0.16)
                  : HrisColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: clearTooltip ?? 'Clear $label',
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(Icons.close_rounded, size: 16, color: iconColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
