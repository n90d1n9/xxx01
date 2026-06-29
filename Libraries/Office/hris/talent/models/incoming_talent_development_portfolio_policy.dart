import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_portfolio.dart';
import 'incoming_talent_development_roadmap.dart';

class IncomingTalentDevelopmentPortfolioDefaults {
  final IncomingTalentDevelopmentPortfolioStage stage;
  final IncomingTalentDevelopmentPortfolioPriority priority;
  final IncomingTalentDevelopmentPortfolioCadence cadence;
  final Duration nextReviewOffset;
  final String competencyFocus;
  final String growthGoal;
  final String learningPath;
  final String evidencePlan;

  const IncomingTalentDevelopmentPortfolioDefaults({
    required this.stage,
    required this.priority,
    required this.cadence,
    required this.nextReviewOffset,
    required this.competencyFocus,
    required this.growthGoal,
    required this.learningPath,
    required this.evidencePlan,
  });

  factory IncomingTalentDevelopmentPortfolioDefaults.fromRoadmap(
    IncomingTalentDevelopmentRoadmap roadmap,
  ) {
    final cadence = _cadenceFromRoadmap(roadmap);

    return IncomingTalentDevelopmentPortfolioDefaults(
      stage: _stageFromRoadmap(roadmap),
      priority: _priorityFromRoadmap(roadmap),
      cadence: cadence,
      nextReviewOffset: _offsetFromCadence(cadence),
      competencyFocus: roadmap.focusArea,
      growthGoal: roadmap.learningObjective,
      learningPath:
          'Pair ${roadmap.mentorName} coaching with ${roadmap.firstMilestone}.',
      evidencePlan:
          'Track ${roadmap.successMetric} with manager sign-off evidence.',
    );
  }
}

IncomingTalentDevelopmentPortfolioStage _stageFromRoadmap(
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  return switch (roadmap.status) {
    IncomingTalentDevelopmentRoadmapStatus.planned =>
      IncomingTalentDevelopmentPortfolioStage.designing,
    IncomingTalentDevelopmentRoadmapStatus.active =>
      IncomingTalentDevelopmentPortfolioStage.active,
    IncomingTalentDevelopmentRoadmapStatus.atRisk =>
      IncomingTalentDevelopmentPortfolioStage.watch,
    IncomingTalentDevelopmentRoadmapStatus.completed =>
      IncomingTalentDevelopmentPortfolioStage.graduated,
  };
}

IncomingTalentDevelopmentPortfolioPriority _priorityFromRoadmap(
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.atRisk ||
      roadmap.retentionRisk == IncomingTalentActivationRetentionRisk.high ||
      roadmap.readinessScore < 70) {
    return IncomingTalentDevelopmentPortfolioPriority.recovery;
  }
  if (roadmap.readinessScore >= 85) {
    return IncomingTalentDevelopmentPortfolioPriority.accelerated;
  }
  return IncomingTalentDevelopmentPortfolioPriority.focused;
}

IncomingTalentDevelopmentPortfolioCadence _cadenceFromRoadmap(
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.atRisk ||
      roadmap.retentionRisk == IncomingTalentActivationRetentionRisk.high) {
    return IncomingTalentDevelopmentPortfolioCadence.weekly;
  }
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.active ||
      roadmap.retentionRisk == IncomingTalentActivationRetentionRisk.medium) {
    return IncomingTalentDevelopmentPortfolioCadence.biweekly;
  }
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.completed) {
    return IncomingTalentDevelopmentPortfolioCadence.quarterly;
  }
  return IncomingTalentDevelopmentPortfolioCadence.monthly;
}

Duration _offsetFromCadence(IncomingTalentDevelopmentPortfolioCadence cadence) {
  return switch (cadence) {
    IncomingTalentDevelopmentPortfolioCadence.weekly => const Duration(days: 7),
    IncomingTalentDevelopmentPortfolioCadence.biweekly => const Duration(
      days: 14,
    ),
    IncomingTalentDevelopmentPortfolioCadence.monthly => const Duration(
      days: 30,
    ),
    IncomingTalentDevelopmentPortfolioCadence.quarterly => const Duration(
      days: 90,
    ),
  };
}

String? validateIncomingTalentDevelopmentPortfolioRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentDevelopmentPortfolioLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentDevelopmentPortfolioRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentDevelopmentPortfolioStage(
  IncomingTalentDevelopmentPortfolioStage? value,
) {
  if (value == null) return 'Select portfolio stage';
  return null;
}

String? validateIncomingTalentDevelopmentPortfolioPriority(
  IncomingTalentDevelopmentPortfolioPriority? value,
) {
  if (value == null) return 'Select portfolio priority';
  return null;
}

String? validateIncomingTalentDevelopmentPortfolioCadence(
  IncomingTalentDevelopmentPortfolioCadence? value,
) {
  if (value == null) return 'Select review cadence';
  return null;
}

String? validateIncomingTalentDevelopmentPortfolioStartDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select a start date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Start date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentDevelopmentPortfolioNextReviewDate(
  DateTime? startDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select a next review date';
  if (startDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(startDate))) {
    return 'Next review must be after the start date';
  }
  return null;
}

String? validateIncomingTalentDevelopmentPortfolioTargetDate(
  DateTime? startDate,
  DateTime? targetCompletionDate,
) {
  if (targetCompletionDate == null) return 'Select a target completion date';
  if (startDate == null) return null;
  if (!_dateOnly(targetCompletionDate).isAfter(_dateOnly(startDate))) {
    return 'Target completion must be after the start date';
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
