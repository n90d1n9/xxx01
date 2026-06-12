import 'gantt_chart_quick_preset_presentation_service.dart';
import 'gantt_chart_quick_preset_service.dart';

/// User-facing copy for a Gantt quick preset summary.
class GanttChartQuickPresetSummary {
  const GanttChartQuickPresetSummary({
    required this.preset,
    required this.subtitle,
    required this.intentLabel,
    required this.emphasisLabel,
    required this.detailLabel,
    required this.tooltip,
  });

  final GanttChartQuickPreset preset;
  final String subtitle;
  final String intentLabel;
  final String emphasisLabel;
  final String detailLabel;
  final String tooltip;
}

/// Builds dynamic quick preset summaries for expanded and compact controls.
class GanttChartQuickPresetSummaryService {
  const GanttChartQuickPresetSummaryService();

  GanttChartQuickPresetSummary summaryFor(
    GanttChartQuickPreset preset, {
    bool showLensSummary = true,
  }) {
    switch (preset) {
      case GanttChartQuickPreset.risk:
        return GanttChartQuickPresetSummary(
          preset: preset,
          subtitle: _subtitleFor(
            preset,
            lensLabel: 'Dependency Watch, Attention Window',
            showLensSummary: showLensSummary,
          ),
          intentLabel: 'Risk review',
          emphasisLabel: 'Links + guard badges',
          detailLabel: 'Dependency lines, conflict badges, cozy rows',
          tooltip: ganttChartQuickPresetPresentation(preset).tooltip,
        );
      case GanttChartQuickPreset.team:
        return GanttChartQuickPresetSummary(
          preset: preset,
          subtitle: _subtitleFor(
            preset,
            lensLabel: 'Active Now, Next 90 Days',
            showLensSummary: showLensSummary,
          ),
          intentLabel: 'Team execution',
          emphasisLabel: 'Avatars + progress',
          detailLabel: 'Team avatars, status labels, wide timeline',
          tooltip: ganttChartQuickPresetPresentation(preset).tooltip,
        );
      case GanttChartQuickPreset.milestones:
        return GanttChartQuickPresetSummary(
          preset: preset,
          subtitle: _subtitleFor(
            preset,
            lensLabel: 'All Tasks, Project Span',
            showLensSummary: showLensSummary,
          ),
          intentLabel: 'Roadmap scan',
          emphasisLabel: 'Milestones + open scale',
          detailLabel: 'Milestone labels, dense rows, fewer bar details',
          tooltip: ganttChartQuickPresetPresentation(preset).tooltip,
        );
      case GanttChartQuickPreset.custom:
        return GanttChartQuickPresetSummary(
          preset: GanttChartQuickPreset.custom,
          subtitle: 'Custom setup',
          intentLabel: 'Manual setup',
          emphasisLabel: 'Custom controls',
          detailLabel: 'Current display controls define this focus',
          tooltip: ganttChartQuickPresetPresentation(preset).tooltip,
        );
    }
  }

  String _subtitleFor(
    GanttChartQuickPreset preset, {
    required String lensLabel,
    required bool showLensSummary,
  }) {
    final label = ganttChartQuickPresetPresentation(preset).label;
    if (!showLensSummary) return '$label setup';

    return '$label: $lensLabel';
  }
}
