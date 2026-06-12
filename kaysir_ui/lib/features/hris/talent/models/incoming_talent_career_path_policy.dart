import 'incoming_talent_career_path.dart';
import 'incoming_talent_development_portfolio.dart';

class IncomingTalentCareerPathDefaults {
  final String targetRole;
  final String competencyName;
  final int currentLevel;
  final int targetLevel;
  final IncomingTalentCareerPathStatus status;
  final IncomingTalentCareerPathPriority priority;
  final String developmentAction;
  final String evidenceRequirement;
  final Duration reviewOffset;

  const IncomingTalentCareerPathDefaults({
    required this.targetRole,
    required this.competencyName,
    required this.currentLevel,
    required this.targetLevel,
    required this.status,
    required this.priority,
    required this.developmentAction,
    required this.evidenceRequirement,
    required this.reviewOffset,
  });

  factory IncomingTalentCareerPathDefaults.fromPortfolio(
    IncomingTalentDevelopmentPortfolio portfolio,
  ) {
    final priority = _priorityFromPortfolio(portfolio);

    return IncomingTalentCareerPathDefaults(
      targetRole: _targetRoleFromPortfolio(portfolio),
      competencyName: portfolio.competencyFocus,
      currentLevel: _currentLevelFromReadiness(portfolio.sourceReadinessScore),
      targetLevel: _targetLevelFromPriority(priority),
      status: _statusFromPortfolio(portfolio),
      priority: priority,
      developmentAction: portfolio.learningPath,
      evidenceRequirement: portfolio.evidencePlan,
      reviewOffset: _reviewOffset(priority),
    );
  }
}

IncomingTalentCareerPathPriority _priorityFromPortfolio(
  IncomingTalentDevelopmentPortfolio portfolio,
) {
  if (portfolio.priority ==
          IncomingTalentDevelopmentPortfolioPriority.recovery ||
      portfolio.sourceReadinessScore < 70) {
    return IncomingTalentCareerPathPriority.critical;
  }
  if (portfolio.priority ==
      IncomingTalentDevelopmentPortfolioPriority.accelerated) {
    return IncomingTalentCareerPathPriority.accelerated;
  }
  return IncomingTalentCareerPathPriority.standard;
}

IncomingTalentCareerPathStatus _statusFromPortfolio(
  IncomingTalentDevelopmentPortfolio portfolio,
) {
  if (portfolio.stage == IncomingTalentDevelopmentPortfolioStage.watch) {
    return IncomingTalentCareerPathStatus.blocked;
  }
  if (portfolio.stage == IncomingTalentDevelopmentPortfolioStage.graduated) {
    return IncomingTalentCareerPathStatus.achieved;
  }
  if (portfolio.stage == IncomingTalentDevelopmentPortfolioStage.active) {
    return IncomingTalentCareerPathStatus.active;
  }
  return IncomingTalentCareerPathStatus.draft;
}

String _targetRoleFromPortfolio(IncomingTalentDevelopmentPortfolio portfolio) {
  return switch (portfolio.priority) {
    IncomingTalentDevelopmentPortfolioPriority.accelerated =>
      'Lead ${portfolio.role}',
    IncomingTalentDevelopmentPortfolioPriority.recovery =>
      '${portfolio.role} - stabilized',
    IncomingTalentDevelopmentPortfolioPriority.focused =>
      '${portfolio.role} - proficient',
  };
}

int _currentLevelFromReadiness(int readinessScore) {
  if (readinessScore >= 90) return 4;
  if (readinessScore >= 75) return 3;
  if (readinessScore >= 60) return 2;
  return 1;
}

int _targetLevelFromPriority(IncomingTalentCareerPathPriority priority) {
  return switch (priority) {
    IncomingTalentCareerPathPriority.standard => 4,
    IncomingTalentCareerPathPriority.accelerated => 5,
    IncomingTalentCareerPathPriority.critical => 4,
  };
}

Duration _reviewOffset(IncomingTalentCareerPathPriority priority) {
  return switch (priority) {
    IncomingTalentCareerPathPriority.critical => const Duration(days: 14),
    IncomingTalentCareerPathPriority.accelerated => const Duration(days: 45),
    IncomingTalentCareerPathPriority.standard => const Duration(days: 30),
  };
}

String? validateIncomingTalentCareerPathRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentCareerPathLongText(String? value, String label) {
  final requiredError = validateIncomingTalentCareerPathRequired(value, label);
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentCareerPathLevel(int value, String label) {
  if (value < 1 || value > 5) return '$label must be between 1 and 5';
  return null;
}

String? validateIncomingTalentCareerPathTargetLevel({
  required int currentLevel,
  required int targetLevel,
}) {
  final levelError = validateIncomingTalentCareerPathLevel(
    targetLevel,
    'Target level',
  );
  if (levelError != null) return levelError;
  if (targetLevel < currentLevel) {
    return 'Target level cannot be below current level';
  }
  return null;
}

String? validateIncomingTalentCareerPathStatus(
  IncomingTalentCareerPathStatus? value,
) {
  if (value == null) return 'Select career path status';
  return null;
}

String? validateIncomingTalentCareerPathPriority(
  IncomingTalentCareerPathPriority? value,
) {
  if (value == null) return 'Select career path priority';
  return null;
}

String? validateIncomingTalentCareerPathReviewDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select a review date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Review date cannot be in the past';
  }
  return null;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
