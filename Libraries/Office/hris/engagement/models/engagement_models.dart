enum SurveyStatus { draft, live, closed, actionRequired }

enum EngagementPriority { low, medium, high }

enum RecognitionType { peer, manager, milestone }

enum WellbeingRiskLevel { low, medium, high }

enum ActionPlanStatus { planned, inProgress, blocked, done }

class EngagementSurvey {
  final String id;
  final String title;
  final String department;
  final int responseRate;
  final int eNps;
  final DateTime closesAt;
  final SurveyStatus status;

  const EngagementSurvey({
    required this.id,
    required this.title,
    required this.department,
    required this.responseRate,
    required this.eNps,
    required this.closesAt,
    required this.status,
  });
}

class PulseTopic {
  final String id;
  final String topic;
  final String department;
  final int score;
  final int trend;
  final String insight;
  final EngagementPriority priority;

  const PulseTopic({
    required this.id,
    required this.topic,
    required this.department,
    required this.score,
    required this.trend,
    required this.insight,
    required this.priority,
  });
}

class RecognitionMoment {
  final String id;
  final String employeeName;
  final String fromName;
  final String department;
  final String reason;
  final DateTime recognizedAt;
  final RecognitionType type;

  const RecognitionMoment({
    required this.id,
    required this.employeeName,
    required this.fromName,
    required this.department,
    required this.reason,
    required this.recognizedAt,
    required this.type,
  });
}

class WellbeingRisk {
  final String id;
  final String employeeName;
  final String department;
  final String signal;
  final String ownerName;
  final DateTime reviewDate;
  final WellbeingRiskLevel level;

  const WellbeingRisk({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.signal,
    required this.ownerName,
    required this.reviewDate,
    required this.level,
  });
}

class EngagementActionPlan {
  final String id;
  final String department;
  final String theme;
  final String ownerName;
  final int progress;
  final DateTime dueDate;
  final ActionPlanStatus status;

  const EngagementActionPlan({
    required this.id,
    required this.department,
    required this.theme,
    required this.ownerName,
    required this.progress,
    required this.dueDate,
    required this.status,
  });
}

class EngagementSummary {
  final int liveSurveys;
  final int actionItems;
  final int highRisks;
  final int recognitionCount;
  final double averagePulseScore;

  const EngagementSummary({
    required this.liveSurveys,
    required this.actionItems,
    required this.highRisks,
    required this.recognitionCount,
    required this.averagePulseScore,
  });
}

class EngagementRiskSummary {
  final int actionRequiredSurveys;
  final int lowPulseTopics;
  final int highWellbeingRisks;
  final int blockedActionPlans;
  final int dueWithinSevenDays;

  const EngagementRiskSummary({
    required this.actionRequiredSurveys,
    required this.lowPulseTopics,
    required this.highWellbeingRisks,
    required this.blockedActionPlans,
    required this.dueWithinSevenDays,
  });

  int get totalRisks =>
      actionRequiredSurveys +
      lowPulseTopics +
      highWellbeingRisks +
      blockedActionPlans;

  factory EngagementRiskSummary.fromData({
    required List<EngagementSurvey> surveys,
    required List<PulseTopic> pulses,
    required List<WellbeingRisk> risks,
    required List<EngagementActionPlan> actions,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 7));

    return EngagementRiskSummary(
      actionRequiredSurveys:
          surveys
              .where((item) => item.status == SurveyStatus.actionRequired)
              .length,
      lowPulseTopics:
          pulses
              .where(
                (item) =>
                    item.priority == EngagementPriority.high || item.score < 70,
              )
              .length,
      highWellbeingRisks:
          risks.where((item) => item.level == WellbeingRiskLevel.high).length,
      blockedActionPlans:
          actions
              .where((item) => item.status == ActionPlanStatus.blocked)
              .length,
      dueWithinSevenDays:
          surveys
              .where(
                (item) =>
                    item.status != SurveyStatus.closed &&
                    !item.closesAt.isAfter(dueThreshold),
              )
              .length +
          risks.where((item) => !item.reviewDate.isAfter(dueThreshold)).length +
          actions
              .where(
                (item) =>
                    item.status != ActionPlanStatus.done &&
                    !item.dueDate.isAfter(dueThreshold),
              )
              .length,
    );
  }
}
