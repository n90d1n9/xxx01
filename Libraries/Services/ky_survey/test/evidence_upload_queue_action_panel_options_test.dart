import 'package:ky_survey/widgets/dashboard/survey_evidence_upload_queue_action_panel_options.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueueActionPanelOptions', () {
    test('keeps defaults compact for queue dashboard panels', () {
      const options = SurveyEvidenceUploadQueueActionPanelOptions();

      expect(options.runDueLimit, isNull);
      expect(options.enqueueLimit, isNull);
      expect(options.requeueFailedLimit, isNull);
      expect(options.pruneUploaded, isTrue);
      expect(options.pruneSkipped, isTrue);
      expect(options.showActionFeedback, isTrue);
      expect(options.visibleEntryLimit, 5);
      expect(options.enqueuePlanLabel, 'Queue ready');
    });

    test('copyWith updates labels and action tuning without losing fields', () {
      const options = SurveyEvidenceUploadQueueActionPanelOptions(
        runDueLimit: 4,
        terminalRetention: Duration(days: 7),
        enqueuePlanLabel: 'Add to queue',
      );

      final updated = options.copyWith(
        runDueLimit: 2,
        stopOnFailure: true,
        showActionFeedback: false,
        visibleEntryLimit: 8,
        runDueUploadsLabel: 'Run now',
      );

      expect(updated.runDueLimit, 2);
      expect(updated.terminalRetention, const Duration(days: 7));
      expect(updated.enqueuePlanLabel, 'Add to queue');
      expect(updated.stopOnFailure, isTrue);
      expect(updated.showActionFeedback, isFalse);
      expect(updated.visibleEntryLimit, 8);
      expect(updated.runDueUploadsLabel, 'Run now');
    });

    test('copyWith can clear nullable queue limits', () {
      const options = SurveyEvidenceUploadQueueActionPanelOptions(
        runDueLimit: 4,
        enqueueLimit: 3,
        requeueFailedLimit: 2,
        terminalRetention: Duration(days: 1),
      );

      final cleared = options.copyWith(
        runDueLimit: null,
        enqueueLimit: null,
        requeueFailedLimit: null,
        terminalRetention: null,
      );

      expect(cleared.runDueLimit, isNull);
      expect(cleared.enqueueLimit, isNull);
      expect(cleared.requeueFailedLimit, isNull);
      expect(cleared.terminalRetention, isNull);
    });
  });
}
