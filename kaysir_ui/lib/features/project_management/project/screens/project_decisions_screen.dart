import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../data/project_portfolio_repository.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_decisions_workspace_service.dart';
import '../widgets/project_decision_action_plan_panel.dart';
import '../widgets/project_decision_brief_pack_panel.dart';
import '../widgets/project_decision_cadence_panel.dart';
import '../widgets/project_decision_escalation_ladder_panel.dart';
import '../widgets/project_decision_evidence_intake_panel.dart';
import '../widgets/project_decision_evidence_matrix_panel.dart';
import '../widgets/project_decision_governance_panel.dart';
import '../widgets/project_decision_impact_matrix_panel.dart';
import '../widgets/project_decision_intake_panel.dart';
import '../widgets/project_decision_readiness_gate_panel.dart';
import '../widgets/project_decision_register_panel.dart';
import '../widgets/project_decision_review_flow_panel.dart';
import '../widgets/project_decision_sla_tracker_panel.dart';
import '../widgets/project_decision_workflow_board_panel.dart';
import '../widgets/project_next_decision_panel.dart';

/// Dedicated workspace for project next decisions and governance routes.
class ProjectDecisionsScreen extends ConsumerStatefulWidget {
  const ProjectDecisionsScreen({
    this.initialProjectId,
    this.repository = const ProjectPortfolioRepository(),
    super.key,
  });

  final String? initialProjectId;
  final ProjectPortfolioRepository repository;

  @override
  ConsumerState<ProjectDecisionsScreen> createState() =>
      _ProjectDecisionsScreenState();
}

/// Keeps project selection and Riverpod data access outside decision UI panels.
class _ProjectDecisionsScreenState
    extends ConsumerState<ProjectDecisionsScreen> {
  late List<ProjectPortfolioItem> _projects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _projects = widget.repository.fetchProjects();
    _selectedProjectId = _resolveProjectId(widget.initialProjectId);
  }

  @override
  void didUpdateWidget(covariant ProjectDecisionsScreen oldWidget) {
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
        appBar: AppBar(title: const Text('Project Decisions')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.account_tree_outlined,
            title: 'No projects available',
            message:
                'Add a project before preparing next decisions, governance routes, sponsor ownership, approval evidence, and decision briefs.',
          ),
        ),
      );
    }

    final project = _selectedProject;
    final allGanttTasks = ref.watch(gantt.tasksProvider);
    final summary = buildProjectDecisionsWorkspaceSummary(
      project: project,
      dependencyTasks: allGanttTasks,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Project Decisions')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectDecisionsHeader(
                    project: project,
                    projects: _projects,
                    linkedTimelineCount: summary.timelineTasks.length,
                    onProjectChanged:
                        (projectId) =>
                            setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: 20),
                  AppContentPanel(
                    title: 'Decision Intake Flow',
                    subtitle:
                        'Create decision drafts, route owners, validate context, and queue the next action',
                    leadingIcon: Icons.post_add_outlined,
                    child: ProjectDecisionIntakePanel(
                      registerSummary: summary.decisionRegisterSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Review Flow',
                    subtitle:
                        'Review existing decisions, select outcomes, validate notes, and queue status changes',
                    leadingIcon: Icons.rate_review_outlined,
                    child: ProjectDecisionReviewFlowPanel(
                      registerSummary: summary.decisionRegisterSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Evidence Intake',
                    subtitle:
                        'Attach proof, references, sign-off notes, and review confidence to decisions',
                    leadingIcon: Icons.upload_file_outlined,
                    child: ProjectDecisionEvidenceIntakePanel(
                      registerSummary: summary.decisionRegisterSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Brief Pack',
                    subtitle:
                        'Copy-ready sponsor and team brief with route, owner focus, actions, and evidence',
                    leadingIcon: Icons.assignment_turned_in_outlined,
                    child: ProjectDecisionBriefPackPanel(
                      summary: summary.decisionBriefPackSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Cadence',
                    subtitle:
                        'Review rhythm, escalation window, agenda, and owner follow-up timing',
                    leadingIcon: Icons.event_repeat_outlined,
                    child: ProjectDecisionCadencePanel(
                      summary: summary.decisionCadenceSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Evidence Matrix',
                    subtitle:
                        'Decision proof readiness, missing evidence, review status, and sign-off checklist',
                    leadingIcon: Icons.fact_check_outlined,
                    child: ProjectDecisionEvidenceMatrixPanel(
                      summary: summary.decisionEvidenceMatrixSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Impact Matrix',
                    subtitle:
                        'Operational impact index, affected areas, owners, and mitigation priorities',
                    leadingIcon: Icons.insights_outlined,
                    child: ProjectDecisionImpactMatrixPanel(
                      summary: summary.decisionImpactMatrixSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Workflow Board',
                    subtitle:
                        'Decision stages, blockers, reviews, delegated work, and closure snapshot',
                    leadingIcon: Icons.view_kanban_outlined,
                    child: ProjectDecisionWorkflowBoardPanel(
                      summary: summary.decisionWorkflowBoardSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Escalation Ladder',
                    subtitle:
                        'Sponsor, owner, team, and monitor lanes for routing open decisions',
                    leadingIcon: Icons.notification_important_outlined,
                    child: ProjectDecisionEscalationLadderPanel(
                      summary: summary.decisionEscalationLadderSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision SLA Tracker',
                    subtitle:
                        'Due dates, breached actions, same-day decisions, and timing lanes',
                    leadingIcon: Icons.event_note_outlined,
                    child: ProjectDecisionSlaTrackerPanel(
                      summary: summary.decisionSlaTrackerSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Readiness Gate',
                    subtitle:
                        'Readiness score, blockers, evidence gaps, and decision preparation lanes',
                    leadingIcon: Icons.fact_check_outlined,
                    child: ProjectDecisionReadinessGatePanel(
                      summary: summary.decisionReadinessGateSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Next Decisions',
                    subtitle:
                        'Priority decisions, readiness signals, and copyable decision brief',
                    leadingIcon: Icons.rule_folder_outlined,
                    child: ProjectNextDecisionPanel(
                      summary: summary.nextDecisionSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Governance',
                    subtitle:
                        'Authority route, sponsor decision path, approval evidence, and governance brief',
                    leadingIcon: Icons.account_tree_outlined,
                    child: ProjectDecisionGovernancePanel(
                      summary: summary.governanceSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Owner Action Plan',
                    subtitle:
                        'Accountable owners, overdue decisions, awaiting reviews, and next clearance steps',
                    leadingIcon: Icons.groups_outlined,
                    child: ProjectDecisionActionPlanPanel(
                      summary: summary.decisionActionPlanSummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Decision Register',
                    subtitle:
                        'Filterable decision log, owners, due dates, domain fields, and action status',
                    leadingIcon: Icons.fact_check_outlined,
                    child: ProjectDecisionRegisterPanel(
                      summary: summary.decisionRegisterSummary,
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

/// Header for selecting the project decision context.
class _ProjectDecisionsHeader extends StatelessWidget {
  const _ProjectDecisionsHeader({
    required this.project,
    required this.projects,
    required this.linkedTimelineCount,
    required this.onProjectChanged,
  });

  final ProjectPortfolioItem project;
  final List<ProjectPortfolioItem> projects;
  final int linkedTimelineCount;
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
            title: 'Project Decisions',
            subtitle:
                '${project.name} decisions workspace for next decisions, governance routes, sponsor ownership, approval evidence, and decision briefs across ${linkedTimelineCount.toString()} linked timeline tasks.',
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

@Preview(name: 'Project decisions screen')
Widget projectDecisionsScreenPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: ProjectDecisionsScreen(initialProjectId: 'mobile-field-app'),
    ),
  );
}
