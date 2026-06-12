import 'incoming_talent_career_path_models.dart';
import 'incoming_talent_development_portfolio_models.dart';
import 'incoming_talent_development_program_models.dart';
import 'incoming_talent_growth_alignment_item.dart';

List<IncomingTalentGrowthAlignmentItem> buildIncomingTalentGrowthAlignments({
  required List<IncomingTalentDevelopmentPortfolio> portfolios,
  required List<IncomingTalentDevelopmentProgram> programs,
  required List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
  required List<IncomingTalentCareerPath> careerPaths,
}) {
  final activePrograms =
      programs.where((program) => program.acceptsEnrollment).toList();
  final items = <IncomingTalentGrowthAlignmentItem>[
    for (final portfolio in portfolios)
      _composeItem(
        portfolio: portfolio,
        activePrograms: activePrograms,
        enrollments: enrollments,
        careerPaths: careerPaths,
      ),
  ];

  items.sort(_compareItems);
  return items;
}

IncomingTalentGrowthAlignmentItem _composeItem({
  required IncomingTalentDevelopmentPortfolio portfolio,
  required List<IncomingTalentDevelopmentProgram> activePrograms,
  required List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
  required List<IncomingTalentCareerPath> careerPaths,
}) {
  final enrollment = _selectEnrollment(portfolio, enrollments);
  final careerPath = _selectCareerPath(portfolio, careerPaths);
  final recommendedProgram = _selectRecommendedProgram(
    portfolio,
    activePrograms,
  );
  final status = _statusFor(
    portfolio: portfolio,
    enrollment: enrollment,
    careerPath: careerPath,
  );

  return IncomingTalentGrowthAlignmentItem(
    id: 'growth-alignment-${portfolio.id}',
    portfolioId: portfolio.id,
    candidateName: portfolio.candidateName,
    department: portfolio.department,
    currentRole: careerPath?.currentRole ?? portfolio.role,
    targetRole: careerPath?.targetRole ?? 'Target role unassigned',
    ownerName: careerPath?.ownerName ?? portfolio.portfolioOwnerName,
    mentorName: careerPath?.mentorName ?? portfolio.mentorName,
    competencyFocus: careerPath?.competencyName ?? portfolio.competencyFocus,
    trainingTitle:
        enrollment?.programTitle ??
        recommendedProgram?.title ??
        'No training program assigned',
    trainingStatusLabel:
        enrollment?.status.label ??
        (recommendedProgram == null ? 'Missing' : 'Recommended'),
    careerStatusLabel: careerPath?.status.label ?? 'Missing',
    evidencePlan:
        careerPath?.evidenceRequirement ??
        enrollment?.evidencePlan ??
        portfolio.evidencePlan,
    nextAction: _nextAction(
      portfolio: portfolio,
      enrollment: enrollment,
      careerPath: careerPath,
      recommendedProgram: recommendedProgram,
      status: status,
    ),
    status: status,
    focus: _focusFor(status),
    nextReviewDate: _earliestDate(
      portfolio.nextReviewDate,
      enrollment?.nextReviewDate,
      careerPath?.reviewDate,
    ),
    sourceReadinessScore: portfolio.sourceReadinessScore,
    trainingProgressScore: enrollment?.progressScore ?? 0,
    levelGap: careerPath?.levelGap ?? 0,
    hasTrainingEnrollment: enrollment != null,
    hasCareerPath: careerPath != null,
    sourceCount:
        1 +
        (enrollment == null ? 0 : 1) +
        (careerPath == null ? 0 : 1) +
        (recommendedProgram == null ? 0 : 1),
  );
}

IncomingTalentDevelopmentProgramEnrollment? _selectEnrollment(
  IncomingTalentDevelopmentPortfolio portfolio,
  List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
) {
  final matches =
      enrollments
          .where(
            (enrollment) =>
                enrollment.portfolioId == portfolio.id &&
                enrollment.status !=
                    IncomingTalentDevelopmentProgramEnrollmentStatus.withdrawn,
          )
          .toList();
  if (matches.isEmpty) return null;

  matches.sort((a, b) {
    final closedComparison = _boolRank(
      a.isClosed,
    ).compareTo(_boolRank(b.isClosed));
    if (closedComparison != 0) return closedComparison;

    final attentionComparison = _boolRank(
      !a.needsAttention,
    ).compareTo(_boolRank(!b.needsAttention));
    if (attentionComparison != 0) return attentionComparison;

    return a.nextReviewDate.compareTo(b.nextReviewDate);
  });

  return matches.first;
}

IncomingTalentCareerPath? _selectCareerPath(
  IncomingTalentDevelopmentPortfolio portfolio,
  List<IncomingTalentCareerPath> careerPaths,
) {
  final matches =
      careerPaths
          .where((careerPath) => careerPath.portfolioId == portfolio.id)
          .toList();
  if (matches.isEmpty) return null;

  matches.sort((a, b) {
    final statusComparison = a.status.index.compareTo(b.status.index);
    if (statusComparison != 0) return statusComparison;
    return a.reviewDate.compareTo(b.reviewDate);
  });
  return matches.first;
}

IncomingTalentDevelopmentProgram? _selectRecommendedProgram(
  IncomingTalentDevelopmentPortfolio portfolio,
  List<IncomingTalentDevelopmentProgram> activePrograms,
) {
  final sameDepartmentPrograms =
      activePrograms
          .where((program) => program.department == portfolio.department)
          .toList();
  if (sameDepartmentPrograms.isEmpty) return null;

  for (final program in sameDepartmentPrograms) {
    if (_matchesCompetency(portfolio, program)) return program;
  }

  if (portfolio.priority ==
          IncomingTalentDevelopmentPortfolioPriority.recovery ||
      portfolio.stage == IncomingTalentDevelopmentPortfolioStage.watch) {
    for (final program in sameDepartmentPrograms) {
      if (program.track == IncomingTalentDevelopmentProgramTrack.recovery) {
        return program;
      }
    }
  }

  return sameDepartmentPrograms.first;
}

bool _matchesCompetency(
  IncomingTalentDevelopmentPortfolio portfolio,
  IncomingTalentDevelopmentProgram program,
) {
  final programText =
      '${program.title} ${program.skillFocus} ${program.expectedOutcome} '
              '${program.track.label}'
          .toLowerCase();
  final portfolioTokens = _tokens(
    '${portfolio.role} ${portfolio.competencyFocus} ${portfolio.learningPath}',
  );

  for (final token in portfolioTokens) {
    if (programText.contains(token)) return true;
  }
  return false;
}

Iterable<String> _tokens(String value) sync* {
  for (final token in value.toLowerCase().split(RegExp(r'[^a-z0-9]+'))) {
    if (token.length >= 4) yield token;
  }
}

IncomingTalentGrowthAlignmentStatus _statusFor({
  required IncomingTalentDevelopmentPortfolio portfolio,
  required IncomingTalentDevelopmentProgramEnrollment? enrollment,
  required IncomingTalentCareerPath? careerPath,
}) {
  if (portfolio.stage == IncomingTalentDevelopmentPortfolioStage.graduated &&
      enrollment?.status ==
          IncomingTalentDevelopmentProgramEnrollmentStatus.completed &&
      careerPath?.status == IncomingTalentCareerPathStatus.achieved) {
    return IncomingTalentGrowthAlignmentStatus.completed;
  }
  if (enrollment == null) {
    return IncomingTalentGrowthAlignmentStatus.needsTraining;
  }
  if (careerPath == null) {
    return IncomingTalentGrowthAlignmentStatus.needsCareerPath;
  }
  if (careerPath.status == IncomingTalentCareerPathStatus.blocked ||
      enrollment.progressScore < 60 ||
      portfolio.sourceReadinessScore < 60) {
    return IncomingTalentGrowthAlignmentStatus.atRisk;
  }
  if (enrollment.needsAttention ||
      careerPath.needsAttention ||
      portfolio.needsAttention) {
    return IncomingTalentGrowthAlignmentStatus.needsEvidence;
  }
  return IncomingTalentGrowthAlignmentStatus.onTrack;
}

IncomingTalentGrowthAlignmentFocus _focusFor(
  IncomingTalentGrowthAlignmentStatus status,
) {
  return switch (status) {
    IncomingTalentGrowthAlignmentStatus.needsTraining =>
      IncomingTalentGrowthAlignmentFocus.training,
    IncomingTalentGrowthAlignmentStatus.needsCareerPath =>
      IncomingTalentGrowthAlignmentFocus.careerPath,
    IncomingTalentGrowthAlignmentStatus.atRisk ||
    IncomingTalentGrowthAlignmentStatus
        .needsEvidence => IncomingTalentGrowthAlignmentFocus.evidence,
    IncomingTalentGrowthAlignmentStatus.onTrack ||
    IncomingTalentGrowthAlignmentStatus
        .completed => IncomingTalentGrowthAlignmentFocus.momentum,
  };
}

String _nextAction({
  required IncomingTalentDevelopmentPortfolio portfolio,
  required IncomingTalentDevelopmentProgramEnrollment? enrollment,
  required IncomingTalentCareerPath? careerPath,
  required IncomingTalentDevelopmentProgram? recommendedProgram,
  required IncomingTalentGrowthAlignmentStatus status,
}) {
  if (enrollment == null && careerPath == null) {
    if (recommendedProgram == null) {
      return 'Create training assignment and career path for ${portfolio.candidateName}.';
    }
    return 'Enroll ${portfolio.candidateName} into ${recommendedProgram.title} and create a career path.';
  }
  if (enrollment == null) {
    if (recommendedProgram == null) {
      return 'Create training coverage for ${portfolio.candidateName}.';
    }
    return 'Enroll ${portfolio.candidateName} into ${recommendedProgram.title}.';
  }
  if (careerPath == null) {
    return 'Create a career path from ${portfolio.candidateName}\'s IDP evidence.';
  }

  return switch (status) {
    IncomingTalentGrowthAlignmentStatus.atRisk =>
      'Stabilize training progress and career evidence.',
    IncomingTalentGrowthAlignmentStatus.needsEvidence =>
      'Collect evidence across training milestone and career review.',
    IncomingTalentGrowthAlignmentStatus.completed =>
      'Archive growth evidence as role-ready proof.',
    IncomingTalentGrowthAlignmentStatus.onTrack =>
      'Keep training and career path on cadence.',
    IncomingTalentGrowthAlignmentStatus.needsTraining ||
    IncomingTalentGrowthAlignmentStatus
        .needsCareerPath => 'Complete growth alignment setup.',
  };
}

DateTime _earliestDate(
  DateTime portfolioDate,
  DateTime? enrollmentDate,
  DateTime? careerDate,
) {
  final dates = [
    portfolioDate,
    if (enrollmentDate != null) enrollmentDate,
    if (careerDate != null) careerDate,
  ]..sort();
  return dates.first;
}

int _compareItems(
  IncomingTalentGrowthAlignmentItem a,
  IncomingTalentGrowthAlignmentItem b,
) {
  final urgencyComparison = a.urgencyRank.compareTo(b.urgencyRank);
  if (urgencyComparison != 0) return urgencyComparison;

  final reviewComparison = a.nextReviewDate.compareTo(b.nextReviewDate);
  if (reviewComparison != 0) return reviewComparison;

  return a.candidateName.compareTo(b.candidateName);
}

int _boolRank(bool value) => value ? 1 : 0;
