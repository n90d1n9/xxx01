import '../survey_settings.dart';
import 'survey_metadata.dart';
import 'survey_section.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final SurveyStatus status;
  final List<SurveySection> sections;
  final SurveySettings settings;
  final SurveyMetadata metadata;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.status = SurveyStatus.draft,
    required this.sections,
    required this.settings,
    required this.metadata,
  });
}

enum SurveyStatus {
  draft,
  published,
  closed,
  archived;

  String toJson() => name;
  static SurveyStatus fromJson(String json) => values.byName(json);
}

enum ResponseStatus {
  inProgress,
  completed,
  abandoned;

  String toJson() => name;
  static ResponseStatus fromJson(String json) => values.byName(json);
}
