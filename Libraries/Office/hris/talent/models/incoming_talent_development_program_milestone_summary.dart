import 'incoming_talent_development_program_milestone.dart';

class IncomingTalentDevelopmentProgramMilestoneSummary {
  final int totalCount;
  final int plannedCount;
  final int submittedCount;
  final int acceptedCount;
  final int revisionCount;
  final int dueSoonCount;
  final double averageScore;
  final String nextAction;

  const IncomingTalentDevelopmentProgramMilestoneSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.submittedCount,
    required this.acceptedCount,
    required this.revisionCount,
    required this.dueSoonCount,
    required this.averageScore,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentProgramMilestoneSummary.fromMilestones({
    required List<IncomingTalentDevelopmentProgramMilestone> milestones,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final plannedCount = _countStatus(
      milestones,
      IncomingTalentDevelopmentProgramMilestoneStatus.planned,
    );
    final submittedCount = _countStatus(
      milestones,
      IncomingTalentDevelopmentProgramMilestoneStatus.submitted,
    );
    final acceptedCount = _countStatus(
      milestones,
      IncomingTalentDevelopmentProgramMilestoneStatus.accepted,
    );
    final revisionCount = _countStatus(
      milestones,
      IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision,
    );
    final dueSoonCount =
        milestones
            .where(
              (milestone) =>
                  !milestone.isClosed &&
                  !milestone.dueDate.isAfter(dueThreshold),
            )
            .length;
    final scoreTotal = milestones.fold<int>(
      0,
      (total, milestone) => total + milestone.score,
    );

    return IncomingTalentDevelopmentProgramMilestoneSummary(
      totalCount: milestones.length,
      plannedCount: plannedCount,
      submittedCount: submittedCount,
      acceptedCount: acceptedCount,
      revisionCount: revisionCount,
      dueSoonCount: dueSoonCount,
      averageScore: milestones.isEmpty ? 0 : scoreTotal / milestones.length,
      nextAction: _nextAction(
        totalCount: milestones.length,
        plannedCount: plannedCount,
        submittedCount: submittedCount,
        revisionCount: revisionCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentDevelopmentProgramMilestone> milestones,
  IncomingTalentDevelopmentProgramMilestoneStatus status,
) {
  return milestones.where((milestone) => milestone.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int submittedCount,
  required int revisionCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Create milestone reviews from enrollments.';
  if (revisionCount > 0) return 'Resolve $revisionCount milestone revisions.';
  if (submittedCount > 0) return 'Review $submittedCount submitted milestones.';
  if (dueSoonCount > 0) return 'Check $dueSoonCount milestones due soon.';
  if (plannedCount > 0) return 'Collect evidence for $plannedCount milestones.';
  return 'Keep accepted milestones archived as evidence.';
}
