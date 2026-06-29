import 'incoming_talent_growth_alignment_item.dart';

/// Summarizes training, career-path, and evidence alignment across IDP plans.
class IncomingTalentGrowthAlignmentSummary {
  final int totalCount;
  final int alignedCount;
  final int attentionCount;
  final int trainingGapCount;
  final int careerGapCount;
  final int evidenceGapCount;
  final int completedCount;
  final double alignmentRatio;
  final String nextAction;

  const IncomingTalentGrowthAlignmentSummary({
    required this.totalCount,
    required this.alignedCount,
    required this.attentionCount,
    required this.trainingGapCount,
    required this.careerGapCount,
    required this.evidenceGapCount,
    required this.completedCount,
    required this.alignmentRatio,
    required this.nextAction,
  });

  factory IncomingTalentGrowthAlignmentSummary.fromItems(
    List<IncomingTalentGrowthAlignmentItem> items,
  ) {
    final alignedCount =
        items
            .where(
              (item) =>
                  item.status == IncomingTalentGrowthAlignmentStatus.onTrack ||
                  item.status == IncomingTalentGrowthAlignmentStatus.completed,
            )
            .length;
    final attentionCount = items.where((item) => item.needsAttention).length;
    final trainingGapCount =
        items.where((item) => !item.hasTrainingEnrollment).length;
    final careerGapCount = items.where((item) => !item.hasCareerPath).length;
    final evidenceGapCount =
        items
            .where(
              (item) =>
                  item.status ==
                      IncomingTalentGrowthAlignmentStatus.needsEvidence ||
                  item.status == IncomingTalentGrowthAlignmentStatus.atRisk,
            )
            .length;
    final completedCount =
        items
            .where(
              (item) =>
                  item.status == IncomingTalentGrowthAlignmentStatus.completed,
            )
            .length;

    return IncomingTalentGrowthAlignmentSummary(
      totalCount: items.length,
      alignedCount: alignedCount,
      attentionCount: attentionCount,
      trainingGapCount: trainingGapCount,
      careerGapCount: careerGapCount,
      evidenceGapCount: evidenceGapCount,
      completedCount: completedCount,
      alignmentRatio: items.isEmpty ? 0 : alignedCount / items.length,
      nextAction: _nextAction(
        totalCount: items.length,
        attentionCount: attentionCount,
        trainingGapCount: trainingGapCount,
        careerGapCount: careerGapCount,
        evidenceGapCount: evidenceGapCount,
      ),
    );
  }
}

String _nextAction({
  required int totalCount,
  required int attentionCount,
  required int trainingGapCount,
  required int careerGapCount,
  required int evidenceGapCount,
}) {
  if (totalCount == 0) {
    return 'Create IDP portfolios before growth alignment.';
  }
  if (trainingGapCount > 0) {
    return 'Assign training for $trainingGapCount IDP portfolios.';
  }
  if (careerGapCount > 0) {
    return 'Create career paths for $careerGapCount IDP portfolios.';
  }
  if (evidenceGapCount > 0) {
    return 'Collect evidence for $evidenceGapCount growth alignments.';
  }
  if (attentionCount > 0) {
    return 'Review $attentionCount growth alignments needing attention.';
  }
  return 'Keep training and career paths aligned.';
}
