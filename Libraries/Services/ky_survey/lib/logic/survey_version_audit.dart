import 'dart:convert';

import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_section.dart';
import '../models/survey_version.dart';

enum SurveyVersionChangeType {
  titleChanged,
  descriptionChanged,
  sectionAdded,
  sectionRemoved,
  sectionChanged,
  questionAdded,
  questionRemoved,
  questionChanged,
  questionOrderChanged,
  evidenceRequirementAdded,
  evidenceRequirementRemoved,
  evidenceRequirementChanged,
}

class SurveyVersionChange {
  final SurveyVersionChangeType type;
  final String label;
  final String detail;

  const SurveyVersionChange({
    required this.type,
    required this.label,
    required this.detail,
  });
}

class SurveyVersionAudit {
  final Survey survey;
  final SurveyVersion? activeVersion;
  final List<SurveyVersion> versions;
  final List<SurveyVersionChange> changes;

  const SurveyVersionAudit({
    required this.survey,
    required this.activeVersion,
    required this.versions,
    required this.changes,
  });

  factory SurveyVersionAudit.evaluate(Survey survey) {
    final versions = [
      ...survey.versions,
    ]..sort((left, right) => right.versionNumber.compareTo(left.versionNumber));
    final activeVersion = survey.activeVersion ?? _firstOrNull(versions);
    final changes = activeVersion == null
        ? const <SurveyVersionChange>[]
        : _changesBetween(activeVersion, survey);

    return SurveyVersionAudit(
      survey: survey,
      activeVersion: activeVersion,
      versions: versions,
      changes: changes,
    );
  }

  bool get hasPublishedVersion => versions.isNotEmpty;

  bool get hasUnpublishedChanges => changes.isNotEmpty;

  int get publishedVersionCount => versions.length;

  int get nextVersionNumber {
    if (versions.isEmpty) {
      return 1;
    }

    return versions.first.versionNumber + 1;
  }
}

List<SurveyVersionChange> _changesBetween(
  SurveyVersion version,
  Survey survey,
) {
  final changes = <SurveyVersionChange>[];

  if (version.title != survey.title) {
    changes.add(
      const SurveyVersionChange(
        type: SurveyVersionChangeType.titleChanged,
        label: 'Title changed',
        detail: 'Survey title differs from the active version.',
      ),
    );
  }

  if (version.description != survey.description) {
    changes.add(
      const SurveyVersionChange(
        type: SurveyVersionChangeType.descriptionChanged,
        label: 'Description changed',
        detail: 'Survey description differs from the active version.',
      ),
    );
  }

  changes.addAll(_sectionChanges(version.sections, survey.sections));
  changes.addAll(_questionChanges(version.questions, survey.questions));
  changes.addAll(
    _evidenceRequirementChanges(
      version.evidenceRequirements,
      survey.evidenceRequirements,
    ),
  );

  return changes;
}

List<SurveyVersionChange> _evidenceRequirementChanges(
  List<SurveyEvidenceRequirement> published,
  List<SurveyEvidenceRequirement> current,
) {
  final changes = <SurveyVersionChange>[];
  final publishedById = {
    for (final requirement in published) requirement.id: requirement,
  };
  final currentById = {
    for (final requirement in current) requirement.id: requirement,
  };

  for (final requirement in current) {
    final previous = publishedById[requirement.id];
    if (previous == null) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.evidenceRequirementAdded,
          label: 'Evidence requirement added',
          detail: requirement.labelOrFallback,
        ),
      );
    } else if (_requirementSignature(previous) !=
        _requirementSignature(requirement)) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.evidenceRequirementChanged,
          label: 'Evidence requirement changed',
          detail: requirement.labelOrFallback,
        ),
      );
    }
  }

  for (final requirement in published) {
    if (!currentById.containsKey(requirement.id)) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.evidenceRequirementRemoved,
          label: 'Evidence requirement removed',
          detail: requirement.labelOrFallback,
        ),
      );
    }
  }

  return changes;
}

List<SurveyVersionChange> _sectionChanges(
  List<SurveySection> published,
  List<SurveySection> current,
) {
  final changes = <SurveyVersionChange>[];
  final publishedById = {for (final section in published) section.id: section};
  final currentById = {for (final section in current) section.id: section};

  for (final section in current) {
    final previous = publishedById[section.id];
    if (previous == null) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.sectionAdded,
          label: 'Section added',
          detail: section.titleOrFallback,
        ),
      );
    } else if (_sectionSignature(previous) != _sectionSignature(section)) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.sectionChanged,
          label: 'Section changed',
          detail: section.titleOrFallback,
        ),
      );
    }
  }

  for (final section in published) {
    if (!currentById.containsKey(section.id)) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.sectionRemoved,
          label: 'Section removed',
          detail: section.titleOrFallback,
        ),
      );
    }
  }

  return changes;
}

List<SurveyVersionChange> _questionChanges(
  List<Question> published,
  List<Question> current,
) {
  final changes = <SurveyVersionChange>[];
  final publishedById = {
    for (final question in published) question.id: question,
  };
  final currentById = {for (final question in current) question.id: question};

  for (final question in current) {
    final previous = publishedById[question.id];
    if (previous == null) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.questionAdded,
          label: 'Question added',
          detail: _questionLabel(question),
        ),
      );
    } else if (_questionSignature(previous) != _questionSignature(question)) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.questionChanged,
          label: 'Question changed',
          detail: _questionLabel(question),
        ),
      );
    }
  }

  for (final question in published) {
    if (!currentById.containsKey(question.id)) {
      changes.add(
        SurveyVersionChange(
          type: SurveyVersionChangeType.questionRemoved,
          label: 'Question removed',
          detail: _questionLabel(question),
        ),
      );
    }
  }

  if (_sameQuestionSet(published, current) &&
      !_sameStringList(_ids(published), _ids(current))) {
    changes.add(
      const SurveyVersionChange(
        type: SurveyVersionChangeType.questionOrderChanged,
        label: 'Question order changed',
        detail: 'Question sequence differs from the active version.',
      ),
    );
  }

  return changes;
}

String _sectionSignature(SurveySection section) {
  return jsonEncode(section.toJson());
}

String _questionSignature(Question question) {
  return jsonEncode({
    'id': question.id,
    'text': question.text,
    'type': question.type.name,
    'required': question.required,
    'options': question.options
        ?.map((option) => {'id': option.id, 'text': option.text})
        .toList(),
    'hint': question.hint,
    'maxLength': question.maxLength,
    'minRating': question.minRating,
    'maxRating': question.maxRating,
    'sectionId': question.sectionId,
    'visibilityRules': question.visibilityRules
        .map((rule) => rule.toJson())
        .toList(),
  });
}

String _requirementSignature(SurveyEvidenceRequirement requirement) {
  return jsonEncode(requirement.toJson());
}

String _questionLabel(Question question) {
  final label = question.text.trim();
  return label.isEmpty ? 'Untitled question' : label;
}

bool _sameQuestionSet(List<Question> left, List<Question> right) {
  final leftIds = _ids(left).toSet();
  final rightIds = _ids(right).toSet();
  if (leftIds.length != rightIds.length) {
    return false;
  }

  return leftIds.containsAll(rightIds);
}

List<String> _ids(List<Question> questions) {
  return questions.map((question) => question.id).toList();
}

bool _sameStringList(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}

SurveyVersion? _firstOrNull(List<SurveyVersion> versions) {
  if (versions.isEmpty) {
    return null;
  }

  return versions.first;
}
