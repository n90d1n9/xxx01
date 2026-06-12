import 'incoming_talent_readiness.dart';

class IncomingTalentReadinessSummary {
  final int totalCount;
  final int readyCount;
  final int attentionCount;
  final int blockedCount;
  final int missingChecklistCount;
  final int openChecklistCount;
  final int evidenceBackedCount;
  final int roleReadyCredentialCount;
  final int programCompletionExtensionCount;
  final double averageReadinessScore;
  final double checklistCompletionRate;
  final double developmentEvidenceCoverageRate;
  final String nextAction;

  const IncomingTalentReadinessSummary({
    required this.totalCount,
    required this.readyCount,
    required this.attentionCount,
    required this.blockedCount,
    required this.missingChecklistCount,
    required this.openChecklistCount,
    required this.evidenceBackedCount,
    required this.roleReadyCredentialCount,
    required this.programCompletionExtensionCount,
    required this.averageReadinessScore,
    required this.checklistCompletionRate,
    required this.developmentEvidenceCoverageRate,
    required this.nextAction,
  });

  factory IncomingTalentReadinessSummary.fromReadiness(
    List<IncomingTalentReadiness> readiness,
  ) {
    final readyCount =
        readiness
            .where((item) => item.status == IncomingTalentReadinessStatus.ready)
            .length;
    final blockedCount =
        readiness
            .where(
              (item) => item.status == IncomingTalentReadinessStatus.blocked,
            )
            .length;
    final attentionCount =
        readiness
            .where(
              (item) => item.status == IncomingTalentReadinessStatus.attention,
            )
            .length;
    final missingChecklistCount = readiness.fold<int>(
      0,
      (total, item) => total + item.missingRequiredChecklistCount,
    );
    final openChecklistCount = readiness.fold<int>(
      0,
      (total, item) => total + item.openRequiredChecklistCount,
    );
    final totalReadinessScore = readiness.fold<int>(
      0,
      (total, item) => total + item.readinessScore,
    );
    final totalChecklistCompletion = readiness.fold<double>(
      0,
      (total, item) => total + item.checklistCompletionRatio,
    );
    final evidenceBackedCount =
        readiness.where((item) => item.developmentEvidenceCount > 0).length;
    final roleReadyCredentialCount = readiness.fold<int>(
      0,
      (total, item) => total + item.roleReadyProgramCompletionCount,
    );
    final programCompletionExtensionCount = readiness.fold<int>(
      0,
      (total, item) => total + item.programCompletionExtensionCount,
    );

    return IncomingTalentReadinessSummary(
      totalCount: readiness.length,
      readyCount: readyCount,
      attentionCount: attentionCount,
      blockedCount: blockedCount,
      missingChecklistCount: missingChecklistCount,
      openChecklistCount: openChecklistCount,
      evidenceBackedCount: evidenceBackedCount,
      roleReadyCredentialCount: roleReadyCredentialCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      averageReadinessScore:
          readiness.isEmpty ? 0 : totalReadinessScore / readiness.length,
      checklistCompletionRate:
          readiness.isEmpty ? 0 : totalChecklistCompletion / readiness.length,
      developmentEvidenceCoverageRate:
          readiness.isEmpty ? 0 : evidenceBackedCount / readiness.length,
      nextAction: _summaryNextAction(
        totalCount: readiness.length,
        readyCount: readyCount,
        attentionCount: attentionCount,
        blockedCount: blockedCount,
        missingChecklistCount: missingChecklistCount,
        openChecklistCount: openChecklistCount,
        roleReadyCredentialCount: roleReadyCredentialCount,
        programCompletionExtensionCount: programCompletionExtensionCount,
      ),
    );
  }
}

String _summaryNextAction({
  required int totalCount,
  required int readyCount,
  required int attentionCount,
  required int blockedCount,
  required int missingChecklistCount,
  required int openChecklistCount,
  required int roleReadyCredentialCount,
  required int programCompletionExtensionCount,
}) {
  if (totalCount == 0) return 'Submit candidate handoffs for talent intake.';
  if (blockedCount > 0) {
    return 'Escalate $blockedCount incoming handoff blockers.';
  }
  if (missingChecklistCount > 0) {
    return 'Generate $missingChecklistCount missing required checklist tasks.';
  }
  if (openChecklistCount > 0) {
    return 'Close checklist work for $attentionCount incoming handoffs.';
  }
  if (programCompletionExtensionCount > 0) {
    final decisionLabel =
        programCompletionExtensionCount == 1 ? 'decision' : 'decisions';
    return 'Resolve $programCompletionExtensionCount program extension '
        '$decisionLabel.';
  }
  if (attentionCount > 0) {
    return 'Review $attentionCount incoming handoffs needing alignment.';
  }
  if (roleReadyCredentialCount > 0) {
    final credentialLabel =
        roleReadyCredentialCount == 1 ? 'credential' : 'credentials';
    return 'Apply $roleReadyCredentialCount role-ready '
        '$credentialLabel to incoming plans.';
  }
  return 'Release $readyCount incoming hires into talent plans.';
}
