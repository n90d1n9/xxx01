enum IncomingTalentGrowthAlignmentFocus {
  training('Training'),
  careerPath('Career path'),
  evidence('Evidence'),
  momentum('Momentum');

  final String label;

  const IncomingTalentGrowthAlignmentFocus(this.label);
}

enum IncomingTalentGrowthAlignmentStatus {
  needsTraining('Needs training'),
  needsCareerPath('Needs career path'),
  atRisk('At risk'),
  needsEvidence('Needs evidence'),
  onTrack('On track'),
  completed('Completed');

  final String label;

  const IncomingTalentGrowthAlignmentStatus(this.label);
}

/// Describes one employee's combined IDP, training, and career-path coverage.
class IncomingTalentGrowthAlignmentItem {
  final String id;
  final String portfolioId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String targetRole;
  final String ownerName;
  final String mentorName;
  final String competencyFocus;
  final String trainingTitle;
  final String trainingStatusLabel;
  final String careerStatusLabel;
  final String evidencePlan;
  final String nextAction;
  final IncomingTalentGrowthAlignmentStatus status;
  final IncomingTalentGrowthAlignmentFocus focus;
  final DateTime nextReviewDate;
  final int sourceReadinessScore;
  final int trainingProgressScore;
  final int levelGap;
  final bool hasTrainingEnrollment;
  final bool hasCareerPath;
  final int sourceCount;

  const IncomingTalentGrowthAlignmentItem({
    required this.id,
    required this.portfolioId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.targetRole,
    required this.ownerName,
    required this.mentorName,
    required this.competencyFocus,
    required this.trainingTitle,
    required this.trainingStatusLabel,
    required this.careerStatusLabel,
    required this.evidencePlan,
    required this.nextAction,
    required this.status,
    required this.focus,
    required this.nextReviewDate,
    required this.sourceReadinessScore,
    required this.trainingProgressScore,
    required this.levelGap,
    required this.hasTrainingEnrollment,
    required this.hasCareerPath,
    required this.sourceCount,
  });

  bool get needsAttention {
    return switch (status) {
      IncomingTalentGrowthAlignmentStatus.onTrack ||
      IncomingTalentGrowthAlignmentStatus.completed => false,
      _ => true,
    };
  }

  double get readinessRatio {
    return (sourceReadinessScore / 100).clamp(0, 1).toDouble();
  }

  double get trainingProgressRatio {
    return (trainingProgressScore / 100).clamp(0, 1).toDouble();
  }

  double get careerProgressRatio {
    if (!hasCareerPath) return 0;
    return (1 - (levelGap / 5)).clamp(0, 1).toDouble();
  }

  double get alignmentRatio {
    final total = readinessRatio + trainingProgressRatio + careerProgressRatio;
    return (total / 3).clamp(0, 1).toDouble();
  }

  int get urgencyRank {
    return switch (status) {
      IncomingTalentGrowthAlignmentStatus.needsTraining => 0,
      IncomingTalentGrowthAlignmentStatus.needsCareerPath => 1,
      IncomingTalentGrowthAlignmentStatus.atRisk => 2,
      IncomingTalentGrowthAlignmentStatus.needsEvidence => 3,
      IncomingTalentGrowthAlignmentStatus.onTrack => 4,
      IncomingTalentGrowthAlignmentStatus.completed => 5,
    };
  }
}
