import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_scenario_service.dart';
import '../services/project_finance_workspace_service.dart';

/// Budget scenario planning panel for project finance forecast decisions.
class ProjectFinanceScenarioPanel extends StatefulWidget {
  const ProjectFinanceScenarioPanel({required this.summary, super.key});

  final ProjectFinanceWorkspaceSummary summary;

  @override
  State<ProjectFinanceScenarioPanel> createState() =>
      _ProjectFinanceScenarioPanelState();
}

/// Stores selected scenario lens separately from scenario calculations.
class _ProjectFinanceScenarioPanelState
    extends State<ProjectFinanceScenarioPanel> {
  ProjectFinanceScenarioKind? _selectedKind;

  @override
  Widget build(BuildContext context) {
    final scenarioSummary = buildProjectFinanceScenarioSummary(widget.summary);
    final selectedScenario = _selectedScenario(scenarioSummary);
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = scenarioSummary.recommendedOption.level.color(
      colorScheme,
    );
    final selectedColor = selectedScenario.level.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: scenarioSummary.title,
          subtitle: scenarioSummary.detail,
          icon: scenarioSummary.recommendedOption.kind.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: levelColor.withValues(alpha: 0.12),
          iconForegroundColor: levelColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: scenarioSummary.recommendedOption.level.label,
            icon: scenarioSummary.recommendedOption.level.icon,
            color: levelColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Projected',
              value: '${selectedScenario.projectedAtCompletionPercent}%',
              icon: Icons.query_stats_outlined,
              accentColor: selectedColor,
              helper: 'At completion',
            ),
            AppMetricGridItem(
              title: 'Budget Gap',
              value: selectedScenario.budgetDeltaLabel,
              icon: Icons.speed_outlined,
              accentColor: selectedColor,
              helper: 'Vs baseline budget',
            ),
            AppMetricGridItem(
              title: 'Actions',
              value: selectedScenario.expectedActionCount.toString(),
              icon: Icons.pending_actions_outlined,
              accentColor:
                  selectedScenario.expectedActionCount == 0
                      ? Colors.green.shade700
                      : selectedColor,
              helper: 'Remaining actions',
            ),
            AppMetricGridItem(
              title: 'Open Ledger',
              value: selectedScenario.expectedOpenLedgerCount.toString(),
              icon: Icons.receipt_long_outlined,
              accentColor:
                  selectedScenario.expectedOpenLedgerCount == 0
                      ? Colors.green.shade700
                      : selectedColor,
              helper: 'Remaining records',
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppFilterChipGroup<ProjectFinanceScenarioKind>(
          value: selectedScenario.kind,
          options: [
            for (final option in scenarioSummary.options)
              AppFilterChipOption(
                value: option.kind,
                label: option.kind.label,
                icon: option.kind.icon,
              ),
          ],
          onChanged: (kind) => setState(() => _selectedKind = kind),
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          title: selectedScenario.title,
          subtitle:
              '${selectedScenario.detail} Release policy: ${selectedScenario.releasePolicyLabel}.',
          icon: selectedScenario.kind.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: selectedColor.withValues(alpha: 0.12),
          iconForegroundColor: selectedColor,
          titleMaxLines: 2,
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: selectedScenario.level.label,
            icon: selectedScenario.level.icon,
            color: selectedColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        for (
          var index = 0;
          index < scenarioSummary.options.length;
          index++
        ) ...[
          _ScenarioComparisonRow(option: scenarioSummary.options[index]),
          if (index != scenarioSummary.options.length - 1)
            const SizedBox(height: 10),
        ],
      ],
    );
  }

  ProjectFinanceScenarioOption _selectedScenario(
    ProjectFinanceScenarioSummary summary,
  ) {
    final selectedKind = _selectedKind ?? summary.recommendedOption.kind;
    return summary.options.firstWhere(
      (option) => option.kind == selectedKind,
      orElse: () => summary.recommendedOption,
    );
  }
}

/// Compact comparison row for one finance scenario option.
class _ScenarioComparisonRow extends StatelessWidget {
  const _ScenarioComparisonRow({required this.option});

  final ProjectFinanceScenarioOption option;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = option.level.color(colorScheme);

    return AppInfoRow(
      title: '${option.title} - ${option.projectedAtCompletionPercent}%',
      subtitle:
          '${option.budgetDeltaLabel} - ${option.expectedActionCount} actions - ${option.expectedOpenLedgerCount} open ledger records.',
      icon: option.kind.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.1),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      trailing: AppStatusPill(
        label: option.level.label,
        icon: option.level.icon,
        color: levelColor,
        maxWidth: 128,
      ),
    );
  }
}

@Preview(name: 'Project finance scenario panel')
Widget projectFinanceScenarioPanelPreview() {
  final project = const ProjectPortfolioRepository().fetchProjects().first;

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFinanceScenarioPanel(
          summary: buildProjectFinanceWorkspaceSummary(project),
        ),
      ),
    ),
  );
}
