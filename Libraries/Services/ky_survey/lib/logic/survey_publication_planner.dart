import '../models/survey.dart';
import '../models/survey_status.dart';
import '../models/survey_version.dart';
import 'survey_version_audit.dart';
import 'survey_versioning.dart';

enum SurveyPublicationAction {
  statusOnly,
  publishInitialVersion,
  publishChangedVersion,
}

class SurveyPublicationPlan {
  final Survey survey;
  final SurveyStatus targetStatus;
  final SurveyVersionAudit audit;
  final SurveyPublicationAction action;

  const SurveyPublicationPlan({
    required this.survey,
    required this.targetStatus,
    required this.audit,
    required this.action,
  });

  bool get createsSnapshot =>
      action == SurveyPublicationAction.publishInitialVersion ||
      action == SurveyPublicationAction.publishChangedVersion;

  SurveyVersion? get activeVersion => audit.activeVersion;

  String get label {
    switch (action) {
      case SurveyPublicationAction.statusOnly:
        return targetStatus == SurveyStatus.published
            ? 'Use active version'
            : 'Update status';
      case SurveyPublicationAction.publishInitialVersion:
        return 'Publish v1';
      case SurveyPublicationAction.publishChangedVersion:
        return 'Publish v${audit.nextVersionNumber}';
    }
  }

  String get detail {
    switch (action) {
      case SurveyPublicationAction.statusOnly:
        return targetStatus == SurveyStatus.published
            ? 'Draft matches the active published version.'
            : 'No published snapshot is needed for this status.';
      case SurveyPublicationAction.publishInitialVersion:
        return 'Create the first immutable survey snapshot.';
      case SurveyPublicationAction.publishChangedVersion:
        return 'Create a new snapshot for ${audit.changes.length} unpublished changes.';
    }
  }
}

class SurveyPublicationPlanner {
  const SurveyPublicationPlanner._();

  static SurveyPublicationPlan plan({
    required Survey survey,
    required SurveyStatus targetStatus,
  }) {
    final audit = SurveyVersionAudit.evaluate(survey);
    final action = _actionFor(targetStatus: targetStatus, audit: audit);

    return SurveyPublicationPlan(
      survey: survey,
      targetStatus: targetStatus,
      audit: audit,
      action: action,
    );
  }

  static Survey applyStatusChange({
    required Survey survey,
    required SurveyStatus targetStatus,
    DateTime? changedAt,
  }) {
    final timestamp = changedAt ?? DateTime.now();
    final plan = SurveyPublicationPlanner.plan(
      survey: survey,
      targetStatus: targetStatus,
    );
    final statusUpdated = survey.copyWith(
      status: targetStatus,
      publishedAt: targetStatus.isLive && survey.publishedAt == null
          ? timestamp
          : survey.publishedAt,
      updatedAt: timestamp,
    );

    if (plan.createsSnapshot) {
      return SurveyVersioning.publishSnapshot(
        survey: statusUpdated,
        publishedAt: timestamp,
      );
    }

    final activeVersion = plan.activeVersion;
    if (targetStatus == SurveyStatus.published && activeVersion != null) {
      return statusUpdated.copyWith(
        activeVersionId: activeVersion.id,
        currentVersion: activeVersion.versionNumber,
      );
    }

    return statusUpdated;
  }

  static SurveyPublicationAction _actionFor({
    required SurveyStatus targetStatus,
    required SurveyVersionAudit audit,
  }) {
    if (targetStatus != SurveyStatus.published) {
      return SurveyPublicationAction.statusOnly;
    }

    if (!audit.hasPublishedVersion) {
      return SurveyPublicationAction.publishInitialVersion;
    }

    if (audit.hasUnpublishedChanges) {
      return SurveyPublicationAction.publishChangedVersion;
    }

    return SurveyPublicationAction.statusOnly;
  }
}
