import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/project_form_draft.dart';
import '../models/project_form_focus.dart';
import '../project_management_routes.dart';
import '../services/project_form_submission_feedback_service.dart';
import '../states/project_portfolio_provider.dart';
import '../widgets/project_form_edit_guard_state.dart';
import '../widgets/project_form_loading_state.dart';
import '../widgets/project_form_navigation_actions.dart';
import '../widgets/project_form_screen_content.dart';
import '../widgets/project_form_screen_frame.dart';

/// Project form route that coordinates create, edit, loading, and guard states.
class ProjectFormScreen extends ConsumerWidget {
  const ProjectFormScreen({
    this.projectId,
    this.initialFocus = ProjectFormPanelFocus.none,
    this.focusedAttributeKey,
    super.key,
  });

  final String? projectId;
  final ProjectFormPanelFocus initialFocus;
  final String? focusedAttributeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydration = ref.watch(createdProjectPortfolioHydrationProvider);
    final isEditing = projectId != null;
    final createdProjectIds = ref.watch(createdProjectPortfolioIdsProvider);
    final project =
        projectId == null ? null : ref.watch(projectByIdProvider(projectId!));
    final navigationActions = _navigationActions(
      context,
      detailProjectId: project?.id,
    );

    if (isEditing &&
        hydration.isLoading &&
        (project == null || !createdProjectIds.contains(projectId))) {
      return ProjectFormScreenFrame(
        actions: navigationActions,
        centerBody: true,
        child: ProjectFormLoadingState(projectId: projectId),
      );
    }

    if (isEditing &&
        (project == null || !createdProjectIds.contains(projectId))) {
      return ProjectFormScreenFrame(
        actions: navigationActions,
        centerBody: true,
        child: ProjectFormEditGuardState(
          projectId: projectId,
          onOpenProjects:
              () => context.go(ProjectManagementRoutes.portfolioPath),
          onOpenProjectTable:
              () => context.go(ProjectManagementRoutes.tablePath),
        ),
      );
    }

    final initialDraft =
        project == null
            ? ProjectFormDraft.initial(today: DateTime(2026, 6))
            : ProjectFormDraft.fromProject(project);

    return ProjectFormScreenFrame(
      actions: navigationActions,
      safeArea: false,
      child: ProjectFormScreenContent(
        initialDraft: initialDraft,
        isEditing: isEditing,
        initialFocus: initialFocus,
        focusedAttributeKey: focusedAttributeKey,
        onSubmitted:
            (draft) =>
                isEditing
                    ? _updateProject(
                      context: context,
                      ref: ref,
                      draft: draft,
                      projectId: projectId!,
                    )
                    : _createProject(context: context, ref: ref, draft: draft),
      ),
    );
  }

  List<Widget> _navigationActions(
    BuildContext context, {
    String? detailProjectId,
  }) {
    final normalizedProjectId = detailProjectId?.trim();
    final hasProjectId =
        normalizedProjectId != null && normalizedProjectId.isNotEmpty;

    return [
      ProjectFormNavigationActions(
        onOpenProjects: () => context.go(ProjectManagementRoutes.portfolioPath),
        onOpenProjectTable: () => context.go(ProjectManagementRoutes.tablePath),
        onOpenProjectDetail:
            hasProjectId
                ? () => context.go(
                  ProjectManagementRoutes.detailPath(normalizedProjectId),
                )
                : null,
      ),
    ];
  }

  void _createProject({
    required BuildContext context,
    required WidgetRef ref,
    required ProjectFormDraft draft,
  }) {
    final project = ref
        .read(createdProjectPortfolioProvider.notifier)
        .createFromDraft(
          draft: draft,
          existingProjects: ref.read(projectPortfolioProvider),
        );

    showProjectFormSubmissionFeedback(
      context,
      projectName: project.name,
      kind: ProjectFormSubmissionFeedbackKind.created,
      action: SnackBarAction(
        label: 'View',
        onPressed:
            () => context.go(ProjectManagementRoutes.detailPath(project.id)),
      ),
    );
  }

  void _updateProject({
    required BuildContext context,
    required WidgetRef ref,
    required ProjectFormDraft draft,
    required String projectId,
  }) {
    final project = ref
        .read(createdProjectPortfolioProvider.notifier)
        .updateFromDraft(projectId: projectId, draft: draft);
    if (project == null) return;

    showProjectFormSubmissionFeedback(
      context,
      projectName: project.name,
      kind: ProjectFormSubmissionFeedbackKind.updated,
      action: SnackBarAction(
        label: 'View',
        onPressed:
            () => context.go(ProjectManagementRoutes.detailPath(project.id)),
      ),
    );
  }
}
