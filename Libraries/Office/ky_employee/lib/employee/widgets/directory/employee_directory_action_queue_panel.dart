import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_action_models.dart';
import 'employee_directory_action_queue_tiles.dart';

class EmployeeDirectoryActionQueuePanel extends StatelessWidget {
  final EmployeeDirectoryActionQueueSummary summary;
  final List<EmployeeDirectoryActionItem> actions;
  final ValueChanged<EmployeeDirectoryActionItem> onAssign;
  final ValueChanged<EmployeeDirectoryActionItem> onStart;
  final ValueChanged<EmployeeDirectoryActionItem> onResolve;
  final ValueChanged<EmployeeDirectoryActionItem> onSnooze;

  const EmployeeDirectoryActionQueuePanel({
    super.key,
    required this.summary,
    required this.actions,
    required this.onAssign,
    required this.onStart,
    required this.onResolve,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-action-queue-panel'),
      icon: Icons.assignment_turned_in_outlined,
      title: 'HR action queue',
      subtitle: '${summary.openCount} open actions from visible employees',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Open', value: '${summary.openCount}'),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
            HrisMetricStripItem(
              label: 'Resolved',
              value: '${summary.resolvedCount}',
            ),
          ],
        ),
        if (actions.isEmpty)
          const HrisEmptyState(message: 'No HR actions for this table view')
        else
          ...actions.map(
            (action) => EmployeeDirectoryActionQueueTile(
              key: ValueKey('employee-directory-action-${action.id}'),
              action: action,
              onAssign: onAssign,
              onStart: onStart,
              onResolve: onResolve,
              onSnooze: onSnooze,
            ),
          ),
      ],
    );
  }
}
