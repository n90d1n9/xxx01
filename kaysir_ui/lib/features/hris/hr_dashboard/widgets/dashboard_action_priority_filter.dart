import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_priority_summary.dart';
import '../models/dashboard_action_summary.dart';
import 'dashboard_action_style.dart';

class DashboardActionPriorityFilter extends StatelessWidget {
  final List<DashboardActionPrioritySummary> priorities;
  final DashboardActionPriority? selectedPriority;
  final ValueChanged<DashboardActionPriority?> onChanged;

  const DashboardActionPriorityFilter({
    super.key,
    required this.priorities,
    required this.selectedPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = priorities.fold<int>(
      0,
      (total, priority) => total + priority.totalCount,
    );

    return HrisListSurface(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _PriorityFilterLabel(),
          ChoiceChip(
            avatar: const Icon(Icons.format_list_bulleted_rounded, size: 18),
            label: Text('$dashboardActionAllPriorities ($totalCount)'),
            selected: selectedPriority == null,
            onSelected: (_) => onChanged(null),
          ),
          ...priorities.map(
            (summary) => ChoiceChip(
              avatar: Icon(
                Icons.flag_outlined,
                size: 18,
                color: dashboardActionPriorityColor(summary.priority),
              ),
              label: Text('${summary.priority.label} (${summary.totalCount})'),
              selected: selectedPriority == summary.priority,
              onSelected: (_) => onChanged(summary.priority),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityFilterLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 116),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high_rounded,
            size: 18,
            color: HrisColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Priority focus',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
