import '../models/survey.dart';
import '../models/survey_response.dart';
import '../models/survey_response_quality.dart';
import '../models/survey_response_review.dart';
import 'survey_response_quality_insights.dart';

class SurveyResponseReviewInsights {
  final List<Survey> surveys;
  final List<SurveyResponse> responses;
  final SurveyResponseQualityInsights qualityInsights;

  const SurveyResponseReviewInsights({
    required this.surveys,
    required this.responses,
    required this.qualityInsights,
  });

  List<SurveyResponse> get reviewableResponses => responses
      .where((response) => response.status == SurveyResponseStatus.submitted)
      .toList(growable: false);

  int get pendingReviewCount => _count(SurveyResponseReviewStatus.pending);

  int get approvedCount => _count(SurveyResponseReviewStatus.approved);

  int get rejectedCount => _count(SurveyResponseReviewStatus.rejected);

  int get needsFollowUpCount =>
      _count(SurveyResponseReviewStatus.needsFollowUp);

  int get completedReviewCount => approvedCount + rejectedCount;

  double get reviewProgress {
    if (reviewableResponses.isEmpty) {
      return 0;
    }

    return completedReviewCount / reviewableResponses.length;
  }

  List<SurveyResponseReviewItem> reviewQueue({int limit = 6}) {
    final items = reviewableResponses
        .where((response) {
          return response.reviewStatus == SurveyResponseReviewStatus.pending ||
              response.reviewStatus == SurveyResponseReviewStatus.needsFollowUp;
        })
        .map(_itemForResponse)
        .whereType<SurveyResponseReviewItem>()
        .toList();

    items.sort((left, right) {
      final statusCompare = _statusRank(
        right.response.reviewStatus,
      ).compareTo(_statusRank(left.response.reviewStatus));
      if (statusCompare != 0) {
        return statusCompare;
      }

      final signalCompare = _strongestSeverityRank(
        right.signals,
      ).compareTo(_strongestSeverityRank(left.signals));
      if (signalCompare != 0) {
        return signalCompare;
      }

      return right.response.startedAt.compareTo(left.response.startedAt);
    });

    return items.take(limit).toList(growable: false);
  }

  List<SurveyResponseReviewSummary> get summaries {
    return surveys.map(summaryForSurvey).toList(growable: false);
  }

  SurveyResponseReviewSummary summaryForSurvey(Survey survey) {
    final surveyResponses = reviewableResponses
        .where((response) => response.surveyId == survey.id)
        .toList(growable: false);

    return SurveyResponseReviewSummary(
      survey: survey,
      submittedResponses: surveyResponses.length,
      pendingReview: surveyResponses
          .where(
            (response) =>
                response.reviewStatus == SurveyResponseReviewStatus.pending,
          )
          .length,
      approved: surveyResponses
          .where(
            (response) =>
                response.reviewStatus == SurveyResponseReviewStatus.approved,
          )
          .length,
      rejected: surveyResponses
          .where(
            (response) =>
                response.reviewStatus == SurveyResponseReviewStatus.rejected,
          )
          .length,
      needsFollowUp: surveyResponses
          .where(
            (response) =>
                response.reviewStatus ==
                SurveyResponseReviewStatus.needsFollowUp,
          )
          .length,
    );
  }

  Survey? surveyForResponse(SurveyResponse response) {
    return qualityInsights.surveyForResponse(response);
  }

  SurveyResponseReviewItem? _itemForResponse(SurveyResponse response) {
    final survey = surveyForResponse(response);
    if (survey == null) {
      return null;
    }

    return SurveyResponseReviewItem(
      survey: survey,
      response: response,
      signals: qualityInsights.signalsForResponse(response),
    );
  }

  int _count(SurveyResponseReviewStatus status) {
    return reviewableResponses
        .where((response) => response.reviewStatus == status)
        .length;
  }

  int _statusRank(SurveyResponseReviewStatus status) {
    switch (status) {
      case SurveyResponseReviewStatus.needsFollowUp:
        return 2;
      case SurveyResponseReviewStatus.pending:
        return 1;
      case SurveyResponseReviewStatus.approved:
      case SurveyResponseReviewStatus.rejected:
        return 0;
    }
  }

  int _strongestSeverityRank(List<SurveyResponseQualitySignal> signals) {
    if (signals.any(
      (signal) => signal.severity == SurveyResponseQualitySeverity.critical,
    )) {
      return 2;
    }

    if (signals.any(
      (signal) => signal.severity == SurveyResponseQualitySeverity.warning,
    )) {
      return 1;
    }

    return 0;
  }
}

class SurveyResponseReviewItem {
  final Survey survey;
  final SurveyResponse response;
  final List<SurveyResponseQualitySignal> signals;

  const SurveyResponseReviewItem({
    required this.survey,
    required this.response,
    required this.signals,
  });

  int get signalCount => signals.length;

  bool get hasCriticalSignal => signals.any(
    (signal) => signal.severity == SurveyResponseQualitySeverity.critical,
  );
}

class SurveyResponseReviewSummary {
  final Survey survey;
  final int submittedResponses;
  final int pendingReview;
  final int approved;
  final int rejected;
  final int needsFollowUp;

  const SurveyResponseReviewSummary({
    required this.survey,
    required this.submittedResponses,
    required this.pendingReview,
    required this.approved,
    required this.rejected,
    required this.needsFollowUp,
  });
}
