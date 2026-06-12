import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_petty_cash_workspace_service.dart';
import '../widgets/project_petty_cash_request_intake_panel.dart';
import '../widgets/project_petty_cash_workspace_panel.dart';

/// Dedicated petty-cash workspace for project float and reconciliation work.
class ProjectPettyCashScreen extends StatefulWidget {
  const ProjectPettyCashScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  State<ProjectPettyCashScreen> createState() => _ProjectPettyCashScreenState();
}

/// Keeps petty-cash project selection separate from workspace presentation.
class _ProjectPettyCashScreenState extends State<ProjectPettyCashScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectPettyCashScreen oldWidget) {
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
        appBar: AppBar(title: const Text('Project Petty Cash')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.payments_outlined,
            title: 'No projects available',
            message:
                'Add a project before managing petty cash, custodians, receipts, and reconciliation.',
          ),
        ),
      );
    }

    final project = _selectedProject;
    final financeSummary = buildProjectFinanceWorkspaceSummary(project);
    final pettyCashSummary = buildProjectPettyCashWorkspaceSummary(
      financeSummary,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Project Petty Cash')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectPettyCashHeader(
                    project: project,
                    projects: _projects,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Petty Cash Request Flow',
                    subtitle:
                        'Queue float requests with custodian, amount, purpose, evidence, and reconciliation timing',
                    leadingIcon: Icons.add_card_outlined,
                    child: ProjectPettyCashRequestIntakePanel(
                      summary: pettyCashSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Petty Cash Workspace',
                    subtitle:
                        'Project float, custodians, receipts, approval route, and reconciliation',
                    leadingIcon: Icons.payments_outlined,
                    child: ProjectPettyCashWorkspacePanel(
                      summary: pettyCashSummary,
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

/// Header for selecting the project petty-cash operating context.
class _ProjectPettyCashHeader extends StatelessWidget {
  const _ProjectPettyCashHeader({
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
            title: 'Project Petty Cash',
            subtitle:
                '${project.name} petty-cash workspace for project float, receipts, custodians, approval route, and closeout evidence.',
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

@Preview(name: 'Project petty cash screen')
Widget projectPettyCashScreenPreview() {
  return const MaterialApp(
    home: ProjectPettyCashScreen(initialProjectId: 'retail-modernization'),
  );
}
