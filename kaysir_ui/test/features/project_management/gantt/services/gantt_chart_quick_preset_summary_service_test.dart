import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_summary_service.dart';

void main() {
  group('GanttChartQuickPresetSummaryService', () {
    const service = GanttChartQuickPresetSummaryService();

    test('describes built-in chart focus presets', () {
      final risk = service.summaryFor(GanttChartQuickPreset.risk);
      final team = service.summaryFor(GanttChartQuickPreset.team);
      final milestones = service.summaryFor(GanttChartQuickPreset.milestones);

      expect(risk.subtitle, 'Risk: Dependency Watch, Attention Window');
      expect(risk.intentLabel, 'Risk review');
      expect(risk.emphasisLabel, 'Links + guard badges');
      expect(risk.tooltip, contains('highlights blocked dependencies'));

      expect(team.subtitle, 'Team: Active Now, Next 90 Days');
      expect(team.intentLabel, 'Team execution');
      expect(team.emphasisLabel, 'Avatars + progress');
      expect(team.detailLabel, 'Team avatars, status labels, wide timeline');

      expect(milestones.subtitle, 'Milestones: All Tasks, Project Span');
      expect(milestones.intentLabel, 'Roadmap scan');
      expect(milestones.emphasisLabel, 'Milestones + open scale');
    });

    test('can hide lens text while keeping preset summaries', () {
      final team = service.summaryFor(
        GanttChartQuickPreset.team,
        showLensSummary: false,
      );
      final custom = service.summaryFor(GanttChartQuickPreset.custom);

      expect(team.subtitle, 'Team setup');
      expect(team.intentLabel, 'Team execution');
      expect(custom.subtitle, 'Custom setup');
      expect(custom.emphasisLabel, 'Custom controls');
    });
  });
}
