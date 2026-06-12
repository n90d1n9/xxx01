import 'relief_approval_guidance.dart';

/// Overall execution readiness for applying exception relief commands.
enum BillingExceptionReliefExecutionStatus {
  blocked,
  ready,
  controlsRequired,
  escalationRequired,
}

/// Operational phase used to group relief execution work.
enum BillingExceptionReliefExecutionPhase {
  unblock,
  approval,
  forecast,
  collections,
  recovery,
  customer,
  application,
}

/// One operator step in the exception relief execution handoff.
class BillingExceptionReliefExecutionStep {
  final BillingExceptionReliefExecutionPhase phase;
  final String label;
  final String ownerRole;
  final String description;
  final bool isRequired;
  final bool isBlocked;

  const BillingExceptionReliefExecutionStep({
    required this.phase,
    required this.label,
    required this.ownerRole,
    required this.description,
    this.isRequired = true,
    this.isBlocked = false,
  });

  String get statusLabel {
    if (isBlocked) return 'Blocked';
    return isRequired ? 'Required' : 'Optional';
  }
}

/// Ordered, display-safe execution plan for approved exception relief.
class BillingExceptionReliefExecutionPlan {
  final BillingExceptionReliefApprovalGuidance guidance;
  final BillingExceptionReliefExecutionStatus status;
  final List<BillingExceptionReliefExecutionStep> steps;
  final List<String> blockers;

  BillingExceptionReliefExecutionPlan({
    required this.guidance,
    required this.status,
    Iterable<BillingExceptionReliefExecutionStep> steps = const [],
    Iterable<String> blockers = const [],
  }) : steps = List.unmodifiable(steps),
       blockers = List.unmodifiable(blockers);

  bool get isBlocked => status == BillingExceptionReliefExecutionStatus.blocked;

  bool get requiresEscalation {
    return status == BillingExceptionReliefExecutionStatus.escalationRequired;
  }

  bool get hasSteps => steps.isNotEmpty;

  bool get hasBlockers => blockers.isNotEmpty;

  int get stepCount => steps.length;

  int get requiredStepCount {
    return steps.where((step) => step.isRequired).length;
  }

  int get blockedStepCount {
    return steps.where((step) => step.isBlocked).length;
  }

  List<BillingExceptionReliefExecutionPhase> get phases {
    final orderedPhases = <BillingExceptionReliefExecutionPhase>[];
    for (final step in steps) {
      if (!orderedPhases.contains(step.phase)) {
        orderedPhases.add(step.phase);
      }
    }

    return List.unmodifiable(orderedPhases);
  }

  int get phaseCount => phases.length;

  String get statusLabel {
    return switch (status) {
      BillingExceptionReliefExecutionStatus.blocked => 'Blocked',
      BillingExceptionReliefExecutionStatus.ready => 'Ready',
      BillingExceptionReliefExecutionStatus.controlsRequired =>
        'Controls required',
      BillingExceptionReliefExecutionStatus.escalationRequired =>
        'Escalation required',
    };
  }

  String get summaryLabel {
    return switch (status) {
      BillingExceptionReliefExecutionStatus.blocked =>
        'Execution cannot start until relief blockers are resolved.',
      BillingExceptionReliefExecutionStatus.ready =>
        'Relief commands can be applied with the standard execution handoff.',
      BillingExceptionReliefExecutionStatus.controlsRequired =>
        'Assign required controls before applying relief commands.',
      BillingExceptionReliefExecutionStatus.escalationRequired =>
        'Complete escalation review before relief commands are applied.',
    };
  }

  bool hasPhase(BillingExceptionReliefExecutionPhase phase) {
    return steps.any((step) => step.phase == phase);
  }

  List<BillingExceptionReliefExecutionStep> stepsForPhase(
    BillingExceptionReliefExecutionPhase phase,
  ) {
    return List.unmodifiable(steps.where((step) => step.phase == phase));
  }
}

/// Display labels for relief execution phases.
extension BillingExceptionReliefExecutionPhaseLabels
    on BillingExceptionReliefExecutionPhase {
  String get label {
    return switch (this) {
      BillingExceptionReliefExecutionPhase.unblock => 'Unblock',
      BillingExceptionReliefExecutionPhase.approval => 'Approval',
      BillingExceptionReliefExecutionPhase.forecast => 'Forecast',
      BillingExceptionReliefExecutionPhase.collections => 'Collections',
      BillingExceptionReliefExecutionPhase.recovery => 'Recovery',
      BillingExceptionReliefExecutionPhase.customer => 'Customer',
      BillingExceptionReliefExecutionPhase.application => 'Application',
    };
  }
}
