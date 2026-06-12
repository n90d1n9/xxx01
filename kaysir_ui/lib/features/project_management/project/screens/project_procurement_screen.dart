import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_procurement_commitment_service.dart';
import '../widgets/project_expense_intake_panel.dart';
import '../widgets/project_procurement_commitment_panel.dart';
import '../widgets/project_procurement_request_flow_panel.dart';

/// Dedicated procurement workspace for vendor commitments and delivery proof.
class ProjectProcurementScreen extends StatefulWidget {
  const ProjectProcurementScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  State<ProjectProcurementScreen> createState() =>
      _ProjectProcurementScreenState();
}

/// Keeps procurement project selection separate from presentation widgets.
class _ProjectProcurementScreenState extends State<ProjectProcurementScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectProcurementScreen oldWidget) {
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
        appBar: AppBar(title: const Text('Project Procurement')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No projects available',
            message:
                'Add a project before tracking vendor commitments, procurement routes, supplier risks, and delivery proof.',
          ),
        ),
      );
    }

    final project = _selectedProject;
    final financeSummary = buildProjectFinanceWorkspaceSummary(project);
    final procurementSummary = buildProjectProcurementCommitmentSummary(
      financeSummary,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Project Procurement')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectProcurementHeader(
                    project: project,
                    projects: _projects,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Procurement Request Flow',
                    subtitle:
                        'Create vendor, supplier, purchase, and delivery-proof requests with route-ready context',
                    leadingIcon: Icons.playlist_add_check_outlined,
                    child: ProjectProcurementRequestFlowPanel(
                      summary: procurementSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Procurement Commitments',
                    subtitle:
                        'Vendor packages, spend routes, authority, delivery proof, and supplier risks',
                    leadingIcon: Icons.inventory_2_outlined,
                    child: ProjectProcurementCommitmentPanel(
                      summary: procurementSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Expense Intake',
                    subtitle:
                        'Petty cash, reimbursements, vendors, and exceptions',
                    leadingIcon: Icons.request_quote_outlined,
                    child: ProjectExpenseIntakePanel(
                      summary: financeSummary.expenseIntake,
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

/// Header for selecting the procurement project context.
class _ProjectProcurementHeader extends StatelessWidget {
  const _ProjectProcurementHeader({
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
            title: 'Project Procurement',
            subtitle:
                '${project.name} procurement workspace for vendor packages, supplier risks, commitment authority, and delivery proof.',
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

@Preview(name: 'Project procurement screen')
Widget projectProcurementScreenPreview() {
  return const MaterialApp(
    home: ProjectProcurementScreen(initialProjectId: 'warehouse-automation'),
  );
}
