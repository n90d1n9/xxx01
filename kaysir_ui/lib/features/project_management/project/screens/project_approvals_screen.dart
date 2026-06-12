import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_approval_workspace_service.dart';
import '../services/project_finance_workspace_service.dart';
import '../widgets/project_approval_action_flow_panel.dart';
import '../widgets/project_approval_workspace_panel.dart';

/// Dedicated approval workspace for authority, sign-off, and evidence routing.
class ProjectApprovalsScreen extends StatefulWidget {
  const ProjectApprovalsScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  State<ProjectApprovalsScreen> createState() => _ProjectApprovalsScreenState();
}

/// Keeps approval workspace project selection separate from presentation.
class _ProjectApprovalsScreenState extends State<ProjectApprovalsScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectApprovalsScreen oldWidget) {
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
        appBar: AppBar(title: const Text('Project Approvals')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.verified_user_outlined,
            title: 'No projects available',
            message:
                'Add a project before routing spend authority, budget changes, evidence sign-off, and approval records.',
          ),
        ),
      );
    }

    final project = _selectedProject;
    final financeSummary = buildProjectFinanceWorkspaceSummary(project);
    final approvalSummary = buildProjectApprovalWorkspaceSummary(
      financeSummary,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Project Approvals')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectApprovalsHeader(
                    project: project,
                    projects: _projects,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Approval Action Flow',
                    subtitle:
                        'Review, approve, delegate, escalate, or request evidence for approval items',
                    leadingIcon: Icons.playlist_add_check_outlined,
                    child: ProjectApprovalActionFlowPanel(
                      summary: approvalSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Approval Workspace',
                    subtitle:
                        'Spend authority, budget changes, evidence sign-off, and approval records',
                    leadingIcon: Icons.verified_user_outlined,
                    child: ProjectApprovalWorkspacePanel(
                      summary: approvalSummary,
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

/// Header for selecting the approval workspace project context.
class _ProjectApprovalsHeader extends StatelessWidget {
  const _ProjectApprovalsHeader({
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
            title: 'Project Approvals',
            subtitle:
                '${project.name} approvals workspace for authority routing, decision evidence, budget changes, and sign-off ownership.',
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

@Preview(name: 'Project approvals screen')
Widget projectApprovalsScreenPreview() {
  return const MaterialApp(
    home: ProjectApprovalsScreen(initialProjectId: 'warehouse-automation'),
  );
}
