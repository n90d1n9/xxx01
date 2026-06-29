import 'incoming_talent_activation_checkpoint.dart';

class IncomingTalentActivationCheckpointSummary {
  final int totalCount;
  final int onTrackCount;
  final int watchCount;
  final int blockedCount;
  final int lowConfidenceCount;
  final int evidenceBackedCount;
  final int roleReadyCredentialCount;
  final int programExtensionRiskCount;
  final double averageConfidence;
  final String nextAction;

  const IncomingTalentActivationCheckpointSummary({
    required this.totalCount,
    required this.onTrackCount,
    required this.watchCount,
    required this.blockedCount,
    required this.lowConfidenceCount,
    required this.evidenceBackedCount,
    required this.roleReadyCredentialCount,
    required this.programExtensionRiskCount,
    required this.averageConfidence,
    required this.nextAction,
  });

  factory IncomingTalentActivationCheckpointSummary.fromCheckpoints(
    List<IncomingTalentActivationCheckpoint> checkpoints,
  ) {
    final onTrackCount =
        checkpoints
            .where(
              (checkpoint) =>
                  checkpoint.health ==
                  IncomingTalentActivationCheckpointHealth.onTrack,
            )
            .length;
    final watchCount =
        checkpoints
            .where(
              (checkpoint) =>
                  checkpoint.health ==
                  IncomingTalentActivationCheckpointHealth.watch,
            )
            .length;
    final blockedCount =
        checkpoints
            .where(
              (checkpoint) =>
                  checkpoint.health ==
                  IncomingTalentActivationCheckpointHealth.blocked,
            )
            .length;
    final lowConfidenceCount =
        checkpoints
            .where((checkpoint) => checkpoint.confidenceScore <= 3)
            .length;
    final totalConfidence = checkpoints.fold<int>(
      0,
      (total, checkpoint) => total + checkpoint.confidenceScore,
    );
    final evidenceBackedCount =
        checkpoints
            .where((checkpoint) => checkpoint.developmentEvidenceCount > 0)
            .length;
    final roleReadyCredentialCount = checkpoints.fold<int>(
      0,
      (total, checkpoint) => total + checkpoint.roleReadyProgramCompletionCount,
    );
    final programExtensionRiskCount = checkpoints.fold<int>(
      0,
      (total, checkpoint) => total + checkpoint.programCompletionExtensionCount,
    );

    return IncomingTalentActivationCheckpointSummary(
      totalCount: checkpoints.length,
      onTrackCount: onTrackCount,
      watchCount: watchCount,
      blockedCount: blockedCount,
      lowConfidenceCount: lowConfidenceCount,
      evidenceBackedCount: evidenceBackedCount,
      roleReadyCredentialCount: roleReadyCredentialCount,
      programExtensionRiskCount: programExtensionRiskCount,
      averageConfidence:
          checkpoints.isEmpty ? 0 : totalConfidence / checkpoints.length,
      nextAction: _nextAction(
        totalCount: checkpoints.length,
        blockedCount: blockedCount,
        watchCount: watchCount,
        lowConfidenceCount: lowConfidenceCount,
        programExtensionRiskCount: programExtensionRiskCount,
        onTrackCount: onTrackCount,
      ),
    );
  }
}

String _nextAction({
  required int totalCount,
  required int blockedCount,
  required int watchCount,
  required int lowConfidenceCount,
  required int programExtensionRiskCount,
  required int onTrackCount,
}) {
  if (totalCount == 0) return 'Submit activation checkpoints.';
  if (blockedCount > 0) return 'Escalate $blockedCount blocked checkpoints.';
  if (programExtensionRiskCount > 0) {
    return 'Resolve $programExtensionRiskCount checkpoint release evidence risks.';
  }
  if (watchCount > 0) {
    return 'Review $watchCount activation checkpoints needing follow-up.';
  }
  if (lowConfidenceCount > 0) {
    return 'Coach $lowConfidenceCount low-confidence activations.';
  }
  return 'Keep $onTrackCount activation checkpoints on track.';
}
