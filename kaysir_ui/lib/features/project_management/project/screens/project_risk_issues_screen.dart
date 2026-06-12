import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_risk_issue_workspace_service.dart';
import '../widgets/project_risk_issue_workspace_panel.dart';
import '../widgets/project_risk_response_flow_panel.dart';

/// Dedicated risk and issue workspace for project recovery triage.
class ProjectRiskIssuesScreen extends StatefulWidget {
  const ProjectRiskIssuesScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  State<ProjectRiskIssuesScreen> createState() =>
      _ProjectRiskIssuesScreenState();
}

/// Keeps risk workspace project selection separate from risk presentation.
class _ProjectRiskIssuesScreenState extends State<ProjectRiskIssuesScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectRiskIssuesScreen oldWidget) {
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
        appBar: AppBar(title: const Text('Project Risk & Issues')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.health_and_safety_outlined,
            title: 'No projects available',
            message:
                'Add a project before triaging blockers, delivery risks, milestones, budget exposure, and evidence issues.',
          ),
        ),
      );
    }

    final project = _selectedProject;
    final financeSummary = buildProjectFinanceWorkspaceSummary(project);
    final riskSummary = buildProjectRiskIssueWorkspaceSummary(financeSummary);

    return Scaffold(
      appBar: AppBar(title: const Text('Project Risk & Issues')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectRiskIssuesHeader(
                    project: project,
                    projects: _projects,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Risk Response Flow',
                    subtitle:
                        'Queue mitigation, recovery, escalation, and acceptance responses with owner and evidence context',
                    leadingIcon: Icons.playlist_add_check_outlined,
                    child: ProjectRiskResponseFlowPanel(summary: riskSummary),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Risk & Issue Board',
                    subtitle:
                        'Blockers, delivery risks, milestones, budget exposure, authority, cash-flow, and evidence issues',
                    leadingIcon: Icons.health_and_safety_outlined,
                    child: ProjectRiskIssueWorkspacePanel(summary: riskSummary),
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

/// Header for selecting the risk and issue project context.
class _ProjectRiskIssuesHeader extends StatelessWidget {
  const _ProjectRiskIssuesHeader({
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
            title: 'Project Risk & Issues',
            subtitle:
                '${project.name} risk workspace for blockers, delivery risks, milestones, budget exposure, authority, cash-flow, and evidence issues.',
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

@Preview(name: 'Project risk issues screen')
Widget projectRiskIssuesScreenPreview() {
  return const MaterialApp(
    home: ProjectRiskIssuesScreen(initialProjectId: 'warehouse-automation'),
  );
}
