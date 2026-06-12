import 'package:ky_survey/logic/survey_publication_planner.dart';
import 'package:ky_survey/logic/survey_versioning.dart';
import 'package:ky_survey/models/option.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/models/survey_status.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyPublicationPlanner', () {
    test('creates the initial snapshot when publishing a draft', () {
      final survey = _survey();

      final plan = SurveyPublicationPlanner.plan(
        survey: survey,
        targetStatus: SurveyStatus.published,
      );
      final published = SurveyPublicationPlanner.applyStatusChange(
        survey: survey,
        targetStatus: SurveyStatus.published,
        changedAt: DateTime(2026, 1, 1, 10),
      );

      expect(plan.action, SurveyPublicationAction.publishInitialVersion);
      expect(plan.createsSnapshot, isTrue);
      expect(plan.label, 'Publish v1');
      expect(published.status, SurveyStatus.published);
      expect(published.currentVersion, 1);
      expect(published.activeVersionId, 'publication-v1');
      expect(published.versions, hasLength(1));
      expect(published.publishedAt, DateTime(2026, 1, 1, 10));
    });

    test('does not duplicate snapshots when publishing without changes', () {
      final firstPublish = SurveyPublicationPlanner.applyStatusChange(
        survey: _survey(),
        targetStatus: SurveyStatus.published,
        changedAt: DateTime(2026, 1, 1, 10),
      );

      final plan = SurveyPublicationPlanner.plan(
        survey: firstPublish,
        targetStatus: SurveyStatus.published,
      );
      final republished = SurveyPublicationPlanner.applyStatusChange(
        survey: firstPublish,
        targetStatus: SurveyStatus.published,
        changedAt: DateTime(2026, 1, 2, 10),
      );

      expect(plan.action, SurveyPublicationAction.statusOnly);
      expect(plan.createsSnapshot, isFalse);
      expect(plan.label, 'Use active version');
      expect(republished.versions, hasLength(1));
      expect(republished.currentVersion, 1);
      expect(republished.activeVersionId, firstPublish.activeVersionId);
      expect(republished.publishedAt, DateTime(2026, 1, 1, 10));
      expect(republished.updatedAt, DateTime(2026, 1, 2, 10));
    });

    test('creates a new snapshot when the draft changed after publish', () {
      final published = SurveyPublicationPlanner.applyStatusChange(
        survey: _survey(),
        targetStatus: SurveyStatus.published,
        changedAt: DateTime(2026, 1, 1, 10),
      );
      final edited = published.copyWith(
        questions: [
          ...published.questions,
          Question(
            id: 'q2',
            text: 'Extra notes',
            type: QuestionType.multiLineText,
            required: false,
          ),
        ],
      );

      final plan = SurveyPublicationPlanner.plan(
        survey: edited,
        targetStatus: SurveyStatus.published,
      );
      final republished = SurveyPublicationPlanner.applyStatusChange(
        survey: edited,
        targetStatus: SurveyStatus.published,
        changedAt: DateTime(2026, 1, 2, 10),
      );

      expect(plan.action, SurveyPublicationAction.publishChangedVersion);
      expect(plan.createsSnapshot, isTrue);
      expect(plan.label, 'Publish v2');
      expect(plan.detail, contains('1 unpublished changes'));
      expect(republished.versions, hasLength(2));
      expect(republished.currentVersion, 2);
      expect(republished.activeVersionId, 'publication-v2');
      expect(republished.activeVersion?.questions, hasLength(2));
      expect(republished.publishedAt, DateTime(2026, 1, 1, 10));
    });

    test('keeps non-publish status changes status-only', () {
      final published = SurveyVersioning.publishSnapshot(
        survey: _survey(),
        publishedAt: DateTime(2026, 1, 1, 10),
      );

      final plan = SurveyPublicationPlanner.plan(
        survey: published,
        targetStatus: SurveyStatus.collecting,
      );
      final collecting = SurveyPublicationPlanner.applyStatusChange(
        survey: published,
        targetStatus: SurveyStatus.collecting,
        changedAt: DateTime(2026, 1, 2, 10),
      );

      expect(plan.action, SurveyPublicationAction.statusOnly);
      expect(plan.detail, 'No published snapshot is needed for this status.');
      expect(collecting.status, SurveyStatus.collecting);
      expect(collecting.versions, hasLength(1));
      expect(collecting.activeVersionId, published.activeVersionId);
    });

    test('restores missing active version metadata from latest snapshot', () {
      final published = SurveyVersioning.publishSnapshot(
        survey: _survey(),
        publishedAt: DateTime(2026, 1, 1, 10),
      );
      final imported = Survey(
        id: published.id,
        title: published.title,
        description: published.description,
        createdAt: published.createdAt,
        sections: published.sections,
        questions: published.questions,
        publishedAt: published.publishedAt,
        versions: published.versions,
      );

      final republished = SurveyPublicationPlanner.applyStatusChange(
        survey: imported,
        targetStatus: SurveyStatus.published,
        changedAt: DateTime(2026, 1, 2, 10),
      );

      expect(republished.versions, hasLength(1));
      expect(republished.currentVersion, 1);
      expect(republished.activeVersionId, 'publication-v1');
    });
  });
}

Survey _survey() {
  return Survey(
    id: 'publication',
    title: 'Publication Survey',
    description: 'Publication workflow',
    createdAt: DateTime(2026),
    targetResponses: 20,
    sections: const [SurveySection(id: 'intro', title: 'Intro')],
    questions: [
      Question(
        id: 'q1',
        text: 'Ready?',
        type: QuestionType.singleChoice,
        required: true,
        sectionId: 'intro',
        options: [
          Option(id: 'yes', text: 'Yes'),
          Option(id: 'no', text: 'No'),
        ],
      ),
    ],
  );
}
