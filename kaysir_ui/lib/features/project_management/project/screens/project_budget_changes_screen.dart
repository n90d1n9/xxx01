import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_budget_change_workspace_service.dart';
import '../services/project_finance_workspace_service.dart';
import '../widgets/project_budget_change_request_intake_panel.dart';
import '../widgets/project_budget_change_workspace_panel.dart';

/// Dedicated budget-change workspace for project variation requests.
class ProjectBudgetChangesScreen extends StatefulWidget {
  const ProjectBudgetChangesScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  State<ProjectBudgetChangesScreen> createState() =>
      _ProjectBudgetChangesScreenState();
}

/// Keeps project selection separate from budget-change presentation.
class _ProjectBudgetChangesScreenState
    extends State<ProjectBudgetChangesScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectBudgetChangesScreen oldWidget) {
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
        appBar: AppBar(title: const Text('Project Budget Changes')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.rule_folder_outlined,
            title: 'No projects available',
            message:
                'Add a project before preparing budget changes, variation requests, and approval evidence.',
          ),
        ),
      );
    }

    final project = _selectedProject;
    final financeSummary = buildProjectFinanceWorkspaceSummary(project);
    final budgetChangeSummary = buildProjectBudgetChangeWorkspaceSummary(
      financeSummary,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Project Budget Changes')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectBudgetChangesHeader(
                    project: project,
                    projects: _projects,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Budget Change Request Flow',
                    subtitle:
                        'Queue variation requests with owner, amount, impact, evidence, and review route',
                    leadingIcon: Icons.playlist_add_check_outlined,
                    child: ProjectBudgetChangeRequestIntakePanel(
                      summary: budgetChangeSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Budget Change Workspace',
                    subtitle:
                        'Variation requests, recovery amounts, approval route, and budget evidence',
                    leadingIcon: Icons.rule_folder_outlined,
                    child: ProjectBudgetChangeWorkspacePanel(
                      summary: budgetChangeSummary,
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

/// Header for selecting the budget-change project context.
class _ProjectBudgetChangesHeader extends StatelessWidget {
  const _ProjectBudgetChangesHeader({
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
            title: 'Project Budget Changes',
            subtitle:
                '${project.name} budget-change workspace for variation requests, recovery amounts, approval route, and evidence.',
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

@Preview(name: 'Project budget changes screen')
Widget projectBudgetChangesScreenPreview() {
  return const MaterialApp(
    home: ProjectBudgetChangesScreen(initialProjectId: 'warehouse-automation'),
  );
}
