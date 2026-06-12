enum SurveyStatus {
  draft,
  review,
  published,
  collecting,
  analyzing,
  closed,
  archived,
}

SurveyStatus surveyStatusFromJson(Object? value) {
  if (value is SurveyStatus) {
    return value;
  }

  if (value is String) {
    for (final status in SurveyStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
  }

  return SurveyStatus.draft;
}

extension SurveyStatusDetails on SurveyStatus {
  String get label {
    switch (this) {
      case SurveyStatus.draft:
        return 'Draft';
      case SurveyStatus.review:
        return 'Review';
      case SurveyStatus.published:
        return 'Published';
      case SurveyStatus.collecting:
        return 'Collecting';
      case SurveyStatus.analyzing:
        return 'Analyzing';
      case SurveyStatus.closed:
        return 'Closed';
      case SurveyStatus.archived:
        return 'Archived';
    }
  }

  bool get isLive {
    switch (this) {
      case SurveyStatus.published:
      case SurveyStatus.collecting:
        return true;
      case SurveyStatus.draft:
      case SurveyStatus.review:
      case SurveyStatus.analyzing:
      case SurveyStatus.closed:
      case SurveyStatus.archived:
        return false;
    }
  }

  bool get isFinal {
    switch (this) {
      case SurveyStatus.closed:
      case SurveyStatus.archived:
        return true;
      case SurveyStatus.draft:
      case SurveyStatus.review:
      case SurveyStatus.published:
      case SurveyStatus.collecting:
      case SurveyStatus.analyzing:
        return false;
    }
  }
}
