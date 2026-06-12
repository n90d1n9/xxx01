import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_header_action_presentation_service.dart';

void main() {
  group('ganttChartHeaderActionPresentations', () {
    test('describes expanded header actions', () {
      final actions = ganttChartHeaderActionPresentations(
        controlsExpanded: true,
        canUndoLastEdit: true,
      );

      expect(actions.map((action) => action.role), [
        GanttChartHeaderActionRole.toggleControls,
        GanttChartHeaderActionRole.undoEdit,
        GanttChartHeaderActionRole.viewSettings,
        GanttChartHeaderActionRole.dashboard,
      ]);
      expect(actions.first.label, 'Hide Controls');
      expect(actions.first.tooltip, 'Hide Controls');
      expect(actions.first.icon, Icons.keyboard_arrow_up_rounded);
      expect(actions.first.enabled, isTrue);
      expect(actions[1].label, 'Undo Edit');
      expect(actions[1].enabled, isTrue);
    });

    test('describes collapsed and disabled states', () {
      final actions = ganttChartHeaderActionPresentations(
        controlsExpanded: false,
        canUndoLastEdit: false,
      );

      expect(actions.first.label, 'Show Controls');
      expect(actions.first.icon, Icons.tune_outlined);
      expect(actions[1].label, 'Undo Edit');
      expect(actions[1].enabled, isFalse);
      expect(actions[2].key, ganttHeaderViewSettingsButtonKey);
      expect(actions[3].icon, Icons.space_dashboard_outlined);
    });
  });
}
