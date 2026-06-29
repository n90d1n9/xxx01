import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_urgency.dart';
import '../models/dashboard_action_urgency_summary.dart';
import 'dashboard_action_urgency_style.dart';

class DashboardActionUrgencyFilter extends StatelessWidget {
  final List<DashboardActionUrgencySummary> urgencies;
  final DashboardActionUrgencyTier? selectedUrgency;
  final ValueChanged<DashboardActionUrgencyTier?> onChanged;

  const DashboardActionUrgencyFilter({
    super.key,
    required this.urgencies,
    required this.selectedUrgency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = urgencies.fold<int>(
      0,
      (total, urgency) => total + urgency.totalCount,
    );

    return HrisListSurface(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _UrgencyFilterLabel(),
          ChoiceChip(
            avatar: const Icon(Icons.radar_outlined, size: 18),
            label: Text('$dashboardActionAllUrgencies ($totalCount)'),
            selected: selectedUrgency == null,
            onSelected: (_) => onChanged(null),
          ),
          ...urgencies.map(
            (summary) => ChoiceChip(
              avatar: Icon(
                dashboardActionUrgencyIcon(summary.tier),
                size: 18,
                color: dashboardActionUrgencyColor(summary.tier),
              ),
              label: Text('${summary.label} (${summary.totalCount})'),
              selected: selectedUrgency == summary.tier,
              onSelected: (_) => onChanged(summary.tier),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyFilterLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 116),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar_outlined, size: 18, color: HrisColors.primary),
          const SizedBox(width: 8),
          Text(
            'Urgency focus',
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
