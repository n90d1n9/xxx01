import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_cadence_intervention.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

IncomingTalentMobilityCadenceInterventionType
defaultIncomingTalentMobilityCadenceInterventionType(
  IncomingTalentMobilityCadenceCheckIn checkIn,
) {
  if (checkIn.status == IncomingTalentMobilityCadenceStatus.intervene) {
    return IncomingTalentMobilityCadenceInterventionType.sponsorEscalation;
  }
  if (checkIn.residualRisk ==
      IncomingTalentMobilityStabilizationResidualRisk.high) {
    return IncomingTalentMobilityCadenceInterventionType.retentionConversation;
  }
  if (checkIn.hostConfidenceScore <= 3) {
    return IncomingTalentMobilityCadenceInterventionType.managerCoaching;
  }
  if (checkIn.residualRisk ==
      IncomingTalentMobilityStabilizationResidualRisk.moderate) {
    return IncomingTalentMobilityCadenceInterventionType.roleScopeReset;
  }
  return IncomingTalentMobilityCadenceInterventionType.workloadRebalance;
}

IncomingTalentMobilityCadenceInterventionPriority
defaultIncomingTalentMobilityCadenceInterventionPriority(
  IncomingTalentMobilityCadenceCheckIn checkIn,
) {
  if (checkIn.status == IncomingTalentMobilityCadenceStatus.intervene ||
      checkIn.residualRisk ==
          IncomingTalentMobilityStabilizationResidualRisk.high) {
    return IncomingTalentMobilityCadenceInterventionPriority.urgent;
  }
  if (checkIn.status == IncomingTalentMobilityCadenceStatus.watch ||
      checkIn.hostConfidenceScore <= 3 ||
      checkIn.residualRisk ==
          IncomingTalentMobilityStabilizationResidualRisk.moderate) {
    return IncomingTalentMobilityCadenceInterventionPriority.high;
  }
  return IncomingTalentMobilityCadenceInterventionPriority.standard;
}

IncomingTalentMobilityCadenceInterventionStatus
defaultIncomingTalentMobilityCadenceInterventionStatus(
  IncomingTalentMobilityCadenceCheckIn checkIn,
) {
  return checkIn.status == IncomingTalentMobilityCadenceStatus.intervene
      ? IncomingTalentMobilityCadenceInterventionStatus.inProgress
      : IncomingTalentMobilityCadenceInterventionStatus.planned;
}

DateTime defaultIncomingTalentMobilityCadenceInterventionDueDate({
  required IncomingTalentMobilityCadenceInterventionPriority priority,
  required DateTime asOfDate,
}) {
  return switch (priority) {
    IncomingTalentMobilityCadenceInterventionPriority.urgent => asOfDate.add(
      const Duration(days: 5),
    ),
    IncomingTalentMobilityCadenceInterventionPriority.high => asOfDate.add(
      const Duration(days: 10),
    ),
    IncomingTalentMobilityCadenceInterventionPriority.standard => asOfDate.add(
      const Duration(days: 14),
    ),
  };
}

String defaultIncomingTalentMobilityCadenceInterventionSummary(
  IncomingTalentMobilityCadenceCheckIn checkIn,
) {
  return 'Recover ${checkIn.candidateName} mobility cadence with targeted support for ${checkIn.opportunityTitle.toLowerCase()}.';
}

String defaultIncomingTalentMobilityCadenceInterventionSuccessMeasure(
  IncomingTalentMobilityCadenceCheckIn checkIn,
) {
  return 'Raise host confidence above 3/5 and reduce residual risk before ${checkIn.targetRole.toLowerCase()} review.';
}

String? validateIncomingTalentMobilityCadenceInterventionRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionType(
  IncomingTalentMobilityCadenceInterventionType? value,
) {
  if (value == null) return 'Select intervention type';
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionPriority(
  IncomingTalentMobilityCadenceInterventionPriority? value,
) {
  if (value == null) return 'Select priority';
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionStatus(
  IncomingTalentMobilityCadenceInterventionStatus? value,
) {
  if (value == null) return 'Select intervention status';
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionDueDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select due date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Due date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionSummary(
  String? value,
) {
  return _validateLongText(value, 'intervention summary');
}

String? validateIncomingTalentMobilityCadenceInterventionSuccessMeasure(
  String? value,
) {
  return _validateLongText(value, 'success measure');
}

String? validateIncomingTalentMobilityCadenceInterventionBlockerNote(
  String? value,
  IncomingTalentMobilityCadenceInterventionStatus? status,
) {
  if (status != IncomingTalentMobilityCadenceInterventionStatus.blocked) {
    return null;
  }
  return _validateLongText(value, 'blocker note');
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      validateIncomingTalentMobilityCadenceInterventionRequired(value, label);
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
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
