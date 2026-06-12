import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_active_focus_bar_presentation_service.dart';

void main() {
  group('GanttActiveFocusBarPresentationService', () {
    const service = GanttActiveFocusBarPresentationService();

    test('describes active focus layout and header', () {
      const layout = GanttActiveFocusBarPresentationService.layout;
      const header = GanttActiveFocusBarPresentationService.header;

      expect(layout.topPadding, 12);
      expect(layout.spacing, 10);
      expect(layout.runSpacing, 10);
      expect(header.title, 'Active focus');
      expect(header.icon, Icons.filter_alt_outlined);
      expect(header.minWidth, 170);
      expect(header.maxWidth, 260);
    });

    test('describes clearable focus chip metadata', () {
      final project = service.chipPresentationFor(
        GanttActiveFocusChipRole.project,
      );
      final branch = service.chipPresentationFor(
        GanttActiveFocusChipRole.branch,
      );
      final query = service.chipPresentationFor(GanttActiveFocusChipRole.query);

      expect(project.icon, Icons.workspaces_outline);
      expect(project.maxWidth, 240);
      expect(project.clearButtonKey, ganttActiveFocusClearProjectButtonKey);
      expect(project.clearTooltip, 'Clear project focus');

      expect(branch.icon, Icons.account_tree_outlined);
      expect(branch.accent, GanttActiveFocusChipAccent.secondary);
      expect(branch.clearButtonKey, ganttActiveFocusClearBranchButtonKey);

      expect(query.icon, Icons.search);
      expect(query.maxWidth, 220);
      expect(query.clearTooltip, 'Clear search');
    });

    test('resolves colors for fixed and custom accents', () {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
      final result = service.chipPresentationFor(
        GanttActiveFocusChipRole.result,
      );
      final risk = service.chipPresentationFor(
        GanttActiveFocusChipRole.branchRisk,
      );
      final status = service.chipPresentationFor(
        GanttActiveFocusChipRole.status,
      );

      expect(result.colorFor(colorScheme), colorScheme.primary);
      expect(risk.colorFor(colorScheme), colorScheme.error);
      expect(
        status.colorFor(colorScheme, customColor: Colors.orange),
        Colors.orange,
      );
      expect(status.clearButtonKey, ganttActiveFocusClearStatusButtonKey);
    });
  });
}
