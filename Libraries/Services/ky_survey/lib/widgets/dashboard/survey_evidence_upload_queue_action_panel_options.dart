class SurveyEvidenceUploadQueueActionPanelOptions {
  static const Object _unset = Object();

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

  const SurveyEvidenceUploadQueueActionPanelOptions({
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
  }) : assert(visibleEntryLimit > 0);

  SurveyEvidenceUploadQueueActionPanelOptions copyWith({
    Object? runDueLimit = _unset,
    Object? enqueueLimit = _unset,
    Object? requeueFailedLimit = _unset,
    bool? stopOnFailure,
    bool? resetFailedAttemptCount,
    Object? terminalRetention = _unset,
    bool? pruneUploaded,
    bool? pruneSkipped,
    bool? pruneFailed,
    bool? showActionFeedback,
    int? visibleEntryLimit,
    String? enqueuePlanLabel,
    String? runDueUploadsLabel,
    String? maintainQueueLabel,
    String? requeueFailedUploadsLabel,
  }) {
    return SurveyEvidenceUploadQueueActionPanelOptions(
      runDueLimit: identical(runDueLimit, _unset)
          ? this.runDueLimit
          : runDueLimit as int?,
      enqueueLimit: identical(enqueueLimit, _unset)
          ? this.enqueueLimit
          : enqueueLimit as int?,
      requeueFailedLimit: identical(requeueFailedLimit, _unset)
          ? this.requeueFailedLimit
          : requeueFailedLimit as int?,
      stopOnFailure: stopOnFailure ?? this.stopOnFailure,
      resetFailedAttemptCount:
          resetFailedAttemptCount ?? this.resetFailedAttemptCount,
      terminalRetention: identical(terminalRetention, _unset)
          ? this.terminalRetention
          : terminalRetention as Duration?,
      pruneUploaded: pruneUploaded ?? this.pruneUploaded,
      pruneSkipped: pruneSkipped ?? this.pruneSkipped,
      pruneFailed: pruneFailed ?? this.pruneFailed,
      showActionFeedback: showActionFeedback ?? this.showActionFeedback,
      visibleEntryLimit: visibleEntryLimit ?? this.visibleEntryLimit,
      enqueuePlanLabel: enqueuePlanLabel ?? this.enqueuePlanLabel,
      runDueUploadsLabel: runDueUploadsLabel ?? this.runDueUploadsLabel,
      maintainQueueLabel: maintainQueueLabel ?? this.maintainQueueLabel,
      requeueFailedUploadsLabel:
          requeueFailedUploadsLabel ?? this.requeueFailedUploadsLabel,
    );
  }
}
