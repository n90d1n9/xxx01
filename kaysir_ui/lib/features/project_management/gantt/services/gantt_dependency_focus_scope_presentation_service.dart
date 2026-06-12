import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

class GanttDependencyFocusScopePresentation {
  const GanttDependencyFocusScopePresentation({
    required this.scope,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
    required this.icon,
  });

  final ky.KyGanttDependencyLineFocusScope scope;
  final String label;
  final String summaryLabel;
  final String tooltip;
  final IconData icon;
}

const ganttDependencyFocusScopePresentations = [
  GanttDependencyFocusScopePresentation(
    scope: ky.KyGanttDependencyLineFocusScope.direct,
    label: 'Direct',
    summaryLabel: 'Direct deps',
    tooltip: 'Highlights direct predecessor and successor links',
    icon: Icons.call_split_outlined,
  ),
  GanttDependencyFocusScopePresentation(
    scope: ky.KyGanttDependencyLineFocusScope.upstream,
    label: 'Up',
    summaryLabel: 'Upstream deps',
    tooltip: 'Highlights the upstream chain feeding the selected task',
    icon: Icons.subdirectory_arrow_left_outlined,
  ),
  GanttDependencyFocusScopePresentation(
    scope: ky.KyGanttDependencyLineFocusScope.downstream,
    label: 'Down',
    summaryLabel: 'Downstream deps',
    tooltip: 'Highlights downstream work impacted by the selected task',
    icon: Icons.subdirectory_arrow_right_outlined,
  ),
  GanttDependencyFocusScopePresentation(
    scope: ky.KyGanttDependencyLineFocusScope.chain,
    label: 'Full',
    summaryLabel: 'Full deps',
    tooltip: 'Highlights upstream and downstream dependency chains',
    icon: Icons.route_outlined,
  ),
];

GanttDependencyFocusScopePresentation ganttDependencyFocusScopePresentation(
  ky.KyGanttDependencyLineFocusScope scope,
) {
  return switch (scope) {
    ky.KyGanttDependencyLineFocusScope.direct =>
      ganttDependencyFocusScopePresentations[0],
    ky.KyGanttDependencyLineFocusScope.upstream =>
      ganttDependencyFocusScopePresentations[1],
    ky.KyGanttDependencyLineFocusScope.downstream =>
      ganttDependencyFocusScopePresentations[2],
    ky.KyGanttDependencyLineFocusScope.chain =>
      ganttDependencyFocusScopePresentations[3],
  };
}
