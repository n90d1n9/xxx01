import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/survey_dashboard_insights_bundle.dart';
import '../analytics/survey_evidence_upload_queue_insights.dart';
import '../analytics/survey_evidence_upload_planner.dart';
import '../analytics/survey_response_sync_readiness.dart';
import '../logic/survey_evidence_upload_activity_tracker.dart';
import '../logic/survey_evidence_upload_queue_actions.dart';
import '../logic/survey_evidence_upload_execution_feedback.dart';
import '../logic/survey_evidence_upload_service.dart';
import '../logic/survey_evidence_upload_task_runner.dart';
import '../logic/survey_dashboard_role_scope.dart';
import '../logic/survey_response_view_intent.dart';
import '../logic/survey_workspace_intent_launcher.dart';
import '../models/survey.dart';
import '../models/survey_assignment.dart';
import '../models/survey_response.dart';
import '../models/survey_response_review.dart';
import '../models/survey_role.dart';
import '../models/survey_status.dart';
import '../models/survey_workspace_intent.dart';
import '../states/survey_assignment_provider.dart';
import '../states/survey_provider.dart';
import '../states/survey_response_provider.dart';
import '../states/survey_response_upload_state_sink.dart';
import '../widgets/dashboard/survey_dashboard_content.dart';
import '../widgets/dashboard/survey_evidence_upload_queue_action_panel.dart';
import '../widgets/dashboard/survey_evidence_upload_queue_dashboard_binding.dart';
import '../widgets/dashboard/survey_evidence_upload_queue_panel_slot.dart';
import '../widgets/dashboard/survey_workspace_section_badges.dart';
import '../widgets/dashboard/survey_workspace_shortcuts.dart';
import '../widgets/dashboard/survey_workspace_shell.dart';
import '../widgets/evidence_response/evidence_upload_execution_feedback_snack_bar.dart';
import 'survey_editor_screen.dart';
import 'survey_list_screen.dart';
import 'survey_view_screen.dart';

class SurveyDashboardScreen extends ConsumerStatefulWidget {
  final SurveyRole initialRole;
  final SurveyWorkspaceIntent? initialIntent;
  final List<SurveyRole> availableRoles;
  final SurveyEvidenceUploader? evidenceUploader;
  final SurveyEvidenceUploadQueueDashboardBinding? evidenceUploadQueueBinding;
  final SurveyEvidenceUploadQueueActionController?
  evidenceUploadQueueActionController;
  final SurveyEvidenceUploadObserver? evidenceUploadQueueObserver;
  final ValueChanged<SurveyEvidenceUploadQueueActionState>?
  onEvidenceUploadQueueStateChanged;
  final ValueChanged<SurveyEvidenceUploadQueueActionResult>?
  onEvidenceUploadQueueActionComplete;
  final SurveyEvidenceUploadQueueActionError? onEvidenceUploadQueueActionError;
  final SurveyEvidenceUploadQueuePanelBuilder? evidenceUploadQueuePanelBuilder;
  final SurveyEvidenceUploadQueueInsights? evidenceUploadQueueInsights;
  final VoidCallback? onRunDueEvidenceUploads;
  final VoidCallback? onMaintainEvidenceUploadQueue;
  final VoidCallback? onRequeueFailedEvidenceUploads;

  const SurveyDashboardScreen({
    super.key,
    this.initialRole = SurveyRole.admin,
    this.initialIntent,
    this.availableRoles = SurveyRole.values,
    this.evidenceUploader,
    this.evidenceUploadQueueBinding,
    this.evidenceUploadQueueActionController,
    this.evidenceUploadQueueObserver,
    this.onEvidenceUploadQueueStateChanged,
    this.onEvidenceUploadQueueActionComplete,
    this.onEvidenceUploadQueueActionError,
    this.evidenceUploadQueuePanelBuilder,
    this.evidenceUploadQueueInsights,
    this.onRunDueEvidenceUploads,
    this.onMaintainEvidenceUploadQueue,
    this.onRequeueFailedEvidenceUploads,
  });

  @override
  ConsumerState<SurveyDashboardScreen> createState() =>
      _SurveyDashboardScreenState();
}

class _SurveyDashboardScreenState extends ConsumerState<SurveyDashboardScreen> {
  late SurveyRole _selectedRole;
  int _selectedIndex = 0;
  int _evidenceSyncFocusRequestId = 0;
  SurveyWorkspaceIntent? _pendingInitialIntent;
  bool _initialIntentLaunchScheduled = false;
  final SurveyEvidenceUploadActivityTracker _activeEvidenceUploads =
      SurveyEvidenceUploadActivityTracker();

  @override
  void initState() {
    super.initState();
    _applyInitialIntent(_dashboardInitialIntent(widget));
    _schedulePendingInitialIntent();
  }

  @override
  void didUpdateWidget(covariant SurveyDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIntent = _dashboardInitialIntent(oldWidget);
    final newIntent = _dashboardInitialIntent(widget);
    if (newIntent == oldIntent && _roleScope.contains(_selectedRole)) {
      return;
    }
    setState(() {
      if (newIntent == oldIntent) {
        _applyRoleScopeToCurrentSelection();
      } else {
        _applyInitialIntent(newIntent);
      }
    });
    _schedulePendingInitialIntent();
  }

  @override
  Widget build(BuildContext context) {
    final surveys = ref.watch(surveyProvider);
    final responses = ref.watch(surveyResponseProvider);
    final assignments = ref.watch(surveyAssignmentProvider);
    final roleScope = _roleScope;
    final insightBundle = SurveyDashboardInsightsBundle.evaluate(
      surveys: surveys,
      responses: responses,
      assignments: assignments,
    );
    final sections = _selectedRole.sections;
    final screenShortcuts = SurveyWorkspaceShortcutBuilder(
      role: _selectedRole,
      surveys: surveys,
      onOpenSurveyList: _openSurveyList,
      onCreateSurvey: _createSurvey,
      onEditSurvey: _editSurvey,
      onOpenSurvey: _openSurvey,
    ).build();
    final evidenceUploadQueuePanelBuilder =
        _evidenceUploadQueueActionPanelBuilder();
    final sectionBadges = SurveyWorkspaceSectionBadgeBuilder(
      responseSyncReadiness: insightBundle.responseSyncReadiness,
      evidenceSyncInsights: insightBundle.evidenceSyncInsights,
      responseReviewInsights: insightBundle.responseReviewInsights,
      evidenceUploadQueueInsights: widget.evidenceUploadQueueInsights,
      activeEvidenceUploadKeys: _activeEvidenceUploads.activeKeys,
    ).build();

    return SurveyWorkspaceShell(
      role: _selectedRole,
      sections: sections,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
          _evidenceSyncFocusRequestId = 0;
        });
      },
      onSectionSelected: _selectSection,
      shortcuts: screenShortcuts,
      sectionBadges: sectionBadges,
      onOpenSurveyList: _openSurveyList,
      onCreateSurvey: _createSurvey,
      bodyBuilder: (context, isWide, selectedSection) {
        return SurveyDashboardContent(
          role: _selectedRole,
          selectedSection: selectedSection,
          insights: insightBundle.insights,
          fieldworkInsights: insightBundle.fieldworkInsights,
          responseInsights: insightBundle.responseInsights,
          evidenceSyncInsights: insightBundle.evidenceSyncInsights,
          responseQualityInsights: insightBundle.responseQualityInsights,
          responseReviewInsights: insightBundle.responseReviewInsights,
          responseSyncReadiness: insightBundle.responseSyncReadiness,
          surveys: surveys,
          isWide: isWide,
          onRoleChanged: _changeRole,
          availableRoles: roleScope.roles,
          onEditSurvey: _editSurvey,
          onOpenSurvey: _openSurvey,
          onOpenResponse: _openReadinessResponse,
          onAssignmentStatusChanged: _updateAssignmentStatus,
          onResponseReviewStatusChanged: _updateResponseReviewStatus,
          onStatusChanged: _updateSurveyStatus,
          onRunEvidenceUploadPlan: _runEvidenceUploadPlan,
          runEvidenceUploadPlanLabel: widget.evidenceUploader == null
              ? 'Queue ready'
              : 'Upload ready',
          onQueueEvidenceUpload: _queueEvidenceUpload,
          onRetryEvidenceUpload: _retryEvidenceUpload,
          onFixEvidenceUpload: _showEvidenceFixHint,
          onMonitorEvidenceUpload: _showEvidenceUploadStatus,
          activeEvidenceUploadKeys: _activeEvidenceUploads.activeKeys,
          evidenceUploadQueuePanelBuilder: evidenceUploadQueuePanelBuilder,
          evidenceUploadQueueInsights: widget.evidenceUploadQueueInsights,
          onRunDueEvidenceUploads: widget.onRunDueEvidenceUploads,
          onMaintainEvidenceUploadQueue: widget.onMaintainEvidenceUploadQueue,
          onRequeueFailedEvidenceUploads: widget.onRequeueFailedEvidenceUploads,
          onOpenEvidenceSyncActivity: _openEvidenceSyncActivity,
          evidenceSyncFocusRequestId: _evidenceSyncFocusRequestId,
        );
      },
    );
  }

  SurveyDashboardRoleScope get _roleScope {
    return SurveyDashboardRoleScope(widget.availableRoles);
  }

  SurveyWorkspaceIntent _dashboardInitialIntent(
    SurveyDashboardScreen dashboard,
  ) {
    final intent =
        dashboard.initialIntent ??
        SurveyWorkspaceIntent(role: dashboard.initialRole);
    return SurveyDashboardRoleScope(
      dashboard.availableRoles,
    ).resolveIntent(intent);
  }

  void _applyInitialIntent(SurveyWorkspaceIntent intent) {
    _selectedRole = intent.role;
    _selectedIndex = intent.selectedIndex;
    _evidenceSyncFocusRequestId = 0;
    _pendingInitialIntent = intent.opensScreen ? intent : null;
  }

  void _schedulePendingInitialIntent() {
    if (_pendingInitialIntent == null || _initialIntentLaunchScheduled) {
      return;
    }
    _initialIntentLaunchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialIntentLaunchScheduled = false;
      _openPendingInitialIntent();
    });
  }

  void _openPendingInitialIntent() {
    final intent = _pendingInitialIntent;
    if (!mounted || intent == null) {
      return;
    }
    _pendingInitialIntent = null;

    SurveyWorkspaceIntentLauncher(
      surveys: ref.read(surveyProvider),
      onOpenSurveyList: _openSurveyList,
      onCreateSurvey: _createSurvey,
      onEditSurvey: _editSurvey,
      onOpenSurvey: _openSurvey,
      onUnavailable: _showIntentUnavailable,
    ).launch(intent);
  }

  void _showIntentUnavailable(SurveyWorkspaceIntent intent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No survey is available for ${intent.launchTarget.label}',
        ),
      ),
    );
  }

  void _changeRole(SurveyRole role) {
    setState(() {
      _selectedRole = _roleScope.resolveRole(role);
      _selectedIndex = 0;
      _evidenceSyncFocusRequestId = 0;
    });
  }

  void _applyRoleScopeToCurrentSelection() {
    final selection = _roleScope.resolveSelection(
      role: _selectedRole,
      selectedIndex: _selectedIndex,
    );

    _selectedRole = selection.role;
    _selectedIndex = selection.selectedIndex;
    _evidenceSyncFocusRequestId = 0;
  }

  void _selectSection(SurveyWorkspaceSection section) {
    final index = _selectedRole.sections.indexOf(section);
    if (index < 0) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      _evidenceSyncFocusRequestId = 0;
    });
  }

  void _openEvidenceSyncActivity() {
    final targetSection =
        _selectedRole.sections.contains(SurveyWorkspaceSection.reports)
        ? SurveyWorkspaceSection.reports
        : SurveyWorkspaceSection.overview;
    final targetIndex = _selectedRole.sections.indexOf(targetSection);
    if (targetIndex < 0) {
      return;
    }

    setState(() {
      _selectedIndex = targetIndex;
      if (targetSection == SurveyWorkspaceSection.reports) {
        _evidenceSyncFocusRequestId++;
      }
    });
  }

  SurveyEvidenceUploadQueuePanelBuilder?
  _evidenceUploadQueueActionPanelBuilder() {
    return SurveyEvidenceUploadQueuePanelBuilderResolver(
      customBuilder: widget.evidenceUploadQueuePanelBuilder,
      binding: widget.evidenceUploadQueueBinding,
      legacyController: widget.evidenceUploadQueueActionController,
      legacyUploadObserver: widget.evidenceUploadQueueObserver,
      onStateChanged: widget.onEvidenceUploadQueueStateChanged,
      onActionComplete: widget.onEvidenceUploadQueueActionComplete,
      onActionError: widget.onEvidenceUploadQueueActionError,
    ).resolve(
      fallbackObserver: surveyResponseUploadStateObserver(
        ref.read(surveyResponseProvider.notifier),
      ),
    );
  }

  void _createSurvey() {
    final notifier = ref.read(surveyProvider.notifier);
    final newSurvey = notifier.createEmptySurvey();
    notifier.addSurvey(newSurvey);
    _editSurvey(newSurvey);
  }

  void _openSurveyList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SurveyListScreen()),
    );
  }

  void _editSurvey(Survey survey) {
    ref.read(currentSurveyProvider.notifier).state = survey;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyEditorScreen(surveyId: survey.id),
      ),
    );
  }

  void _openSurvey(Survey survey) {
    ref.read(currentSurveyProvider.notifier).state = survey;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyViewerScreen(
          surveyId: survey.id,
          evidenceUploader: widget.evidenceUploader,
        ),
      ),
    );
  }

  void _openReadinessResponse(SurveyResponseSyncReadiness readiness) {
    final survey = readiness.survey;
    if (survey == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(readiness.detailLabel)));
      return;
    }

    ref.read(currentSurveyProvider.notifier).state = survey;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyViewerScreen(
          surveyId: survey.id,
          initialResponseId: readiness.response.id,
          initialIntent: SurveyResponseViewerIntent.fromReadiness(readiness),
          evidenceUploader: widget.evidenceUploader,
        ),
      ),
    );
  }

  void _updateSurveyStatus(Survey survey, SurveyStatus status) {
    ref.read(surveyProvider.notifier).updateSurveyStatus(survey.id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${survey.title} moved to ${status.label}')),
    );
  }

  void _updateAssignmentStatus(
    SurveyAssignment assignment,
    SurveyAssignmentStatus status,
  ) {
    ref
        .read(surveyAssignmentProvider.notifier)
        .updateAssignmentStatus(assignment.id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${assignment.assigneeName} marked ${status.label}'),
      ),
    );
  }

  void _updateResponseReviewStatus(
    SurveyResponse response,
    SurveyResponseReviewStatus status,
  ) {
    ref
        .read(surveyResponseProvider.notifier)
        .updateReviewStatus(
          responseId: response.id,
          status: status,
          reviewerName: 'Survey Admin',
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${response.respondentName} marked ${status.label}'),
      ),
    );
  }

  Future<void> _queueEvidenceUpload(SurveyEvidenceUploadTask task) async {
    if (widget.evidenceUploader != null) {
      await _runEvidenceUpload(task, fallbackMessage: 'queued for upload');
      return;
    }

    ref
        .read(surveyResponseProvider.notifier)
        .queueEvidenceUpload(
          responseId: task.responseId,
          evidenceId: task.evidenceId,
        );
    _showUploadSnackBar('${task.item.title} queued for upload');
  }

  Future<void> _retryEvidenceUpload(SurveyEvidenceUploadTask task) async {
    if (widget.evidenceUploader != null) {
      await _runEvidenceUpload(task, fallbackMessage: 'retry queued');
      return;
    }

    ref
        .read(surveyResponseProvider.notifier)
        .queueEvidenceUpload(
          responseId: task.responseId,
          evidenceId: task.evidenceId,
        );
    _showUploadSnackBar('${task.item.title} retry queued');
  }

  Future<void> _runEvidenceUploadPlan(SurveyEvidenceUploadPlan plan) async {
    final uploader = widget.evidenceUploader;
    if (uploader == null) {
      final uploadableTasks = _activeEvidenceUploads.inactiveTasks(
        plan.uploadableTasks,
      );
      if (uploadableTasks.isEmpty) {
        _showUploadSnackBar('No evidence uploads are ready to run');
        return;
      }

      final notifier = ref.read(surveyResponseProvider.notifier);
      for (final task in uploadableTasks) {
        notifier.queueEvidenceUpload(
          responseId: task.responseId,
          evidenceId: task.evidenceId,
        );
      }
      _showUploadSnackBar('${uploadableTasks.length} evidence uploads queued');
      return;
    }

    final result = await _evidenceUploadRunner(uploader).uploadPlan(plan);

    if (!mounted) {
      return;
    }
    if (result.noUploadableTasks) {
      _showUploadSnackBar('No evidence uploads are ready to run');
      return;
    }

    _showUploadSnackBar(result.execution!.summaryLabel);
  }

  Future<void> _runEvidenceUpload(
    SurveyEvidenceUploadTask task, {
    required String fallbackMessage,
  }) async {
    final uploader = widget.evidenceUploader;
    if (uploader == null) {
      _showUploadSnackBar('${task.item.title} $fallbackMessage');
      return;
    }

    final result = await _evidenceUploadRunner(uploader).uploadTask(task);

    if (!mounted) {
      return;
    }
    if (result.alreadyActive) {
      _showUploadSnackBar('${task.item.title} is already uploading');
      return;
    }

    _showUploadExecutionSnackBar(result.execution!, task);
  }

  SurveyEvidenceUploadTaskRunner _evidenceUploadRunner(
    SurveyEvidenceUploader uploader,
  ) {
    return SurveyEvidenceUploadTaskRunner(
      service: SurveyEvidenceUploadService(uploader: uploader),
      activityTracker: _activeEvidenceUploads,
      observer: surveyResponseUploadStateObserver(
        ref.read(surveyResponseProvider.notifier),
      ),
      onActivityChanged: _refreshEvidenceUploadActivity,
    );
  }

  void _refreshEvidenceUploadActivity() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _showUploadExecutionSnackBar(
    SurveyEvidenceUploadExecution execution,
    SurveyEvidenceUploadTask task,
  ) {
    final feedback = SurveyEvidenceUploadExecutionFeedback.fromExecution(
      execution,
      fallbackTask: task,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SurveyEvidenceUploadExecutionSnackBar.build(context, feedback),
    );
  }

  void _showEvidenceFixHint(SurveyEvidenceUploadTask task) {
    _showUploadSnackBar('${task.item.title}: ${task.detail}');
  }

  void _showEvidenceUploadStatus(SurveyEvidenceUploadTask task) {
    _showUploadSnackBar('${task.item.title}: ${task.item.stateLabel}');
  }

  void _showUploadSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
