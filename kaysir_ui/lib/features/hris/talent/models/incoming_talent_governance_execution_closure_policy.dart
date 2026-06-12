import 'incoming_talent_governance_execution_action.dart';
import 'incoming_talent_governance_execution_closure.dart';

/// Defaulting and validation policy for governance execution closures.
class IncomingTalentGovernanceExecutionClosureDefaults {
  final IncomingTalentGovernanceExecutionClosureOutcome outcome;
  final int residualRiskCount;
  final String evidenceSummary;
  final String ownerConfirmationNote;
  final String nextAction;
  final Duration nextReviewOffset;

  const IncomingTalentGovernanceExecutionClosureDefaults({
    required this.outcome,
    required this.residualRiskCount,
    required this.evidenceSummary,
    required this.ownerConfirmationNote,
    required this.nextAction,
    required this.nextReviewOffset,
  });

  factory IncomingTalentGovernanceExecutionClosureDefaults.fromAction(
    IncomingTalentGovernanceExecutionAction action,
  ) {
    final residualRiskCount =
        defaultIncomingTalentGovernanceExecutionClosureResidualRiskCount(
          action,
        );
    final outcome = defaultIncomingTalentGovernanceExecutionClosureOutcome(
      action: action,
      residualRiskCount: residualRiskCount,
    );

    return IncomingTalentGovernanceExecutionClosureDefaults(
      outcome: outcome,
      residualRiskCount: residualRiskCount,
      evidenceSummary: defaultIncomingTalentGovernanceExecutionClosureEvidence(
        action,
      ),
      ownerConfirmationNote:
          defaultIncomingTalentGovernanceExecutionClosureOwnerNote(action),
      nextAction: defaultIncomingTalentGovernanceExecutionClosureNextAction(
        outcome,
      ),
      nextReviewOffset:
          defaultIncomingTalentGovernanceExecutionClosureNextReviewOffset(
            outcome,
          ),
    );
  }
}

int defaultIncomingTalentGovernanceExecutionClosureResidualRiskCount(
  IncomingTalentGovernanceExecutionAction action,
) {
  if (action.overdue ||
      action.priority ==
          IncomingTalentGovernanceExecutionActionPriority.critical) {
    return 1;
  }
  return 0;
}

IncomingTalentGovernanceExecutionClosureOutcome
defaultIncomingTalentGovernanceExecutionClosureOutcome({
  required IncomingTalentGovernanceExecutionAction action,
  required int residualRiskCount,
}) {
  if (action.overdue) {
    return IncomingTalentGovernanceExecutionClosureOutcome.monitor;
  }
  if (residualRiskCount > 1) {
    return IncomingTalentGovernanceExecutionClosureOutcome.reopened;
  }
  if (residualRiskCount > 0 ||
      action.priority == IncomingTalentGovernanceExecutionActionPriority.high) {
    return IncomingTalentGovernanceExecutionClosureOutcome.monitor;
  }
  return IncomingTalentGovernanceExecutionClosureOutcome.completed;
}

String defaultIncomingTalentGovernanceExecutionClosureEvidence(
  IncomingTalentGovernanceExecutionAction action,
) {
  return 'Closure evidence for ${action.detail.toLowerCase()}: ${action.evidenceExpectation}';
}

String defaultIncomingTalentGovernanceExecutionClosureOwnerNote(
  IncomingTalentGovernanceExecutionAction action,
) {
  return '${action.ownerName} confirms ${action.nextAction.toLowerCase()}';
}

String defaultIncomingTalentGovernanceExecutionClosureNextAction(
  IncomingTalentGovernanceExecutionClosureOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentGovernanceExecutionClosureOutcome.completed =>
      'Archive governance execution evidence and return to standard review cadence.',
    IncomingTalentGovernanceExecutionClosureOutcome.monitor =>
      'Monitor closure evidence in the next governance check-in.',
    IncomingTalentGovernanceExecutionClosureOutcome.reopened =>
      'Reopen governance execution with clearer owner commitment and evidence.',
    IncomingTalentGovernanceExecutionClosureOutcome.escalated =>
      'Escalate unresolved governance execution to leadership review.',
  };
}

Duration defaultIncomingTalentGovernanceExecutionClosureNextReviewOffset(
  IncomingTalentGovernanceExecutionClosureOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentGovernanceExecutionClosureOutcome.completed => const Duration(
      days: 45,
    ),
    IncomingTalentGovernanceExecutionClosureOutcome.monitor => const Duration(
      days: 14,
    ),
    IncomingTalentGovernanceExecutionClosureOutcome.reopened => const Duration(
      days: 7,
    ),
    IncomingTalentGovernanceExecutionClosureOutcome.escalated => const Duration(
      days: 3,
    ),
  };
}

String? validateIncomingTalentGovernanceExecutionClosureRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentGovernanceExecutionClosureDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select closure date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Closure date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentGovernanceExecutionClosureOutcome(
  IncomingTalentGovernanceExecutionClosureOutcome? value,
) {
  if (value == null) return 'Select closure outcome';
  return null;
}

String? validateIncomingTalentGovernanceExecutionClosureResidualRisk(
  int value,
) {
  if (value < 0) return 'Residual risk cannot be negative';
  if (value > 5) return 'Residual risk must be 5 or fewer';
  return null;
}

String? validateIncomingTalentGovernanceExecutionClosureNextReviewDate(
  DateTime? closureDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select next review date';
  if (closureDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(closureDate))) {
    return 'Next review must be after closure date';
  }
  return null;
}

String? validateIncomingTalentGovernanceExecutionClosureLongText(
  String? value,
  String label,
) {
  final requiredError =
      validateIncomingTalentGovernanceExecutionClosureRequired(value, label);
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

DateTime dateOnlyIncomingTalentGovernanceExecutionClosure(DateTime value) {
  return _dateOnly(value);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
