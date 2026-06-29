import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_summary.dart';

class DashboardActionMetadataWrap extends StatelessWidget {
  final DashboardActionRecommendation item;
  final bool ownerSelected;
  final ValueChanged<String>? onOwnerSelected;
  final VoidCallback? onOwnerCleared;

  const DashboardActionMetadataWrap({
    super.key,
    required this.item,
    this.ownerSelected = false,
    this.onOwnerSelected,
    this.onOwnerCleared,
  });

  @override
  Widget build(BuildContext context) {
    final ownerCanClear = ownerSelected && onOwnerCleared != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DashboardActionMetadataChip(
          icon: Icons.account_circle_outlined,
          label: item.ownerLabel,
          selected: ownerSelected,
          tooltip:
              ownerSelected
                  ? ownerCanClear
                      ? 'Clear ${item.ownerLabel} owner focus'
                      : '${item.ownerLabel} owner focus active'
                  : 'Focus ${item.ownerLabel}',
          onPressed:
              ownerCanClear
                  ? onOwnerCleared
                  : onOwnerSelected == null
                  ? null
                  : () => onOwnerSelected!(item.ownerLabel),
        ),
        _DashboardActionMetadataChip(
          icon: Icons.event_available_outlined,
          label: item.dueLabel,
        ),
      ],
    );
  }
}

class _DashboardActionMetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final String? tooltip;
  final VoidCallback? onPressed;

  const _DashboardActionMetadataChip({
    required this.icon,
    required this.label,
    this.selected = false,
    this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? HrisColors.primary : HrisColors.muted;
    final content = Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color:
            selected
                ? HrisColors.primary.withValues(alpha: 0.08)
                : HrisColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              selected
                  ? HrisColors.primary.withValues(alpha: 0.26)
                  : HrisColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 5),
            const Icon(
              Icons.check_rounded,
              size: 14,
              color: HrisColors.primary,
            ),
          ],
        ],
      ),
    );

    if (onPressed == null) {
      return content;
    }

    return Tooltip(
      message: tooltip ?? label,
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onPressed, child: content),
        ),
      ),
    );
  }
}
