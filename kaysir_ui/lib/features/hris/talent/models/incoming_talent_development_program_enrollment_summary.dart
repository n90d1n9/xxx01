import 'incoming_talent_development_program_enrollment.dart';

class IncomingTalentDevelopmentProgramEnrollmentSummary {
  final int totalCount;
  final int plannedCount;
  final int activeCount;
  final int watchCount;
  final int completedCount;
  final int dueSoonCount;
  final double averageProgressScore;
  final String nextAction;

  const IncomingTalentDevelopmentProgramEnrollmentSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.activeCount,
    required this.watchCount,
    required this.completedCount,
    required this.dueSoonCount,
    required this.averageProgressScore,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentProgramEnrollmentSummary.fromEnrollments({
    required List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final plannedCount = _countStatus(
      enrollments,
      IncomingTalentDevelopmentProgramEnrollmentStatus.planned,
    );
    final activeCount = _countStatus(
      enrollments,
      IncomingTalentDevelopmentProgramEnrollmentStatus.active,
    );
    final watchCount = _countStatus(
      enrollments,
      IncomingTalentDevelopmentProgramEnrollmentStatus.watch,
    );
    final completedCount = _countStatus(
      enrollments,
      IncomingTalentDevelopmentProgramEnrollmentStatus.completed,
    );
    final dueSoonCount =
        enrollments
            .where(
              (enrollment) =>
                  !enrollment.isClosed &&
                  !enrollment.nextReviewDate.isAfter(dueThreshold),
            )
            .length;
    final progressTotal = enrollments.fold<int>(
      0,
      (total, enrollment) => total + enrollment.progressScore,
    );

    return IncomingTalentDevelopmentProgramEnrollmentSummary(
      totalCount: enrollments.length,
      plannedCount: plannedCount,
      activeCount: activeCount,
      watchCount: watchCount,
      completedCount: completedCount,
      dueSoonCount: dueSoonCount,
      averageProgressScore:
          enrollments.isEmpty ? 0 : progressTotal / enrollments.length,
      nextAction: _nextAction(
        totalCount: enrollments.length,
        plannedCount: plannedCount,
        activeCount: activeCount,
        watchCount: watchCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
  IncomingTalentDevelopmentProgramEnrollmentStatus status,
) {
  return enrollments.where((enrollment) => enrollment.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int activeCount,
  required int watchCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Enroll IDP portfolios into programs.';
  if (watchCount > 0) return 'Stabilize $watchCount watch enrollments.';
  if (dueSoonCount > 0) return 'Review $dueSoonCount program enrollments.';
  if (plannedCount > 0) return 'Launch $plannedCount planned enrollments.';
  return 'Keep $activeCount active enrollments on cadence.';
}
