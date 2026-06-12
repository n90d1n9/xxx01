import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_funding_release_service.dart';
import '../widgets/project_cash_flow_forecast_panel.dart';
import '../widgets/project_funding_release_request_intake_panel.dart';
import '../widgets/project_funding_release_panel.dart';

/// Dedicated funding release workspace for cash-flow gates and release control.
class ProjectFundingReleasesScreen extends StatefulWidget {
  const ProjectFundingReleasesScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  State<ProjectFundingReleasesScreen> createState() =>
      _ProjectFundingReleasesScreenState();
}

/// Keeps funding release project selection separate from presentation widgets.
class _ProjectFundingReleasesScreenState
    extends State<ProjectFundingReleasesScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectFundingReleasesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository == widget.repository &&
        oldWidget.initialProjectId == widget.initialProjectId) {
      return;
    }

    final projects = widget.repository.fetchProjects();
    setState(() {
      _projects = projects;
      _selectedProjectId = _resolveProjectId(
        widget.initialProjectId ?? _selectedProjectId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_projects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Funding Releases')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.waterfall_chart_outlined,
            title: 'No projects available',
            message:
                'Add a project before planning funding windows, release gates, reserve controls, and cash-flow evidence.',
          ),
        ),
      );
    }

    final project = _selectedProject;
    final financeSummary = buildProjectFinanceWorkspaceSummary(project);
    final fundingSummary = buildProjectFundingReleaseSummary(financeSummary);

    return Scaffold(
      appBar: AppBar(title: const Text('Project Funding Releases')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectFundingReleasesHeader(
                    project: project,
                    projects: _projects,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Funding Release Request Flow',
                    subtitle:
                        'Queue release requests with owner, amount, gate condition, evidence, and release window',
                    leadingIcon: Icons.playlist_add_check_outlined,
                    child: ProjectFundingReleaseRequestIntakePanel(
                      summary: fundingSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Funding Release Board',
                    subtitle:
                        'Cash movement gates, authority checks, reserve guardrails, and release evidence',
                    leadingIcon: Icons.waterfall_chart_outlined,
                    child: ProjectFundingReleasePanel(summary: fundingSummary),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Cash Flow Forecast',
                    subtitle:
                        'Funding windows, release gates, and reserve runway',
                    leadingIcon: Icons.query_stats_outlined,
                    child: ProjectCashFlowForecastPanel(
                      summary: financeSummary.cashFlowForecast,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ProjectPortfolioItem get _selectedProject {
    return _projects.firstWhere(
      (project) => project.id == _selectedProjectId,
      orElse: () => _projects.first,
    );
  }

  String? _resolveProjectId(String? preferredProjectId) {
    final normalizedProjectId = preferredProjectId?.trim();
    if (normalizedProjectId != null &&
        normalizedProjectId.isNotEmpty &&
        _projects.any((project) => project.id == normalizedProjectId)) {
      return normalizedProjectId;
    }

    return _projects.isEmpty ? null : _projects.first.id;
  }
}

/// Header for selecting the funding release project context.
class _ProjectFundingReleasesHeader extends StatelessWidget {
  const _ProjectFundingReleasesHeader({
    required this.project,
    required this.projects,
    required this.onProjectChanged,
  });

  final ProjectPortfolioItem project;
  final List<ProjectPortfolioItem> projects;
  final ValueChanged<String> onProjectChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: AppTextCluster(
            eyebrow: 'Project Management',
            title: 'Project Funding Releases',
            subtitle:
                '${project.name} funding release workspace for cash-flow gates, authority checks, reserve guardrails, and release evidence.',
            titleStyle: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            subtitleMaxLines: 3,
          ),
        ),
        AppSelectField<String>(
          label: 'Project',
          value: project.id,
          width: 300,
          icon: Icons.work_outline_rounded,
          menuMaxHeight: 320,
          options: [
            for (final option in projects)
              AppSelectOption(value: option.id, label: option.name),
          ],
          onChanged: onProjectChanged,
        ),
      ],
    );
  }
}

@Preview(name: 'Project funding releases screen')
Widget projectFundingReleasesScreenPreview() {
  return const MaterialApp(
    home: ProjectFundingReleasesScreen(
      initialProjectId: 'warehouse-automation',
    ),
  );
}
