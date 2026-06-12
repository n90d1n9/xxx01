import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_tree_control_summary_service.dart';

void main() {
  group('GanttTreeControlSummaryService', () {
    const service = GanttTreeControlSummaryService();

    test('summarizes a fully expanded tree', () {
      final summary = service.summaryFor(branchCount: 4, collapsedCount: 0);

      expect(summary.branchCount, 4);
      expect(summary.collapsedCount, 0);
      expect(summary.state, GanttTreeCollapseState.expanded);
      expect(summary.countLabel, '0 of 4 collapsed');
      expect(summary.stateLabel, 'Expanded');
      expect(summary.percentLabel, '0% hidden');
      expect(summary.canCollapseAll, isTrue);
      expect(summary.canExpandAll, isFalse);
      expect(summary.collapseActionTooltip, 'Collapse all visible branches');
      expect(
        summary.expandActionTooltip,
        'All visible branches are already expanded',
      );
      expect(summary.tooltip, 'All visible branches are expanded');
    });

    test('summarizes a partially collapsed tree', () {
      final summary = service.summaryFor(branchCount: 4, collapsedCount: 2);

      expect(summary.state, GanttTreeCollapseState.mixed);
      expect(summary.countLabel, '2 of 4 collapsed');
      expect(summary.stateLabel, 'Mixed');
      expect(summary.percentLabel, '50% hidden');
      expect(summary.canCollapseAll, isTrue);
      expect(summary.canExpandAll, isTrue);
      expect(summary.collapseActionTooltip, 'Collapse all visible branches');
      expect(summary.expandActionTooltip, 'Expand all visible branches');
      expect(summary.tooltip, '2 of 4 collapsed across visible branches');
    });

    test('summarizes and clamps fully collapsed trees', () {
      final summary = service.summaryFor(branchCount: 3, collapsedCount: 8);

      expect(summary.branchCount, 3);
      expect(summary.collapsedCount, 3);
      expect(summary.state, GanttTreeCollapseState.collapsed);
      expect(summary.countLabel, '3 of 3 collapsed');
      expect(summary.percentLabel, '100% hidden');
      expect(summary.canCollapseAll, isFalse);
      expect(summary.canExpandAll, isTrue);
      expect(
        summary.collapseActionTooltip,
        'All visible branches are already collapsed',
      );
      expect(summary.expandActionTooltip, 'Expand all visible branches');
      expect(summary.tooltip, 'All visible branches are collapsed');
    });

    test('normalizes empty or invalid trees', () {
      final summary = service.summaryFor(branchCount: -1, collapsedCount: 2);

      expect(summary.branchCount, 0);
      expect(summary.collapsedCount, 0);
      expect(summary.state, GanttTreeCollapseState.expanded);
      expect(summary.countLabel, '0 of 0 collapsed');
      expect(summary.percentLabel, '0% hidden');
      expect(summary.canCollapseAll, isFalse);
      expect(summary.canExpandAll, isFalse);
    });
  });
}
