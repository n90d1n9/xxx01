import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_upload_planner.dart';
import '../../logic/survey_evidence_upload_queue_actions.dart';
import '../../logic/survey_evidence_upload_queue_action_feedback.dart';
import '../../logic/survey_evidence_upload_service.dart';
import 'survey_dashboard_shared.dart';
import 'survey_evidence_upload_queue_feedback_banner.dart';
import 'survey_evidence_upload_queue_action_panel_options.dart';
import 'survey_evidence_upload_queue_status_panel.dart';

typedef SurveyEvidenceUploadQueueActionError =
    void Function(Object error, StackTrace stackTrace);

class SurveyEvidenceUploadQueueActionPanel extends StatefulWidget {
  final SurveyEvidenceUploadQueueActionController controller;
  final SurveyEvidenceUploadPlan plan;
  final SurveyEvidenceUploadObserver? uploadObserver;
  final ValueChanged<SurveyEvidenceUploadQueueActionState>? onStateChanged;
  final ValueChanged<SurveyEvidenceUploadQueueActionResult>? onActionComplete;
  final SurveyEvidenceUploadQueueActionError? onActionError;
  final int? runDueLimit;
  final int? enqueueLimit;
  final int? requeueFailedLimit;
  final bool stopOnFailure;
  final bool resetFailedAttemptCount;
  final Duration? terminalRetention;
  final bool pruneUploaded;
  final bool pruneSkipped;
  final bool pruneFailed;
  final bool showActionFeedback;
  final int visibleEntryLimit;
  final String enqueuePlanLabel;
  final String runDueUploadsLabel;
  final String maintainQueueLabel;
  final String requeueFailedUploadsLabel;

  const SurveyEvidenceUploadQueueActionPanel({
    super.key,
    required this.controller,
    required this.plan,
    this.uploadObserver,
    this.onStateChanged,
    this.onActionComplete,
    this.onActionError,
    this.runDueLimit,
    this.enqueueLimit,
    this.requeueFailedLimit,
    this.stopOnFailure = false,
    this.resetFailedAttemptCount = false,
    this.terminalRetention,
    this.pruneUploaded = true,
    this.pruneSkipped = true,
    this.pruneFailed = false,
    this.showActionFeedback = true,
    this.visibleEntryLimit = 5,
    this.enqueuePlanLabel = 'Queue ready',
    this.runDueUploadsLabel = 'Run due',
    this.maintainQueueLabel = 'Maintain',
    this.requeueFailedUploadsLabel = 'Requeue failed',
  });

  SurveyEvidenceUploadQueueActionPanel.withOptions({
    Key? key,
    required SurveyEvidenceUploadQueueActionController controller,
    required SurveyEvidenceUploadPlan plan,
    SurveyEvidenceUploadObserver? uploadObserver,
    ValueChanged<SurveyEvidenceUploadQueueActionState>? onStateChanged,
    ValueChanged<SurveyEvidenceUploadQueueActionResult>? onActionComplete,
    SurveyEvidenceUploadQueueActionError? onActionError,
    SurveyEvidenceUploadQueueActionPanelOptions options =
        const SurveyEvidenceUploadQueueActionPanelOptions(),
  }) : this(
         key: key,
         controller: controller,
         plan: plan,
         uploadObserver: uploadObserver,
         onStateChanged: onStateChanged,
         onActionComplete: onActionComplete,
         onActionError: onActionError,
         runDueLimit: options.runDueLimit,
         enqueueLimit: options.enqueueLimit,
         requeueFailedLimit: options.requeueFailedLimit,
         stopOnFailure: options.stopOnFailure,
         resetFailedAttemptCount: options.resetFailedAttemptCount,
         terminalRetention: options.terminalRetention,
         pruneUploaded: options.pruneUploaded,
         pruneSkipped: options.pruneSkipped,
         pruneFailed: options.pruneFailed,
         showActionFeedback: options.showActionFeedback,
         visibleEntryLimit: options.visibleEntryLimit,
         enqueuePlanLabel: options.enqueuePlanLabel,
         runDueUploadsLabel: options.runDueUploadsLabel,
         maintainQueueLabel: options.maintainQueueLabel,
         requeueFailedUploadsLabel: options.requeueFailedUploadsLabel,
       );

  @override
  State<SurveyEvidenceUploadQueueActionPanel> createState() =>
      _SurveyEvidenceUploadQueueActionPanelState();
}

class _SurveyEvidenceUploadQueueActionPanelState
    extends State<SurveyEvidenceUploadQueueActionPanel> {
  SurveyEvidenceUploadQueueActionState? _state;
  SurveyEvidenceUploadQueueAction? _runningAction;
  SurveyEvidenceUploadQueueActionFeedback? _feedback;
  Object? _loadError;

  bool get _isRunning => _runningAction != null;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void didUpdateWidget(
    covariant SurveyEvidenceUploadQueueActionPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _loadState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) {
      if (_loadError != null) {
        return _QueueActionMessage(
          icon: Icons.error_outline,
          title: 'Queue unavailable',
          subtitle: 'Evidence upload queue status could not be loaded.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh_outlined,
          onPressed: _isRunning ? null : _loadState,
        );
      }

      return const SurveyEmptyState(
        icon: Icons.sync_outlined,
        title: 'Loading upload queue',
        subtitle: 'Evidence upload queue status is being prepared.',
      );
    }

    final canEnqueue =
        state.queue.isEmpty && widget.plan.uploadableTasks.isNotEmpty;
    final panel = canEnqueue
        ? _QueueActionMessage(
            icon: Icons.cloud_upload_outlined,
            title: 'Queue ready evidence',
            subtitle:
                '${widget.plan.uploadableTasks.length} evidence uploads are ready to queue.',
            actionLabel: widget.enqueuePlanLabel,
            actionIcon: Icons.cloud_upload_outlined,
            onPressed: _isRunning ? null : _enqueuePlan,
          )
        : SurveyEvidenceUploadQueueStatusPanel(
            insights: state.insights,
            visibleEntryLimit: widget.visibleEntryLimit,
            runDueUploadsLabel: widget.runDueUploadsLabel,
            maintainQueueLabel: widget.maintainQueueLabel,
            requeueFailedUploadsLabel: widget.requeueFailedUploadsLabel,
            onRunDueUploads: _isRunning || state.insights.dueCount == 0
                ? null
                : _runDue,
            onMaintainQueue: _isRunning ? null : _maintainQueue,
            onRequeueFailedUploads:
                _isRunning || state.insights.failedCount == 0
                ? null
                : _requeueFailed,
          );

    if (!_isRunning) {
      return _withFeedback(panel);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          minHeight: 3,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 10),
        _withFeedback(panel),
      ],
    );
  }

  Widget _withFeedback(Widget panel) {
    final feedback = _feedback;
    if (!widget.showActionFeedback || feedback == null) {
      return panel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurveyEvidenceUploadQueueFeedbackBanner(
          feedback: feedback,
          onDismiss: () => setState(() => _feedback = null),
        ),
        const SizedBox(height: 10),
        panel,
      ],
    );
  }

  Future<void> _loadState() async {
    setState(() {
      _runningAction = SurveyEvidenceUploadQueueAction.loadState;
      _feedback = null;
      _loadError = null;
    });

    try {
      final state = await widget.controller.loadState();
      if (!mounted) {
        return;
      }
      setState(() {
        _state = state;
        _runningAction = null;
      });
      widget.onStateChanged?.call(state);
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error;
        _runningAction = null;
      });
      widget.onActionError?.call(error, stackTrace);
    }
  }

  Future<void> _enqueuePlan() {
    return _runAction(
      SurveyEvidenceUploadQueueAction.enqueuePlan,
      () => widget.controller.enqueuePlan(
        widget.plan,
        limit: widget.enqueueLimit,
      ),
    );
  }

  Future<void> _runDue() {
    return _runAction(
      SurveyEvidenceUploadQueueAction.runDueUploads,
      () => widget.controller.runDueUploads(
        widget.plan,
        limit: widget.runDueLimit,
        stopOnFailure: widget.stopOnFailure,
        observer: widget.uploadObserver,
      ),
    );
  }

  Future<void> _maintainQueue() {
    return _runAction(
      SurveyEvidenceUploadQueueAction.maintainQueue,
      () => widget.controller.maintainQueue(
        terminalRetention: widget.terminalRetention,
        pruneUploaded: widget.pruneUploaded,
        pruneSkipped: widget.pruneSkipped,
        pruneFailed: widget.pruneFailed,
      ),
    );
  }

  Future<void> _requeueFailed() {
    return _runAction(
      SurveyEvidenceUploadQueueAction.requeueFailedUploads,
      () => widget.controller.requeueFailedUploads(
        limit: widget.requeueFailedLimit,
        resetAttemptCount: widget.resetFailedAttemptCount,
      ),
    );
  }

  Future<void> _runAction(
    SurveyEvidenceUploadQueueAction action,
    Future<SurveyEvidenceUploadQueueActionResult> Function() run,
  ) async {
    setState(() {
      _runningAction = action;
      _feedback = null;
      _loadError = null;
    });

    try {
      final result = await run();
      if (!mounted) {
        return;
      }
      setState(() {
        _state = result;
        _feedback = SurveyEvidenceUploadQueueActionFeedback.fromResult(result);
        _runningAction = null;
      });
      widget.onStateChanged?.call(result);
      widget.onActionComplete?.call(result);
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = SurveyEvidenceUploadQueueActionFeedback.fromError(
          action: action,
          error: error,
        );
        _runningAction = null;
      });
      widget.onActionError?.call(error, stackTrace);
    }
  }
}

class _QueueActionMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onPressed;

  const _QueueActionMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 14,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              icon: Icon(actionIcon, size: 18),
              label: Text(actionLabel),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
