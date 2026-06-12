enum PeopleOpsPriority { low, medium, high }

enum WorkforcePlanStatus { open, interviewing, offer, fulfilled }

enum OnboardingStatus { notStarted, inProgress, blocked, done }

enum ComplianceStatus { valid, dueSoon, overdue }

class WorkforcePlan {
  final String id;
  final String role;
  final String department;
  final String location;
  final int openings;
  final int filled;
  final int candidateCount;
  final DateTime targetDate;
  final PeopleOpsPriority priority;
  final WorkforcePlanStatus status;

  const WorkforcePlan({
    required this.id,
    required this.role,
    required this.department,
    required this.location,
    required this.openings,
    required this.filled,
    required this.candidateCount,
    required this.targetDate,
    required this.priority,
    required this.status,
  });

  double get progress => openings == 0 ? 1 : filled / openings;

  int get remaining {
    final value = openings - filled;
    if (value < 0) return 0;
    if (value > openings) return openings;
    return value;
  }
}

class OnboardingMilestone {
  final String id;
  final String employeeName;
  final String role;
  final String department;
  final String buddyName;
  final DateTime startDate;
  final int tasksCompleted;
  final int taskCount;
  final OnboardingStatus status;

  const OnboardingMilestone({
    required this.id,
    required this.employeeName,
    required this.role,
    required this.department,
    required this.buddyName,
    required this.startDate,
    required this.tasksCompleted,
    required this.taskCount,
    required this.status,
  });

  double get progress => taskCount == 0 ? 1 : tasksCompleted / taskCount;

  int get remainingTasks {
    final value = taskCount - tasksCompleted;
    return value < 0 ? 0 : value;
  }
}

class ComplianceItem {
  final String id;
  final String title;
  final String owner;
  final String department;
  final DateTime dueDate;
  final ComplianceStatus status;
  final String requirement;

  const ComplianceItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.department,
    required this.dueDate,
    required this.status,
    required this.requirement,
  });
}

class EngagementPulse {
  final String id;
  final String department;
  final int score;
  final int responseRate;
  final String insight;
  final PeopleOpsPriority priority;

  const EngagementPulse({
    required this.id,
    required this.department,
    required this.score,
    required this.responseRate,
    required this.insight,
    required this.priority,
  });
}

class PeopleOpsSummary {
  final int openRoles;
  final int hiresNeeded;
  final int onboardingTasksDue;
  final int complianceRisks;
  final double averagePulseScore;

  const PeopleOpsSummary({
    required this.openRoles,
    required this.hiresNeeded,
    required this.onboardingTasksDue,
    required this.complianceRisks,
    required this.averagePulseScore,
  });
}

class PeopleOpsRiskSummary {
  final int highPriorityHiringPlans;
  final int blockedOnboarding;
  final int overdueCompliance;
  final int dueSoonCompliance;
  final int lowEngagementPulses;
  final int dueWithinFourteenDays;

  const PeopleOpsRiskSummary({
    required this.highPriorityHiringPlans,
    required this.blockedOnboarding,
    required this.overdueCompliance,
    required this.dueSoonCompliance,
    required this.lowEngagementPulses,
    required this.dueWithinFourteenDays,
  });

  int get totalRisks =>
      highPriorityHiringPlans +
      blockedOnboarding +
      overdueCompliance +
      dueSoonCompliance +
      lowEngagementPulses;

  factory PeopleOpsRiskSummary.fromData({
    required List<WorkforcePlan> workforcePlans,
    required List<OnboardingMilestone> onboarding,
    required List<ComplianceItem> compliance,
    required List<EngagementPulse> pulses,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));

    return PeopleOpsRiskSummary(
      highPriorityHiringPlans:
          workforcePlans
              .where(
                (item) =>
                    item.priority == PeopleOpsPriority.high &&
                    item.remaining > 0,
              )
              .length,
      blockedOnboarding:
          onboarding
              .where((item) => item.status == OnboardingStatus.blocked)
              .length,
      overdueCompliance:
          compliance
              .where((item) => item.status == ComplianceStatus.overdue)
              .length,
      dueSoonCompliance:
          compliance
              .where((item) => item.status == ComplianceStatus.dueSoon)
              .length,
      lowEngagementPulses:
          pulses
              .where(
                (item) =>
                    item.priority == PeopleOpsPriority.high || item.score < 70,
              )
              .length,
      dueWithinFourteenDays:
          workforcePlans
              .where(
                (item) =>
                    item.remaining > 0 &&
                    !item.targetDate.isAfter(dueThreshold),
              )
              .length +
          onboarding
              .where(
                (item) =>
                    item.status != OnboardingStatus.done &&
                    !item.startDate.isAfter(dueThreshold),
              )
              .length +
          compliance
              .where(
                (item) =>
                    item.status != ComplianceStatus.valid &&
                    !item.dueDate.isAfter(dueThreshold),
              )
              .length,
    );
  }
}
