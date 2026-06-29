import 'incoming_talent_activation_follow_up.dart';

class IncomingTalentActivationFollowUpSummary {
  final int totalCount;
  final int plannedCount;
  final int inProgressCount;
  final int completedCount;
  final int blockedCount;
  final int dueSoonCount;
  final int overdueCount;
  final int evidenceBackedCount;
  final int roleReadyCredentialCount;
  final int programExtensionRiskCount;
  final String nextAction;

  const IncomingTalentActivationFollowUpSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.blockedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.evidenceBackedCount,
    required this.roleReadyCredentialCount,
    required this.programExtensionRiskCount,
    required this.nextAction,
  });

  factory IncomingTalentActivationFollowUpSummary.fromActions({
    required List<IncomingTalentActivationFollowUpAction> actions,
    required DateTime asOfDate,
  }) {
    final plannedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentActivationFollowUpStatus.planned,
            )
            .length;
    final inProgressCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentActivationFollowUpStatus.inProgress,
            )
            .length;
    final completedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentActivationFollowUpStatus.completed,
            )
            .length;
    final blockedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentActivationFollowUpStatus.blocked,
            )
            .length;
    final dueSoonCount =
        actions.where((action) => action.isDueSoon(asOfDate)).length;
    final overdueCount =
        actions.where((action) => action.isOverdue(asOfDate)).length;
    final evidenceBackedCount =
        actions.where((action) => action.developmentEvidenceCount > 0).length;
    final roleReadyCredentialCount = actions.fold<int>(
      0,
      (total, action) => total + action.roleReadyProgramCompletionCount,
    );
    final programExtensionRiskCount = actions.fold<int>(
      0,
      (total, action) => total + action.programCompletionExtensionCount,
    );

    return IncomingTalentActivationFollowUpSummary(
      totalCount: actions.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      completedCount: completedCount,
      blockedCount: blockedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      evidenceBackedCount: evidenceBackedCount,
      roleReadyCredentialCount: roleReadyCredentialCount,
      programExtensionRiskCount: programExtensionRiskCount,
      nextAction: _nextAction(
        totalCount: actions.length,
        plannedCount: plannedCount,
        inProgressCount: inProgressCount,
        blockedCount: blockedCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
        programExtensionRiskCount: programExtensionRiskCount,
      ),
    );
  }
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int inProgressCount,
  required int blockedCount,
  required int dueSoonCount,
  required int overdueCount,
  required int programExtensionRiskCount,
}) {
  if (totalCount == 0) return 'Create follow-up actions from checkpoints.';
  if (blockedCount > 0) return 'Unblock $blockedCount follow-up actions.';
  if (programExtensionRiskCount > 0) {
    return 'Close $programExtensionRiskCount follow-up release evidence risks.';
  }
  if (overdueCount > 0) return 'Close $overdueCount overdue follow-up actions.';
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount follow-up actions due soon.';
  }
  if (plannedCount > 0) return 'Start $plannedCount planned follow-up actions.';
  if (inProgressCount > 0) {
    return 'Track $inProgressCount follow-up actions in progress.';
  }
  return 'Activation follow-up actions are complete.';
}
