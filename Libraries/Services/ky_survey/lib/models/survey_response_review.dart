enum SurveyResponseReviewStatus { pending, approved, rejected, needsFollowUp }

SurveyResponseReviewStatus surveyResponseReviewStatusFromJson(Object? value) {
  if (value is SurveyResponseReviewStatus) {
    return value;
  }

  if (value is String) {
    for (final status in SurveyResponseReviewStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
  }

  return SurveyResponseReviewStatus.pending;
}

extension SurveyResponseReviewStatusDetails on SurveyResponseReviewStatus {
  String get label {
    switch (this) {
      case SurveyResponseReviewStatus.pending:
        return 'Pending Review';
      case SurveyResponseReviewStatus.approved:
        return 'Approved';
      case SurveyResponseReviewStatus.rejected:
        return 'Rejected';
      case SurveyResponseReviewStatus.needsFollowUp:
        return 'Needs Follow-up';
    }
  }

  bool get isFinal {
    switch (this) {
      case SurveyResponseReviewStatus.approved:
      case SurveyResponseReviewStatus.rejected:
        return true;
      case SurveyResponseReviewStatus.pending:
      case SurveyResponseReviewStatus.needsFollowUp:
        return false;
    }
  }
}
