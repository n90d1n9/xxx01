enum TalentPriority { low, medium, high }

enum SkillGapStatus { strength, growing, gap }

enum LearningPlanStatus { planned, inProgress, completed, overdue }

enum CertificationStatus { active, expiring, expired }

enum MentorshipHealth { healthy, watch, blocked }

class SkillGap {
  final String id;
  final String employeeName;
  final String role;
  final String department;
  final String skill;
  final int currentLevel;
  final int targetLevel;
  final String mentorName;
  final SkillGapStatus status;

  const SkillGap({
    required this.id,
    required this.employeeName,
    required this.role,
    required this.department,
    required this.skill,
    required this.currentLevel,
    required this.targetLevel,
    required this.mentorName,
    required this.status,
  });

  double get progress => targetLevel == 0 ? 1 : currentLevel / targetLevel;

  int get levelGap {
    final value = targetLevel - currentLevel;
    return value < 0 ? 0 : value;
  }
}

class LearningPlan {
  final String id;
  final String title;
  final String audience;
  final String department;
  final DateTime dueDate;
  final int enrolledCount;
  final int completedCount;
  final LearningPlanStatus status;

  const LearningPlan({
    required this.id,
    required this.title,
    required this.audience,
    required this.department,
    required this.dueDate,
    required this.enrolledCount,
    required this.completedCount,
    required this.status,
  });

  double get completionRate {
    if (enrolledCount == 0) return 1;
    return completedCount / enrolledCount;
  }

  int get pendingCount {
    final value = enrolledCount - completedCount;
    return value < 0 ? 0 : value;
  }
}

class CertificationRecord {
  final String id;
  final String employeeName;
  final String certification;
  final String department;
  final DateTime expiryDate;
  final CertificationStatus status;

  const CertificationRecord({
    required this.id,
    required this.employeeName,
    required this.certification,
    required this.department,
    required this.expiryDate,
    required this.status,
  });
}

class MentorshipPair {
  final String id;
  final String mentorName;
  final String menteeName;
  final String department;
  final String focusArea;
  final int sessionsCompleted;
  final int sessionsPlanned;
  final DateTime nextSession;
  final MentorshipHealth health;

  const MentorshipPair({
    required this.id,
    required this.mentorName,
    required this.menteeName,
    required this.department,
    required this.focusArea,
    required this.sessionsCompleted,
    required this.sessionsPlanned,
    required this.nextSession,
    required this.health,
  });

  double get progress {
    if (sessionsPlanned == 0) return 1;
    return sessionsCompleted / sessionsPlanned;
  }
}

class TalentSummary {
  final int skillGaps;
  final int learningDue;
  final int certificationRisks;
  final int mentoringWatch;
  final double averageLearningCompletion;

  const TalentSummary({
    required this.skillGaps,
    required this.learningDue,
    required this.certificationRisks,
    required this.mentoringWatch,
    required this.averageLearningCompletion,
  });
}

class TalentRiskSummary {
  final int skillGaps;
  final int overdueLearningPlans;
  final int expiredCertifications;
  final int expiringCertifications;
  final int blockedMentorships;
  final int dueWithinFourteenDays;

  const TalentRiskSummary({
    required this.skillGaps,
    required this.overdueLearningPlans,
    required this.expiredCertifications,
    required this.expiringCertifications,
    required this.blockedMentorships,
    required this.dueWithinFourteenDays,
  });

  int get totalRisks =>
      skillGaps +
      overdueLearningPlans +
      expiredCertifications +
      expiringCertifications +
      blockedMentorships;

  factory TalentRiskSummary.fromData({
    required List<SkillGap> skillGaps,
    required List<LearningPlan> learningPlans,
    required List<CertificationRecord> certifications,
    required List<MentorshipPair> mentorshipPairs,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));

    return TalentRiskSummary(
      skillGaps:
          skillGaps.where((item) => item.status == SkillGapStatus.gap).length,
      overdueLearningPlans:
          learningPlans
              .where((item) => item.status == LearningPlanStatus.overdue)
              .length,
      expiredCertifications:
          certifications
              .where((item) => item.status == CertificationStatus.expired)
              .length,
      expiringCertifications:
          certifications
              .where((item) => item.status == CertificationStatus.expiring)
              .length,
      blockedMentorships:
          mentorshipPairs
              .where((item) => item.health == MentorshipHealth.blocked)
              .length,
      dueWithinFourteenDays:
          learningPlans
              .where(
                (item) =>
                    item.status != LearningPlanStatus.completed &&
                    !item.dueDate.isAfter(dueThreshold),
              )
              .length +
          certifications
              .where(
                (item) =>
                    item.status != CertificationStatus.active &&
                    !item.expiryDate.isAfter(dueThreshold),
              )
              .length +
          mentorshipPairs
              .where(
                (item) =>
                    item.health != MentorshipHealth.healthy &&
                    !item.nextSession.isAfter(dueThreshold),
              )
              .length,
    );
  }
}
