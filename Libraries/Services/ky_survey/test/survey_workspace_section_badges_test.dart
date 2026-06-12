import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/analytics/survey_response_quality_insights.dart';
import 'package:ky_survey/analytics/survey_response_review_insights.dart';
import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/models/answer.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_response_review.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_navigation.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_section_badges.dart';

void main() {
  group('SurveyWorkspaceSectionBadgeBuilder', () {
    test('builds module badges from operations, review, and sync signals', () {
      final survey = _survey();
      final responses = [
        _response(id: 'missing-answer'),
        _response(
          id: 'ready-upload',
          answer: 'Display looks good',
          evidenceStatus: SurveyAttachmentUploadStatus.local,
        ),
        _response(
          id: 'follow-up',
          answer: 'Needs a manager call',
          status: SurveyResponseStatus.submitted,
          reviewStatus: SurveyResponseReviewStatus.needsFollowUp,
        ),
      ];
      final qualityInsights = SurveyResponseQualityInsights(
        surveys: [survey],
        responses: responses,
      );

      final badges = SurveyWorkspaceSectionBadgeBuilder(
        responseSyncReadiness: SurveyResponseSyncReadinessInsights.evaluate(
          surveys: [survey],
          responses: responses,
          now: _now,
        ),
        evidenceSyncInsights: SurveyEvidenceSyncInsights(
          surveys: [survey],
          responses: responses,
        ),
        responseReviewInsights: SurveyResponseReviewInsights(
          surveys: [survey],
          responses: responses,
          qualityInsights: qualityInsights,
        ),
      ).build();

      expect(
        badges[SurveyWorkspaceSection.overview]?.tone,
        SurveyWorkspaceSectionBadgeTone.error,
      );
      expect(badges[SurveyWorkspaceSection.overview]?.label, '1');
      expect(
        badges[SurveyWorkspaceSection.fieldwork]?.tone,
        SurveyWorkspaceSectionBadgeTone.error,
      );
      expect(
        badges[SurveyWorkspaceSection.analytics]?.tone,
        SurveyWorkspaceSectionBadgeTone.error,
      );
      expect(
        badges[SurveyWorkspaceSection.reports]?.tone,
        SurveyWorkspaceSectionBadgeTone.success,
      );
      expect(badges[SurveyWorkspaceSection.reports]?.label, '1');
    });

    test('marks active evidence uploads as in-progress module badges', () {
      final survey = _survey();
      final responses = [
        _response(
          id: 'active-upload',
          answer: 'Display looks good',
          evidenceStatus: SurveyAttachmentUploadStatus.local,
          status: SurveyResponseStatus.submitted,
        ),
      ];
      final evidenceSyncInsights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: responses,
      );
      final activeTask = SurveyEvidenceUploadPlanner(
        insights: evidenceSyncInsights,
      ).createPlan().uploadableTasks.single;
      final qualityInsights = SurveyResponseQualityInsights(
        surveys: [survey],
        responses: responses,
      );

      final badges = SurveyWorkspaceSectionBadgeBuilder(
        responseSyncReadiness: SurveyResponseSyncReadinessInsights.evaluate(
          surveys: [survey],
          responses: responses,
          now: _now,
        ),
        evidenceSyncInsights: evidenceSyncInsights,
        responseReviewInsights: SurveyResponseReviewInsights(
          surveys: [survey],
          responses: responses,
          qualityInsights: qualityInsights,
        ),
        activeEvidenceUploadKeys: {
          SurveyEvidenceUploadActivityTracker.keyFor(activeTask),
        },
      ).build();

      expect(
        badges[SurveyWorkspaceSection.overview]?.tone,
        SurveyWorkspaceSectionBadgeTone.warning,
      );
      expect(badges[SurveyWorkspaceSection.overview]?.label, '1');
      expect(
        badges[SurveyWorkspaceSection.overview]?.tooltip,
        '1 evidence upload is running',
      );
      expect(
        badges[SurveyWorkspaceSection.reports]?.tone,
        SurveyWorkspaceSectionBadgeTone.warning,
      );
      expect(badges[SurveyWorkspaceSection.reports]?.label, '1');
      expect(
        badges[SurveyWorkspaceSection.reports]?.tooltip,
        '1 evidence upload is running',
      );
    });
  });
}

final _now = DateTime(2026, 6, 9, 9);

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Navigation badge rules',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'q1',
        text: 'What did you observe?',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
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
  String? answer,
  SurveyAttachmentUploadStatus? evidenceStatus,
  SurveyResponseStatus status = SurveyResponseStatus.draft,
  SurveyResponseReviewStatus reviewStatus = SurveyResponseReviewStatus.pending,
}) {
  return SurveyResponse(
    id: id,
    surveyId: 'retail-audit',
    respondentId: 'participant-$id',
    respondentName: 'Participant $id',
    startedAt: _now.subtract(const Duration(minutes: 20)),
    submittedAt: status == SurveyResponseStatus.submitted
        ? _now.subtract(const Duration(minutes: 4))
        : null,
    status: status,
    reviewStatus: reviewStatus,
    answers: answer == null
        ? const []
        : [
            ResponseAnswer(
              questionId: 'q1',
              value: answer,
              answeredAt: _now.subtract(const Duration(minutes: 12)),
            ),
          ],
    evidence: evidenceStatus == null
        ? const []
        : [_imageEvidence(id: id, status: evidenceStatus)],
  );
}

SurveyEvidence _imageEvidence({
  required String id,
  required SurveyAttachmentUploadStatus status,
}) {
  return SurveyEvidence.attachment(
    id: 'evidence-$id',
    attachment: SurveyAttachment(
      id: 'attachment-$id',
      type: SurveyAttachmentType.image,
      fileName: '$id.jpg',
      capturedAt: _now.subtract(const Duration(minutes: 10)),
      localPath: '/local/$id.jpg',
      uploadStatus: status,
    ),
    metadata: const {'requirementId': 'display-image'},
  );
}
