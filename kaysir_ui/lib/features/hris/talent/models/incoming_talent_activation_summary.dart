import 'incoming_talent_activation_plan.dart';

class IncomingTalentActivationSummary {
  final int totalCount;
  final int plannedCount;
  final int activeCount;
  final int completedCount;
  final int blockedCount;
  final int dueSoonCount;
  final int overdueCount;
  final int evidenceBackedCount;
  final int roleReadyCredentialCount;
  final int programExtensionRiskCount;
  final String nextAction;

  const IncomingTalentActivationSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.activeCount,
    required this.completedCount,
    required this.blockedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.evidenceBackedCount,
    required this.roleReadyCredentialCount,
    required this.programExtensionRiskCount,
    required this.nextAction,
  });

  factory IncomingTalentActivationSummary.fromPlans({
    required List<IncomingTalentActivationPlan> plans,
    required DateTime asOfDate,
  }) {
    final plannedCount =
        plans
            .where(
              (plan) => plan.status == IncomingTalentActivationStatus.planned,
            )
            .length;
    final activeCount =
        plans
            .where(
              (plan) => plan.status == IncomingTalentActivationStatus.active,
            )
            .length;
    final completedCount =
        plans
            .where(
              (plan) => plan.status == IncomingTalentActivationStatus.completed,
            )
            .length;
    final blockedCount =
        plans
            .where(
              (plan) => plan.status == IncomingTalentActivationStatus.blocked,
            )
            .length;
    final dueSoonCount = plans.where((plan) => plan.isDueSoon(asOfDate)).length;
    final overdueCount = plans.where((plan) => plan.isOverdue(asOfDate)).length;
    final evidenceBackedCount =
        plans.where((plan) => plan.developmentEvidenceCount > 0).length;
    final roleReadyCredentialCount = plans.fold<int>(
      0,
      (total, plan) => total + plan.roleReadyProgramCompletionCount,
    );
    final programExtensionRiskCount = plans.fold<int>(
      0,
      (total, plan) => total + plan.programCompletionExtensionCount,
    );

    return IncomingTalentActivationSummary(
      totalCount: plans.length,
      plannedCount: plannedCount,
      activeCount: activeCount,
      completedCount: completedCount,
      blockedCount: blockedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      evidenceBackedCount: evidenceBackedCount,
      roleReadyCredentialCount: roleReadyCredentialCount,
      programExtensionRiskCount: programExtensionRiskCount,
      nextAction: _nextAction(
        totalCount: plans.length,
        plannedCount: plannedCount,
        activeCount: activeCount,
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
  required int activeCount,
  required int blockedCount,
  required int dueSoonCount,
  required int overdueCount,
  required int programExtensionRiskCount,
}) {
  if (totalCount == 0) return 'Create activation plans from ready handoffs.';
  if (blockedCount > 0) return 'Unblock $blockedCount activation plans.';
  if (programExtensionRiskCount > 0) {
    return 'Resolve $programExtensionRiskCount activation release evidence risks.';
  }
  if (overdueCount > 0) return 'Review $overdueCount overdue activations.';
  if (dueSoonCount > 0) {
    return 'Launch $dueSoonCount activation plans due soon.';
  }
  if (plannedCount > 0) return 'Start $plannedCount planned activations.';
  if (activeCount > 0) return 'Track $activeCount active talent activations.';
  return 'Talent activations are complete.';
}
