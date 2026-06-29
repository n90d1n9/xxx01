import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_summary.dart';

class DashboardActionPriorityPill extends StatelessWidget {
  final DashboardActionPriority priority;
  final Color color;
  final bool selected;
  final ValueChanged<DashboardActionPriority>? onSelected;
  final VoidCallback? onClearSelected;

  const DashboardActionPriorityPill({
    super.key,
    required this.priority,
    required this.color,
    this.selected = false,
    this.onSelected,
    this.onClearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final onTap = _tapAction();
    final pill = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border:
            selected
                ? Border.all(color: color.withValues(alpha: 0.38), width: 1.2)
                : null,
      ),
      child: HrisStatusPill(label: priority.label, color: color),
    );

    if (onTap == null && !selected) {
      return pill;
    }

    return Tooltip(
      message: _tooltipFor(canTap: onTap != null),
      child: Semantics(
        button: onTap != null,
        enabled: onTap != null,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onTap, child: pill),
        ),
      ),
    );
  }

  VoidCallback? _tapAction() {
    if (selected) {
      return onClearSelected;
    }

    if (onSelected == null) {
      return null;
    }

    return () => onSelected!(priority);
  }

  String _tooltipFor({required bool canTap}) {
    if (!selected) {
      return 'Focus ${priority.label} priority';
    }

    if (canTap) {
      return 'Clear ${priority.label} priority focus';
    }

    return '${priority.label} priority focus active';
  }
}
