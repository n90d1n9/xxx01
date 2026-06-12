import 'incoming_talent_development_program_completion.dart';

class IncomingTalentDevelopmentProgramCompletionSummary {
  final int totalCount;
  final int credentialedCount;
  final int roleReadyCount;
  final int extensionCount;
  final int renewalDueCount;
  final double averageScore;
  final String nextAction;

  const IncomingTalentDevelopmentProgramCompletionSummary({
    required this.totalCount,
    required this.credentialedCount,
    required this.roleReadyCount,
    required this.extensionCount,
    required this.renewalDueCount,
    required this.averageScore,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentProgramCompletionSummary.fromCompletions({
    required List<IncomingTalentDevelopmentProgramCompletion> completions,
    required DateTime asOfDate,
  }) {
    final renewalThreshold = asOfDate.add(const Duration(days: 45));
    final credentialedCount = _countDecision(
      completions,
      IncomingTalentDevelopmentProgramCompletionDecision.credentialed,
    );
    final roleReadyCount = _countDecision(
      completions,
      IncomingTalentDevelopmentProgramCompletionDecision.roleReady,
    );
    final extensionCount = _countDecision(
      completions,
      IncomingTalentDevelopmentProgramCompletionDecision.extendProgram,
    );
    final renewalDueCount =
        completions
            .where(
              (completion) =>
                  completion.renewalDate != null &&
                  !completion.renewalDate!.isAfter(renewalThreshold),
            )
            .length;
    final scoreTotal = completions.fold<int>(
      0,
      (total, completion) => total + completion.score,
    );

    return IncomingTalentDevelopmentProgramCompletionSummary(
      totalCount: completions.length,
      credentialedCount: credentialedCount,
      roleReadyCount: roleReadyCount,
      extensionCount: extensionCount,
      renewalDueCount: renewalDueCount,
      averageScore: completions.isEmpty ? 0 : scoreTotal / completions.length,
      nextAction: _nextAction(
        totalCount: completions.length,
        roleReadyCount: roleReadyCount,
        extensionCount: extensionCount,
        renewalDueCount: renewalDueCount,
      ),
    );
  }
}

int _countDecision(
  List<IncomingTalentDevelopmentProgramCompletion> completions,
  IncomingTalentDevelopmentProgramCompletionDecision decision,
) {
  return completions
      .where((completion) => completion.decision == decision)
      .length;
}

String _nextAction({
  required int totalCount,
  required int roleReadyCount,
  required int extensionCount,
  required int renewalDueCount,
}) {
  if (totalCount == 0) return 'Close accepted milestones as credentials.';
  if (extensionCount > 0) {
    return 'Resolve $extensionCount program extension decisions.';
  }
  if (renewalDueCount > 0) {
    return 'Review $renewalDueCount credentials due for renewal.';
  }
  if (roleReadyCount > 0) {
    return 'Apply $roleReadyCount role-ready credentials to growth decisions.';
  }
  return 'Keep completion evidence current.';
}
