import 'incoming_talent_development_intervention.dart';

class IncomingTalentDevelopmentInterventionSummary {
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int cancelledCount;
  final int criticalCount;
  final int dueSoonCount;
  final int activationFollowUpCount;
  final int releaseEvidenceBackedCount;
  final int releaseEvidenceRiskCount;
  final String nextAction;

  const IncomingTalentDevelopmentInterventionSummary({
    required this.totalCount,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    this.cancelledCount = 0,
    required this.criticalCount,
    required this.dueSoonCount,
    this.activationFollowUpCount = 0,
    this.releaseEvidenceBackedCount = 0,
    this.releaseEvidenceRiskCount = 0,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentInterventionSummary.fromActions({
    required List<IncomingTalentDevelopmentInterventionAction> actions,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final openCount = _countStatus(
      actions,
      IncomingTalentDevelopmentInterventionStatus.open,
    );
    final inProgressCount = _countStatus(
      actions,
      IncomingTalentDevelopmentInterventionStatus.inProgress,
    );
    final resolvedCount = _countStatus(
      actions,
      IncomingTalentDevelopmentInterventionStatus.resolved,
    );
    final cancelledCount = _countStatus(
      actions,
      IncomingTalentDevelopmentInterventionStatus.cancelled,
    );
    final activeActions = actions.where(_isActive).toList();
    final criticalCount =
        activeActions
            .where(
              (action) =>
                  action.priority ==
                  IncomingTalentDevelopmentInterventionPriority.critical,
            )
            .length;
    final dueSoonCount =
        activeActions
            .where((action) => !action.dueDate.isAfter(dueThreshold))
            .length;
    final activationFollowUpCount =
        actions
            .where((action) => action.activationFollowUpId.isNotEmpty)
            .length;
    final releaseEvidenceBackedCount =
        actions.where((action) => action.releaseEvidenceCount > 0).length;
    final releaseEvidenceRiskCount =
        activeActions.where((action) => action.hasReleaseEvidenceRisk).length;

    return IncomingTalentDevelopmentInterventionSummary(
      totalCount: actions.length,
      openCount: openCount,
      inProgressCount: inProgressCount,
      resolvedCount: resolvedCount,
      cancelledCount: cancelledCount,
      criticalCount: criticalCount,
      dueSoonCount: dueSoonCount,
      activationFollowUpCount: activationFollowUpCount,
      releaseEvidenceBackedCount: releaseEvidenceBackedCount,
      releaseEvidenceRiskCount: releaseEvidenceRiskCount,
      nextAction: _nextAction(
        totalCount: actions.length,
        openCount: openCount,
        criticalCount: criticalCount,
        dueSoonCount: dueSoonCount,
        releaseEvidenceRiskCount: releaseEvidenceRiskCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentDevelopmentInterventionAction> actions,
  IncomingTalentDevelopmentInterventionStatus status,
) {
  return actions.where((action) => action.status == status).length;
}

bool _isActive(IncomingTalentDevelopmentInterventionAction action) {
  return action.status !=
          IncomingTalentDevelopmentInterventionStatus.resolved &&
      action.status != IncomingTalentDevelopmentInterventionStatus.cancelled;
}

String _nextAction({
  required int totalCount,
  required int openCount,
  required int criticalCount,
  required int dueSoonCount,
  required int releaseEvidenceRiskCount,
}) {
  if (totalCount == 0) return 'Create interventions from risky talent sources.';
  if (releaseEvidenceRiskCount > 0) {
    return 'Close $releaseEvidenceRiskCount release evidence interventions.';
  }
  if (criticalCount > 0) {
    return 'Resolve $criticalCount critical development interventions.';
  }
  if (dueSoonCount > 0) {
    return 'Follow up $dueSoonCount interventions due soon.';
  }
  if (openCount > 0) {
    return 'Start $openCount open development interventions.';
  }
  return 'Keep development interventions moving to resolution.';
}
