import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_finance_portfolio_triage_service.dart';
import '../services/project_finance_workspace_service.dart';
import '../widgets/project_finance_portfolio_triage_panel.dart';
import '../widgets/project_finance_workspace_panels.dart';

/// Dedicated project finance workspace for budget, petty cash, and approvals.
class ProjectFinanceScreen extends StatefulWidget {
  const ProjectFinanceScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  State<ProjectFinanceScreen> createState() => _ProjectFinanceScreenState();
}

/// Keeps project selection state separate from finance panel composition.
class _ProjectFinanceScreenState extends State<ProjectFinanceScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectFinanceScreen oldWidget) {
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
        appBar: AppBar(title: const Text('Project Finance')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No projects available',
            message:
                'Add a project before reviewing budgets, petty cash, approvals, and reconciliation.',
          ),
        ),
      );
    }

    final selectedProject = _selectedProject;
    final summary = buildProjectFinanceWorkspaceSummary(selectedProject);
    final portfolioTriage = buildProjectFinancePortfolioTriageSummary(
      _projects,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Project Finance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectFinanceHeader(
                    project: selectedProject,
                    projects: _projects,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Portfolio Finance Triage',
                    subtitle:
                        'Cross-project action pressure, open ledger items, and budget runway',
                    leadingIcon: Icons.account_tree_outlined,
                    child: ProjectFinancePortfolioTriagePanel(
                      summary: portfolioTriage,
                      selectedProjectId: selectedProject.id,
                      onProjectSelected:
                          (projectId) =>
                              setState(() => _selectedProjectId = projectId),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProjectFinanceWorkspacePanels(summary: summary),
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

/// Header for choosing project finance context without hiding the workspace.
class _ProjectFinanceHeader extends StatelessWidget {
  const _ProjectFinanceHeader({
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
            title: 'Project Finance',
            subtitle:
                '${project.name} finance workspace for budget ledger, petty cash, approvals, cash flow, and reconciliation.',
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

@Preview(name: 'Project finance screen')
Widget projectFinanceScreenPreview() {
  return const MaterialApp(
    home: ProjectFinanceScreen(initialProjectId: 'retail-modernization'),
  );
}
