import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_tree_control_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_tree_control_summary_service.dart';

void main() {
  group('ganttTreeControlPresentation', () {
    test('describes collapse state visuals', () {
      final expanded = ganttTreeCollapseStatePresentation(
        GanttTreeCollapseState.expanded,
      );
      final mixed = ganttTreeCollapseStatePresentation(
        GanttTreeCollapseState.mixed,
      );
      final collapsed = ganttTreeCollapseStatePresentation(
        GanttTreeCollapseState.collapsed,
      );

      expect(expanded.icon, Icons.unfold_more_rounded);
      expect(expanded.accent, GanttTreeControlAccent.primary);
      expect(mixed.icon, Icons.tune_rounded);
      expect(mixed.accent, GanttTreeControlAccent.tertiary);
      expect(collapsed.icon, Icons.unfold_less_rounded);
      expect(collapsed.accent, GanttTreeControlAccent.secondary);
    });

    test('describes bulk action controls', () {
      final collapse = ganttTreeControlActionPresentation(
        GanttTreeControlAction.collapseAll,
      );
      final expand = ganttTreeControlActionPresentation(
        GanttTreeControlAction.expandAll,
      );

      expect(collapse.key, ganttTreeCollapseAllButtonKey);
      expect(collapse.label, 'Collapse All');
      expect(collapse.icon, Icons.unfold_less_rounded);
      expect(expand.key, ganttTreeExpandAllButtonKey);
      expect(expand.label, 'Expand All');
      expect(expand.icon, Icons.unfold_more_rounded);
    });
  });
}
