import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_status.dart';

class SurveyInsights {
  final List<Survey> surveys;

  const SurveyInsights(this.surveys);

  int get totalSurveys => surveys.length;

  int get totalQuestions =>
      surveys.fold(0, (total, survey) => total + survey.questions.length);

  int get requiredQuestions => surveys.fold(
    0,
    (total, survey) =>
        total + survey.questions.where((question) => question.required).length,
  );

  int get totalResponses =>
      surveys.fold(0, (total, survey) => total + survey.responseCount);

  int get targetResponses =>
      surveys.fold(0, (total, survey) => total + survey.targetResponses);

  int get liveSurveys => surveys.where((survey) => survey.status.isLive).length;

  int get draftSurveys =>
      surveys.where((survey) => survey.status == SurveyStatus.draft).length;

  int get completedSurveys =>
      surveys.where((survey) => survey.status.isFinal).length;

  double get responseProgress {
    if (targetResponses == 0) {
      return 0;
    }

    return (totalResponses / targetResponses).clamp(0, 1).toDouble();
  }

  double get averageQuestionsPerSurvey {
    if (surveys.isEmpty) {
      return 0;
    }

    return totalQuestions / surveys.length;
  }

  Map<SurveyStatus, int> get statusCounts {
    final counts = {for (final status in SurveyStatus.values) status: 0};

    for (final survey in surveys) {
      counts[survey.status] = (counts[survey.status] ?? 0) + 1;
    }

    return counts;
  }

  Map<QuestionType, int> get questionTypeCounts {
    final counts = {for (final type in QuestionType.values) type: 0};

    for (final survey in surveys) {
      for (final question in survey.questions) {
        counts[question.type] = (counts[question.type] ?? 0) + 1;
      }
    }

    return counts;
  }

  List<Survey> topSurveysByResponses({int limit = 3}) {
    final ranked = [
      ...surveys,
    ]..sort((left, right) => right.responseCount.compareTo(left.responseCount));
    return ranked.take(limit).toList();
  }

  List<SurveyAttentionItem> attentionItems({DateTime? now}) {
    final today = now ?? DateTime.now();
    final items = <SurveyAttentionItem>[];

    for (final survey in surveys) {
      if (survey.questions.isEmpty &&
          survey.status != SurveyStatus.archived &&
          survey.status != SurveyStatus.closed) {
        items.add(
          SurveyAttentionItem(
            survey: survey,
            reason: 'No questions configured',
            severity: SurveyAttentionSeverity.high,
          ),
        );
      }

      if (survey.status.isLive && survey.responseCount == 0) {
        items.add(
          SurveyAttentionItem(
            survey: survey,
            reason: 'Live with no responses',
            severity: SurveyAttentionSeverity.medium,
          ),
        );
      }

      final closesAt = survey.closesAt;
      if (closesAt != null &&
          survey.status.isLive &&
          closesAt.difference(today).inDays <= 3) {
        items.add(
          SurveyAttentionItem(
            survey: survey,
            reason: 'Closing soon',
            severity: SurveyAttentionSeverity.medium,
          ),
        );
      }
    }

    return items;
  }
}

class SurveyAttentionItem {
  final Survey survey;
  final String reason;
  final SurveyAttentionSeverity severity;

  const SurveyAttentionItem({
    required this.survey,
    required this.reason,
    required this.severity,
  });
}

enum SurveyAttentionSeverity { low, medium, high }
