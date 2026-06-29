import 'package:flutter/material.dart';

import '../models/dashboard_action_urgency.dart';
import 'dashboard_action_urgency_style.dart';

class DashboardActionUrgencyChip extends StatelessWidget {
  final DashboardActionUrgency urgency;
  final bool selected;
  final ValueChanged<DashboardActionUrgencyTier>? onSelected;
  final VoidCallback? onClearSelected;

  const DashboardActionUrgencyChip({
    super.key,
    required this.urgency,
    this.selected = false,
    this.onSelected,
    this.onClearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = dashboardActionUrgencyColor(urgency.tier);
    final canClear = selected && onClearSelected != null;
    final chip = Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: selected ? 0.5 : 0.28),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            dashboardActionUrgencyIcon(urgency.tier),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            urgency.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_rounded, size: 15, color: color),
          ],
        ],
      ),
    );

    if (onSelected == null && !canClear) {
      return Tooltip(message: urgency.helper, child: chip);
    }

    return Tooltip(
      message:
          selected
              ? canClear
                  ? 'Clear ${urgency.label} urgency focus'
                  : '${urgency.label} urgency focus active'
              : 'Focus ${urgency.label} urgency',
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap:
                canClear
                    ? onClearSelected
                    : onSelected == null
                    ? null
                    : () => onSelected!(urgency.tier),
            child: chip,
          ),
        ),
      ),
    );
  }
}
