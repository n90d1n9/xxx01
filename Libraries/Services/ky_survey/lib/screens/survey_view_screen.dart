// lib/screens/survey_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/survey_evidence_sync_insights.dart';
import '../analytics/survey_evidence_upload_planner.dart';
import '../logic/survey_evidence_capture_adapter.dart';
import '../logic/survey_evidence_upload_activity_tracker.dart';
import '../logic/survey_evidence_upload_execution_feedback.dart';
import '../logic/survey_evidence_upload_service.dart';
import '../logic/survey_evidence_upload_task_runner.dart';
import '../logic/survey_response_answer_issue_focus_target.dart';
import '../logic/survey_response_evidence_focus_target.dart';
import '../logic/survey_response_focus_state.dart';
import '../logic/survey_response_evidence_summary.dart';
import '../logic/survey_response_issue_summary.dart';
import '../logic/survey_response_section_flow.dart';
import '../logic/survey_response_session_summary.dart';
import '../logic/survey_response_submission_plan.dart';
import '../logic/survey_response_upload_review_focus_target.dart';
import '../logic/survey_response_view_intent.dart';
import '../logic/survey_response_viewer_focus_resolver.dart';
import '../logic/survey_response_viewer_snapshot.dart';
import '../models/survey.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_response.dart';
import '../states/survey_provider.dart';
import '../states/survey_response_provider.dart';
import '../states/survey_response_upload_state_sink.dart';
import '../widgets/evidence_response/evidence_capture_sheet.dart';
import '../widgets/evidence_response/evidence_upload_execution_feedback_snack_bar.dart';
import '../widgets/evidence_response/evidence_upload_review_sheet.dart';
import '../widgets/survey_response_section_progress.dart';
import '../widgets/survey_response_navigation_bar.dart';
import '../widgets/survey_response_viewer_body.dart';
import '../widgets/survey_response_viewer_header.dart';

/// Displays a survey response workflow with answer, evidence, and upload actions.
class SurveyViewerScreen extends ConsumerStatefulWidget {
  final String surveyId;
  final String? initialResponseId;
  final SurveyResponseViewerIntent? initialIntent;
  final SurveyEvidenceCaptureRegistry captureRegistry;
  final SurveyEvidenceUploader? evidenceUploader;

  const SurveyViewerScreen({
    super.key,
    required this.surveyId,
    this.initialResponseId,
    this.initialIntent,
    this.captureRegistry = const SurveyEvidenceCaptureRegistry(),
    this.evidenceUploader,
  });

  @override
  ConsumerState<SurveyViewerScreen> createState() => _SurveyViewerScreenState();
}

class _SurveyViewerScreenState extends ConsumerState<SurveyViewerScreen> {
  late final String _responseId;
  SurveyResponseFocusState _focusState = const SurveyResponseFocusState();
  final SurveyEvidenceUploadActivityTracker _activeEvidenceUploads =
      SurveyEvidenceUploadActivityTracker();

  String? get _focusedQuestionId => _focusState.focusedQuestionId;

  String? get _focusedRequirementId => _focusState.focusedRequirementId;

  int get _focusRequestCount => _focusState.questionFocusRequestId;

  int get _evidenceFocusRequestCount => _focusState.evidenceFocusRequestId;

  @override
  void initState() {
    super.initState();
    final survey = ref
        .read(surveyProvider)
        .firstWhere((s) => s.id == widget.surveyId);
    final notifier = ref.read(surveyResponseProvider.notifier);
    final response =
        _initialDraftForSurvey(notifier) ??
        notifier.createOrResumeDraft(
          surveyId: widget.surveyId,
          surveyVersionId: survey.activeVersionId,
        );
    _responseId = response.id;
    _focusState = SurveyResponseViewerFocusResolver.resolveInitialFocus(
      intent: widget.initialIntent,
      snapshot: SurveyResponseViewerSnapshot.evaluate(
        survey: survey,
        response: response,
        requestedPageIndex: _focusState.selectedPageIndex,
      ),
      initialState: _focusState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surveys = ref.watch(surveyProvider);
    final survey = surveys.firstWhere((s) => s.id == widget.surveyId);
    final responses = ref.watch(surveyResponseProvider);
    final response = _findResponse(responses);

    if (response == null) {
      return Scaffold(
        appBar: AppBar(title: Text(survey.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final snapshot = SurveyResponseViewerSnapshot.evaluate(
      survey: survey,
      response: response,
      requestedPageIndex: _focusState.selectedPageIndex,
    );
    final initialIntent = widget.initialIntent;

    return Scaffold(
      appBar: AppBar(title: Text(survey.title)),
      body: Column(
        children: [
          SurveyResponseViewerHeader(
            survey: survey,
            summary: snapshot.sessionSummary,
          ),
          SurveyResponseSectionProgress(
            pages: snapshot.pages,
            pageStatuses: snapshot.pageStatuses,
            selectedIndex: snapshot.selectedPageIndex,
            onPageSelected: _selectPage,
          ),

          // Questions
          Expanded(
            child: SurveyResponseViewerBody(
              intent: initialIntent,
              onIntentAction: initialIntent == null
                  ? null
                  : () => _handleInitialIntentAction(
                      intent: initialIntent,
                      survey: survey,
                      response: response,
                      summary: snapshot.sessionSummary,
                      evidenceSummary: snapshot.evidenceSummary,
                      sectionFlow: snapshot.sectionFlow,
                    ),
              evidenceSummary: snapshot.evidenceSummary,
              issueSummary: snapshot.issueSummary,
              selectedPageIndex: snapshot.selectedPageIndex,
              selectedPage: snapshot.selectedPage,
              selectedPageStatus: snapshot.selectedPageStatus,
              focusedRequirementId: _focusedRequirementId,
              evidenceFocusRequestKey: _evidenceFocusRequestCount,
              focusedQuestionId: _focusedQuestionId,
              questionFocusRequestKey: _focusRequestCount,
              onRequirementStatusSelected: (status) =>
                  _selectEvidenceRequirement(
                    response: response,
                    sectionFlow: snapshot.sectionFlow,
                    status: status,
                  ),
              onIssueSelected: _selectPage,
              onIssueItemSelected: _focusIssueItem,
              valueForQuestion: response.valueFor,
              issuesForQuestion:
                  snapshot.sessionSummary.validation.issuesForQuestion,
              onAnswerChanged: (question, value) {
                ref
                    .read(surveyResponseProvider.notifier)
                    .updateAnswer(
                      responseId: response.id,
                      questionId: question.id,
                      value: value,
                      questions: survey.questions,
                    );
              },
            ),
          ),

          SurveyResponseNavigationBar(
            summary: snapshot.sessionSummary,
            evidenceSummary: snapshot.evidenceSummary,
            pageCount: snapshot.pageCount,
            selectedPageIndex: snapshot.selectedPageIndex,
            onPrevious: () => _previousPage(snapshot.selectedPageIndex),
            onNext: () => _nextPage(snapshot.selectedPageIndex),
            onSubmit: () => _submitResponse(
              response: response,
              summary: snapshot.sessionSummary,
              evidenceSummary: snapshot.evidenceSummary,
              sectionFlow: snapshot.sectionFlow,
            ),
            submitLabel: initialIntent?.shouldPromptSubmit ?? false
                ? 'Submit now'
                : 'Submit Response',
          ),
        ],
      ),
    );
  }

  SurveyResponse? _findResponse(List<SurveyResponse> responses) {
    for (final response in responses) {
      if (response.id == _responseId) {
        return response;
      }
    }

    return null;
  }

  SurveyResponse? _initialDraftForSurvey(SurveyResponseNotifier notifier) {
    final responseId = widget.initialResponseId;
    if (responseId == null) {
      return null;
    }

    final response = notifier.responseById(responseId);
    if (response == null ||
        response.surveyId != widget.surveyId ||
        response.status != SurveyResponseStatus.draft) {
      return null;
    }

    return response;
  }

  void _selectPage(int index) {
    setState(() => _focusState = _focusState.selectPage(index));
  }

  void _focusIssueItem(SurveyResponseIssueSummaryItem item) {
    setState(() {
      _focusState = _focusState.focusQuestion(
        pageIndex: item.pageIndex,
        questionId: item.firstQuestionId,
      );
    });
  }

  void _selectEvidenceRequirement({
    required SurveyResponse response,
    required SurveyResponseSectionFlow sectionFlow,
    required SurveyEvidenceRequirementStatus status,
  }) {
    _focusEvidenceRequirementStatus(sectionFlow, status);
    _openEvidenceCaptureSheet(
      response: response,
      requirement: status.requirement,
    );
  }

  void _previousPage(int currentIndex) {
    if (currentIndex == 0) {
      return;
    }

    setState(() {
      _focusState = _focusState.selectPage(currentIndex - 1);
    });
  }

  void _nextPage(int currentIndex) {
    setState(() {
      _focusState = _focusState.selectPage(currentIndex + 1);
    });
  }

  void _handleInitialIntentAction({
    required SurveyResponseViewerIntent intent,
    required Survey survey,
    required SurveyResponse response,
    required SurveyResponseSessionSummary summary,
    required SurveyResponseEvidenceSummary evidenceSummary,
    required SurveyResponseSectionFlow sectionFlow,
  }) {
    if (intent.shouldFocusFirstAnswerIssue) {
      final target = SurveyResponseAnswerIssueFocusTarget.resolveFirst(
        sectionFlow: sectionFlow,
        validation: summary.validation,
      );
      if (target != null) {
        setState(() => _focusState = target.applyTo(_focusState));
      }
      return;
    }

    if (intent.shouldOpenEvidenceCapture) {
      final status = evidenceSummary.firstIncompleteRequirement;
      if (status != null) {
        _focusEvidenceRequirementStatus(sectionFlow, status);
        _openEvidenceCaptureSheet(
          response: response,
          requirement: status.requirement,
        );
        return;
      }

      _showResponseSnackBar(intent.detail);
      return;
    }

    if (intent.shouldReviewUpload) {
      _openUploadReviewSheet(
        intent: intent,
        survey: survey,
        response: response,
      );
      return;
    }

    if (intent.shouldPromptSubmit) {
      _submitResponse(
        response: response,
        summary: summary,
        evidenceSummary: evidenceSummary,
        sectionFlow: sectionFlow,
      );
      return;
    }

    _showResponseSnackBar(intent.detail);
  }

  void _openUploadReviewSheet({
    required SurveyResponseViewerIntent intent,
    required Survey survey,
    required SurveyResponse response,
  }) {
    final items = SurveyEvidenceSyncInsights(
      surveys: [survey],
      responses: [response],
    ).itemsNeedingAttention(limit: 8);

    if (items.isEmpty) {
      _showResponseSnackBar(intent.detail);
      return;
    }

    SurveyEvidenceUploadReviewSheet.show(
      context: context,
      items: items,
      focusedQuestionId: intent.focusQuestionId,
      activeUploadKeys: _activeEvidenceUploads.activeKeys,
      onItemSelected: (item) => _focusUploadReviewItem(
        survey: survey,
        response: response,
        item: item,
      ),
      onQueueUpload: _queueUploadReviewTask,
      onRetryUpload: _retryUploadReviewTask,
      onFixEvidence: (task) => _focusUploadReviewItem(
        survey: survey,
        response: response,
        item: task.item,
      ),
      onMonitorUpload: (task) {
        Navigator.of(context).pop();
        _showResponseSnackBar('${task.item.title}: ${task.item.stateLabel}');
      },
    );
  }

  void _focusUploadReviewItem({
    required Survey survey,
    required SurveyResponse response,
    required SurveyEvidenceSyncItem item,
  }) {
    final target = SurveyResponseUploadReviewFocusTarget.resolve(
      sectionFlow: SurveyResponseSectionFlow(
        survey: survey,
        response: response,
      ),
      item: item,
    );
    if (!target.canFocus) {
      _showResponseSnackBar(target.fallbackMessage);
      return;
    }

    if (mounted) {
      setState(() => _focusState = target.applyTo(_focusState));
      Navigator.of(context).pop();
    }
  }

  void _queueUploadReviewTask(SurveyEvidenceUploadTask task) {
    _runOrQueueUploadTask(task, fallbackMessage: 'queued for upload');
  }

  void _retryUploadReviewTask(SurveyEvidenceUploadTask task) {
    _runOrQueueUploadTask(task, fallbackMessage: 'retry queued');
  }

  Future<void> _runOrQueueUploadTask(
    SurveyEvidenceUploadTask task, {
    required String fallbackMessage,
  }) async {
    final uploader = widget.evidenceUploader;
    if (uploader == null) {
      _queueUploadTask(task, message: fallbackMessage);
      return;
    }

    if (_activeEvidenceUploads.isActive(task)) {
      Navigator.of(context).pop();
      _showResponseSnackBar('${task.item.title} is already uploading');
      return;
    }

    Navigator.of(context).pop();
    final result = await _evidenceUploadRunner(uploader).uploadTask(task);

    if (!mounted) {
      return;
    }
    if (result.alreadyActive) {
      _showResponseSnackBar('${task.item.title} is already uploading');
      return;
    }

    _showUploadExecutionSnackBar(result.execution!, task);
  }

  void _queueUploadTask(
    SurveyEvidenceUploadTask task, {
    required String message,
  }) {
    ref
        .read(surveyResponseProvider.notifier)
        .queueEvidenceUpload(
          responseId: task.responseId,
          evidenceId: task.evidenceId,
        );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    _showResponseSnackBar('${task.item.title} $message');
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

  void _openEvidenceCaptureSheet({
    required SurveyResponse response,
    required SurveyEvidenceRequirement requirement,
  }) {
    SurveyEvidenceCaptureSheet.show(
      context: context,
      requirement: requirement,
      collectorId: response.collectorId,
      collectorName: response.collectorName,
      captureRegistry: widget.captureRegistry,
      onCaptured: (evidence) {
        ref
            .read(surveyResponseProvider.notifier)
            .upsertEvidence(responseId: response.id, evidence: evidence);

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${requirement.labelOrFallback} saved'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _showResponseSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitResponse({
    required SurveyResponse response,
    required SurveyResponseSessionSummary summary,
    required SurveyResponseEvidenceSummary evidenceSummary,
    required SurveyResponseSectionFlow sectionFlow,
  }) {
    final submissionPlan = SurveyResponseSubmissionPlan.evaluate(
      summary: summary,
      evidenceSummary: evidenceSummary,
      sectionFlow: sectionFlow,
    );
    if (!submissionPlan.canSubmit) {
      _focusSubmissionBlocker(submissionPlan);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(submissionPlan.feedbackMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final surveys = ref.read(surveyProvider);
    final survey = surveys.firstWhere((s) => s.id == widget.surveyId);
    ref
        .read(surveyResponseProvider.notifier)
        .submitResponse(response.id, surveyVersionId: survey.activeVersionId);
    ref.read(surveyProvider.notifier).recordSurveyResponse(widget.surveyId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Survey response submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  void _focusSubmissionBlocker(SurveyResponseSubmissionPlan plan) {
    switch (plan.blocker) {
      case SurveyResponseSubmissionBlocker.answerIssue:
        final target = plan.answerTarget;
        if (target == null) {
          return;
        }
        setState(() => _focusState = target.applyTo(_focusState));
        return;
      case SurveyResponseSubmissionBlocker.evidenceIssue:
        final target = plan.evidenceTarget;
        if (target == null) {
          return;
        }
        setState(() => _focusState = target.applyTo(_focusState));
        return;
      case SurveyResponseSubmissionBlocker.none:
        return;
    }
  }

  String _focusEvidenceRequirementStatus(
    SurveyResponseSectionFlow sectionFlow,
    SurveyEvidenceRequirementStatus? status,
  ) {
    if (status == null) {
      return '';
    }

    final target = SurveyResponseEvidenceFocusTarget.resolve(
      sectionFlow: sectionFlow,
      status: status,
    );

    setState(() => _focusState = target.applyTo(_focusState));
    return target.locationSuffix;
  }
}
