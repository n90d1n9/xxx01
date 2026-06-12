import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_queue_insights.dart';
import 'package:ky_survey/logic/survey_evidence_sync_activity_summary.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';

void main() {
  group('SurveyEvidenceSyncActivitySummary', () {
    test('separates active and ready local evidence uploads', () {
      final survey = _survey();
      final responses = [
        _response(id: 'active-upload'),
        _response(id: 'ready-upload'),
      ];
      final evidenceSyncInsights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: responses,
      );
      final activeTask =
          SurveyEvidenceUploadPlanner(
            insights: evidenceSyncInsights,
          ).createPlan().uploadableTasks.firstWhere(
            (task) => task.evidenceId == 'evidence-active-upload',
          );

      final summary = SurveyEvidenceSyncActivitySummary.evaluate(
        evidenceSyncInsights: evidenceSyncInsights,
        activeEvidenceUploadKeys: {
          SurveyEvidenceUploadActivityTracker.keyFor(activeTask),
        },
      );

      expect(summary.state, SurveyEvidenceSyncActivityState.active);
      expect(summary.activeUploadCount, 1);
      expect(summary.readyUploadCount, 1);
      expect(summary.attentionCount, 0);
      expect(summary.title, 'Evidence upload running');
      expect(summary.detailLabel, '1 upload running | 1 upload ready');
    });

    test('deduplicates active queue entries and uploading evidence state', () {
      final survey = _survey();
      final response = _response(
        id: 'uploading',
        uploadStatus: SurveyAttachmentUploadStatus.uploading,
      );
      final evidenceSyncInsights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: [response],
      );
      final queueInsights = SurveyEvidenceUploadQueueInsights(
        queue: SurveyEvidenceUploadQueue(
          entries: [
            SurveyEvidenceUploadQueueEntry(
              id: 'uploading:evidence-uploading',
              surveyId: survey.id,
              responseId: response.id,
              evidenceId: 'evidence-uploading',
              action: SurveyEvidenceUploadAction.queueUpload,
              priority: 2,
              status: SurveyEvidenceUploadQueueStatus.uploading,
              createdAt: _now,
              updatedAt: _now,
            ),
          ],
        ),
        now: _now,
      );

      final summary = SurveyEvidenceSyncActivitySummary.evaluate(
        evidenceSyncInsights: evidenceSyncInsights,
        evidenceUploadQueueInsights: queueInsights,
      );

      expect(summary.activeUploadCount, 1);
      expect(summary.readyUploadCount, 0);
      expect(summary.state, SurveyEvidenceSyncActivityState.active);
    });
  });
}

final _now = DateTime(2026, 6, 10, 9);

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Evidence sync activity',
    createdAt: DateTime(2026),
    questions: const [],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'display-image',
        kind: SurveyEvidenceKind.image,
        label: 'Display image',
        requireUploaded: true,
      ),
    ],
  );
}

SurveyResponse _response({
  required String id,
  SurveyAttachmentUploadStatus uploadStatus =
      SurveyAttachmentUploadStatus.local,
}) {
  return SurveyResponse(
    id: id,
    surveyId: 'retail-audit',
    respondentId: 'participant-$id',
    respondentName: 'Participant $id',
    startedAt: _now.subtract(const Duration(minutes: 20)),
    status: SurveyResponseStatus.submitted,
    evidence: [
      SurveyEvidence.attachment(
        id: 'evidence-$id',
        attachment: SurveyAttachment(
          id: 'attachment-$id',
          type: SurveyAttachmentType.image,
          fileName: '$id.jpg',
          capturedAt: _now.subtract(const Duration(minutes: 10)),
          localPath: '/local/$id.jpg',
          uploadStatus: uploadStatus,
        ),
        metadata: const {'requirementId': 'display-image'},
      ),
    ],
  );
}
