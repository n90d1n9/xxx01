enum RecruitmentPriority { low, medium, high }

enum RequisitionStatus { draft, open, interviewing, offer, closed }

enum CandidateStage { applied, screening, interview, offer, hired, rejected }

enum InterviewStatus { scheduled, needsFeedback, completed }

enum OfferStatus { draft, sent, accepted, declined }

enum SourceHealth { strong, watch, weak }

class JobRequisition {
  final String id;
  final String title;
  final String department;
  final String location;
  final String hiringManager;
  final int openings;
  final int filled;
  final int pipelineCount;
  final DateTime openedAt;
  final DateTime targetDate;
  final RecruitmentPriority priority;
  final RequisitionStatus status;

  const JobRequisition({
    required this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.hiringManager,
    required this.openings,
    required this.filled,
    required this.pipelineCount,
    required this.openedAt,
    required this.targetDate,
    required this.priority,
    required this.status,
  });

  int get remainingOpenings {
    final value = openings - filled;
    return value < 0 ? 0 : value;
  }

  double get fillProgress => openings == 0 ? 1 : filled / openings;

  bool get isOpen => status != RequisitionStatus.closed;
}

class CandidateProfile {
  final String id;
  final String name;
  final String role;
  final String department;
  final String source;
  final String owner;
  final int score;
  final DateTime appliedAt;
  final CandidateStage stage;
  final RecruitmentPriority priority;

  const CandidateProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.source,
    required this.owner,
    required this.score,
    required this.appliedAt,
    required this.stage,
    required this.priority,
  });

  bool get isActive =>
      stage != CandidateStage.hired && stage != CandidateStage.rejected;
}

class InterviewSlot {
  final String id;
  final String candidateName;
  final String role;
  final String department;
  final String interviewer;
  final DateTime scheduledAt;
  final InterviewStatus status;

  const InterviewSlot({
    required this.id,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.interviewer,
    required this.scheduledAt,
    required this.status,
  });
}

class OfferTracker {
  final String id;
  final String candidateName;
  final String role;
  final String department;
  final String recruiter;
  final DateTime sentAt;
  final DateTime expiresAt;
  final int compensationScore;
  final OfferStatus status;

  const OfferTracker({
    required this.id,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.recruiter,
    required this.sentAt,
    required this.expiresAt,
    required this.compensationScore,
    required this.status,
  });

  bool get isPending =>
      status == OfferStatus.draft || status == OfferStatus.sent;
}

class SourceMetric {
  final String id;
  final String name;
  final int candidates;
  final int interviews;
  final int hires;
  final int costPerHire;
  final SourceHealth health;

  const SourceMetric({
    required this.id,
    required this.name,
    required this.candidates,
    required this.interviews,
    required this.hires,
    required this.costPerHire,
    required this.health,
  });

  double get interviewRate => candidates == 0 ? 0 : interviews / candidates;

  double get hireRate => candidates == 0 ? 0 : hires / candidates;
}

class RecruitmentSummary {
  final int openRequisitions;
  final int activeCandidates;
  final int interviewsToday;
  final int pendingOffers;
  final double sourceHireRate;

  const RecruitmentSummary({
    required this.openRequisitions,
    required this.activeCandidates,
    required this.interviewsToday,
    required this.pendingOffers,
    required this.sourceHireRate,
  });
}

class RecruitmentPipelineRiskSummary {
  final int highPriorityRequisitions;
  final int candidateFollowUps;
  final int feedbackDue;
  final int expiringOffers;
  final int sourcesToWatch;

  const RecruitmentPipelineRiskSummary({
    required this.highPriorityRequisitions,
    required this.candidateFollowUps,
    required this.feedbackDue,
    required this.expiringOffers,
    required this.sourcesToWatch,
  });

  int get totalRisks =>
      highPriorityRequisitions +
      candidateFollowUps +
      feedbackDue +
      expiringOffers +
      sourcesToWatch;

  factory RecruitmentPipelineRiskSummary.fromData({
    required List<JobRequisition> requisitions,
    required List<CandidateProfile> candidates,
    required List<InterviewSlot> interviews,
    required List<OfferTracker> offers,
    required List<SourceMetric> sources,
    required DateTime asOfDate,
  }) {
    final followUpThreshold = asOfDate.subtract(const Duration(days: 6));
    final offerThreshold = asOfDate.add(const Duration(days: 7));

    return RecruitmentPipelineRiskSummary(
      highPriorityRequisitions:
          requisitions
              .where((item) => item.priority == RecruitmentPriority.high)
              .length,
      candidateFollowUps:
          candidates
              .where(
                (item) =>
                    item.isActive && item.appliedAt.isBefore(followUpThreshold),
              )
              .length,
      feedbackDue:
          interviews
              .where((item) => item.status == InterviewStatus.needsFeedback)
              .length,
      expiringOffers:
          offers
              .where(
                (item) =>
                    item.isPending && !item.expiresAt.isAfter(offerThreshold),
              )
              .length,
      sourcesToWatch:
          sources.where((item) => item.health != SourceHealth.strong).length,
    );
  }
}
