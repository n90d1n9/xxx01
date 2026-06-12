import 'package:flutter/widgets.dart';

import '../../logic/survey_evidence_upload_queue_actions.dart';
import '../../logic/survey_evidence_upload_queue_coordinator.dart';
import '../../logic/survey_evidence_upload_retry_policy.dart';
import '../../logic/survey_evidence_upload_service.dart';
import 'survey_evidence_upload_queue_action_panel.dart';
import 'survey_evidence_upload_queue_action_panel_options.dart';
import 'survey_evidence_upload_queue_panel_slot.dart';

DateTime _defaultEvidenceUploadQueueDashboardBindingClock() => DateTime.now();

class SurveyEvidenceUploadQueueDashboardBinding {
  final SurveyEvidenceUploadQueueActionController controller;
  final SurveyEvidenceUploadObserver? uploadObserver;
  final ValueChanged<SurveyEvidenceUploadQueueActionState>? onStateChanged;
  final ValueChanged<SurveyEvidenceUploadQueueActionResult>? onActionComplete;
  final SurveyEvidenceUploadQueueActionError? onActionError;
  final SurveyEvidenceUploadQueueActionPanelOptions panelOptions;
  final bool showActionFeedback;
  final int visibleEntryLimit;

  const SurveyEvidenceUploadQueueDashboardBinding({
    required this.controller,
    this.uploadObserver,
    this.onStateChanged,
    this.onActionComplete,
    this.onActionError,
    this.panelOptions = const SurveyEvidenceUploadQueueActionPanelOptions(),
    this.showActionFeedback = true,
    this.visibleEntryLimit = 5,
  });

  factory SurveyEvidenceUploadQueueDashboardBinding.fromStore({
    required SurveyEvidenceUploadQueueStore store,
    required SurveyEvidenceUploader uploader,
    SurveyEvidenceUploadObserver? uploadObserver,
    ValueChanged<SurveyEvidenceUploadQueueActionState>? onStateChanged,
    ValueChanged<SurveyEvidenceUploadQueueActionResult>? onActionComplete,
    SurveyEvidenceUploadQueueActionError? onActionError,
    SurveyEvidenceUploadClock clock =
        _defaultEvidenceUploadQueueDashboardBindingClock,
    SurveyEvidenceUploadRetryPolicy uploadRetryPolicy =
        const SurveyEvidenceUploadRetryPolicy.none(),
    SurveyEvidenceUploadRetryPolicy queueRetryPolicy =
        const SurveyEvidenceUploadRetryPolicy.none(),
    SurveyEvidenceUploadRetryWait retryWait =
        defaultSurveyEvidenceUploadRetryWait,
    Duration staleUploadingAfter = const Duration(minutes: 30),
    SurveyEvidenceUploadQueueActionPanelOptions panelOptions =
        const SurveyEvidenceUploadQueueActionPanelOptions(),
    bool showActionFeedback = true,
    int visibleEntryLimit = 5,
  }) {
    return SurveyEvidenceUploadQueueDashboardBinding(
      controller: SurveyEvidenceUploadQueueActionController.fromStore(
        store: store,
        uploader: uploader,
        clock: clock,
        uploadRetryPolicy: uploadRetryPolicy,
        queueRetryPolicy: queueRetryPolicy,
        retryWait: retryWait,
        staleUploadingAfter: staleUploadingAfter,
      ),
      uploadObserver: uploadObserver,
      onStateChanged: onStateChanged,
      onActionComplete: onActionComplete,
      onActionError: onActionError,
      panelOptions: panelOptions,
      showActionFeedback: showActionFeedback,
      visibleEntryLimit: visibleEntryLimit,
    );
  }

  SurveyEvidenceUploadQueuePanelBuilder panelBuilder({
    SurveyEvidenceUploadObserver? fallbackObserver,
  }) {
    return (context, plan) {
      return SurveyEvidenceUploadQueueActionPanel.withOptions(
        controller: controller,
        plan: plan,
        uploadObserver: uploadObserver ?? fallbackObserver,
        onStateChanged: onStateChanged,
        onActionComplete: onActionComplete,
        onActionError: onActionError,
        options: _effectivePanelOptions,
      );
    };
  }

  SurveyEvidenceUploadQueueActionPanelOptions get _effectivePanelOptions {
    var options = panelOptions;
    if (!showActionFeedback) {
      options = options.copyWith(showActionFeedback: false);
    }
    if (visibleEntryLimit != 5) {
      options = options.copyWith(visibleEntryLimit: visibleEntryLimit);
    }
    return options;
  }
}

/// Resolves the dashboard upload queue panel from custom, binding, or legacy inputs.
class SurveyEvidenceUploadQueuePanelBuilderResolver {
  final SurveyEvidenceUploadQueuePanelBuilder? customBuilder;
  final SurveyEvidenceUploadQueueDashboardBinding? binding;
  final SurveyEvidenceUploadQueueActionController? legacyController;
  final SurveyEvidenceUploadObserver? legacyUploadObserver;
  final ValueChanged<SurveyEvidenceUploadQueueActionState>? onStateChanged;
  final ValueChanged<SurveyEvidenceUploadQueueActionResult>? onActionComplete;
  final SurveyEvidenceUploadQueueActionError? onActionError;

  const SurveyEvidenceUploadQueuePanelBuilderResolver({
    this.customBuilder,
    this.binding,
    this.legacyController,
    this.legacyUploadObserver,
    this.onStateChanged,
    this.onActionComplete,
    this.onActionError,
  });

  SurveyEvidenceUploadQueuePanelBuilder? resolve({
    SurveyEvidenceUploadObserver? fallbackObserver,
  }) {
    final customBuilder = this.customBuilder;
    if (customBuilder != null) {
      return customBuilder;
    }

    final binding = this.binding ?? _legacyBinding();
    if (binding == null) {
      return null;
    }

    return binding.panelBuilder(fallbackObserver: fallbackObserver);
  }

  SurveyEvidenceUploadQueueDashboardBinding? _legacyBinding() {
    final controller = legacyController;
    if (controller == null) {
      return null;
    }

    return SurveyEvidenceUploadQueueDashboardBinding(
      controller: controller,
      uploadObserver: legacyUploadObserver,
      onStateChanged: onStateChanged,
      onActionComplete: onActionComplete,
      onActionError: onActionError,
    );
  }
}
