import 'package:ky_survey/logic/survey_version_audit.dart';
import 'package:ky_survey/logic/survey_versioning.dart';
import 'package:ky_survey/models/option.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyVersionAudit', () {
    test('reports draft-only surveys without changes', () {
      final survey = Survey(
        id: 'draft',
        title: 'Draft',
        description: 'No snapshot',
        createdAt: DateTime(2026),
        questions: const [],
      );

      final audit = SurveyVersionAudit.evaluate(survey);

      expect(audit.hasPublishedVersion, isFalse);
      expect(audit.activeVersion, isNull);
      expect(audit.hasUnpublishedChanges, isFalse);
      expect(audit.nextVersionNumber, 1);
    });

    test('sorts versions by newest and reports the next version number', () {
      final v1 = SurveyVersioning.publishSnapshot(
        survey: _survey(title: 'Version 1'),
        publishedAt: DateTime(2026, 1, 1),
      );
      final v2 = SurveyVersioning.publishSnapshot(
        survey: v1.copyWith(title: 'Version 2'),
        publishedAt: DateTime(2026, 1, 2),
      );

      final audit = SurveyVersionAudit.evaluate(v2);

      expect(audit.versions.map((version) => version.versionNumber), [2, 1]);
      expect(audit.activeVersion?.id, v2.activeVersionId);
      expect(audit.nextVersionNumber, 3);
      expect(audit.hasUnpublishedChanges, isFalse);
    });

    test('detects metadata, section, and question drift', () {
      final published = SurveyVersioning.publishSnapshot(
        survey: _survey(title: 'Published'),
        publishedAt: DateTime(2026, 1, 1),
      );
      final editedQuestion = published.questions.first.copyWith(
        text: 'Edited required choice',
      );
      final edited = published.copyWith(
        title: 'Edited',
        sections: [
          published.sections.first.copyWith(title: 'Edited Section'),
          const SurveySection(id: 'extra', title: 'Extra'),
        ],
        questions: [
          editedQuestion,
          Question(
            id: 'q3',
            text: 'New notes',
            type: QuestionType.multiLineText,
            required: false,
          ),
        ],
      );

      final audit = SurveyVersionAudit.evaluate(edited);
      final changeTypes = audit.changes.map((change) => change.type).toSet();

      expect(audit.hasUnpublishedChanges, isTrue);
      expect(changeTypes, contains(SurveyVersionChangeType.titleChanged));
      expect(changeTypes, contains(SurveyVersionChangeType.sectionChanged));
      expect(changeTypes, contains(SurveyVersionChangeType.sectionAdded));
      expect(changeTypes, contains(SurveyVersionChangeType.questionChanged));
      expect(changeTypes, contains(SurveyVersionChangeType.questionAdded));
      expect(changeTypes, contains(SurveyVersionChangeType.questionRemoved));
    });

    test('ignores transient answers but detects reordered questions', () {
      final published = SurveyVersioning.publishSnapshot(
        survey: _survey(title: 'Published'),
        publishedAt: DateTime(2026, 1, 1),
      );
      final withTransientAnswer = published.copyWith(
        questions: [
          published.questions.first.withAnswer('preview'),
          published.questions.last,
        ],
      );
      final reordered = published.copyWith(
        questions: [published.questions.last, published.questions.first],
      );

      final transientAudit = SurveyVersionAudit.evaluate(withTransientAnswer);
      final reorderAudit = SurveyVersionAudit.evaluate(reordered);

      expect(transientAudit.hasUnpublishedChanges, isFalse);
      expect(
        reorderAudit.changes.map((change) => change.type),
        contains(SurveyVersionChangeType.questionOrderChanged),
      );
    });
  });
}

Survey _survey({required String title}) {
  return Survey(
    id: 'version-audit',
    title: title,
    description: 'Snapshot audit',
    createdAt: DateTime(2026),
    sections: const [SurveySection(id: 'intro', title: 'Intro')],
    questions: [
      Question(
        id: 'q1',
        text: 'Required choice',
        type: QuestionType.singleChoice,
        required: true,
        sectionId: 'intro',
        options: [
          Option(id: 'yes', text: 'Yes'),
          Option(id: 'no', text: 'No'),
        ],
      ),
      Question(
        id: 'q2',
        text: 'Optional notes',
        type: QuestionType.multiLineText,
        required: false,
        sectionId: 'intro',
      ),
    ],
  );
}
