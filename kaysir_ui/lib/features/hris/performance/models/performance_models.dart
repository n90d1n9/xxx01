enum PerformancePriority { low, medium, high }

enum GoalStatus { onTrack, atRisk, completed }

enum ReviewStatus { notStarted, inProgress, submitted, overdue }

enum CalibrationStatus { aligned, needsReview, disputed }

enum SuccessionReadiness { readyNow, readySoon, developing }

enum RetentionRiskLevel { low, medium, high }

class GoalProgress {
  final String id;
  final String employeeName;
  final String department;
  final String goal;
  final int progress;
  final DateTime dueDate;
  final GoalStatus status;

  const GoalProgress({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.goal,
    required this.progress,
    required this.dueDate,
    required this.status,
  });
}

class ReviewCycle {
  final String id;
  final String title;
  final String department;
  final int participantCount;
  final int submittedCount;
  final DateTime dueDate;
  final ReviewStatus status;

  const ReviewCycle({
    required this.id,
    required this.title,
    required this.department,
    required this.participantCount,
    required this.submittedCount,
    required this.dueDate,
    required this.status,
  });

  int get pendingCount {
    final value = participantCount - submittedCount;
    return value < 0 ? 0 : value;
  }

  double get completionRate {
    if (participantCount == 0) return 1;
    return submittedCount / participantCount;
  }
}

class CalibrationItem {
  final String id;
  final String employeeName;
  final String department;
  final String managerName;
  final String proposedRating;
  final String calibratedRating;
  final CalibrationStatus status;

  const CalibrationItem({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.managerName,
    required this.proposedRating,
    required this.calibratedRating,
    required this.status,
  });
}

class SuccessionCandidate {
  final String id;
  final String role;
  final String department;
  final String candidateName;
  final String sponsorName;
  final SuccessionReadiness readiness;
  final int readinessScore;

  const SuccessionCandidate({
    required this.id,
    required this.role,
    required this.department,
    required this.candidateName,
    required this.sponsorName,
    required this.readiness,
    required this.readinessScore,
  });
}

class RetentionRisk {
  final String id;
  final String employeeName;
  final String department;
  final String signal;
  final String actionOwner;
  final RetentionRiskLevel level;
  final DateTime reviewDate;

  const RetentionRisk({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.signal,
    required this.actionOwner,
    required this.level,
    required this.reviewDate,
  });
}

class PerformanceSummary {
  final int activeGoals;
  final int reviewsDue;
  final int calibrationFlags;
  final int successorsReady;
  final int highRetentionRisks;

  const PerformanceSummary({
    required this.activeGoals,
    required this.reviewsDue,
    required this.calibrationFlags,
    required this.successorsReady,
    required this.highRetentionRisks,
  });
}

class PerformanceRiskSummary {
  final int atRiskGoals;
  final int overdueReviews;
  final int calibrationExceptions;
  final int developingSuccessors;
  final int highRetentionRisks;
  final int dueWithinFourteenDays;

  const PerformanceRiskSummary({
    required this.atRiskGoals,
    required this.overdueReviews,
    required this.calibrationExceptions,
    required this.developingSuccessors,
    required this.highRetentionRisks,
    required this.dueWithinFourteenDays,
  });

  int get totalRisks =>
      atRiskGoals +
      overdueReviews +
      calibrationExceptions +
      developingSuccessors +
      highRetentionRisks;

  factory PerformanceRiskSummary.fromData({
    required List<GoalProgress> goals,
    required List<ReviewCycle> reviews,
    required List<CalibrationItem> calibration,
    required List<SuccessionCandidate> successors,
    required List<RetentionRisk> retention,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));

    return PerformanceRiskSummary(
      atRiskGoals:
          goals.where((item) => item.status == GoalStatus.atRisk).length,
      overdueReviews:
          reviews.where((item) => item.status == ReviewStatus.overdue).length,
      calibrationExceptions:
          calibration
              .where((item) => item.status != CalibrationStatus.aligned)
              .length,
      developingSuccessors:
          successors
              .where((item) => item.readiness != SuccessionReadiness.readyNow)
              .length,
      highRetentionRisks:
          retention
              .where((item) => item.level == RetentionRiskLevel.high)
              .length,
      dueWithinFourteenDays:
          goals
              .where(
                (item) =>
                    item.status != GoalStatus.completed &&
                    !item.dueDate.isAfter(dueThreshold),
              )
              .length +
          reviews
              .where(
                (item) =>
                    item.status != ReviewStatus.submitted &&
                    !item.dueDate.isAfter(dueThreshold),
              )
              .length +
          retention
              .where((item) => !item.reviewDate.isAfter(dueThreshold))
              .length,
    );
  }
}
