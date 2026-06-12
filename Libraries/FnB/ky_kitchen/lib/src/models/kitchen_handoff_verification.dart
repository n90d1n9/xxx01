import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_handoff_readiness.dart';
import 'kitchen_operator_context.dart';
import 'kitchen_ticket.dart';

/// User-facing reason shown when handoff checks block serving a ticket.
const kitchenHandoffVerificationBlockReason =
    'Complete handoff checks before serving.';

/// Audit detail for a completed handoff verification step.
class KitchenHandoffVerificationRecord {
  const KitchenHandoffVerificationRecord({
    required this.stepId,
    required this.verifiedAt,
    required this.verifiedBy,
    this.verifiedById,
    this.verifiedByRole,
  });

  /// Builds a verification record from the current operator context.
  factory KitchenHandoffVerificationRecord.fromOperator({
    required String stepId,
    required DateTime verifiedAt,
    required KitchenOperatorContext operatorContext,
  }) {
    return KitchenHandoffVerificationRecord(
      stepId: stepId,
      verifiedAt: verifiedAt,
      verifiedBy: operatorContext.verifierLabel,
      verifiedById: operatorContext.normalizedId,
      verifiedByRole: operatorContext.roleBadgeLabel,
    );
  }

  final String stepId;
  final DateTime verifiedAt;
  final String verifiedBy;
  final String? verifiedById;
  final String? verifiedByRole;

  String get verifierLabel {
    final label = verifiedBy.trim();
    return label.isEmpty ? 'Kitchen' : label;
  }

  String get verifiedAtClockLabel {
    return '${_twoDigits(verifiedAt.hour)}:${_twoDigits(verifiedAt.minute)}';
  }

  String get auditLabel {
    return 'Verified: $verifierLabel - $verifiedAtClockLabel';
  }

  @override
  bool operator ==(Object other) {
    return other is KitchenHandoffVerificationRecord &&
        other.stepId == stepId &&
        other.verifiedAt == verifiedAt &&
        other.verifiedBy == verifiedBy &&
        other.verifiedById == verifiedById &&
        other.verifiedByRole == verifiedByRole;
  }

  @override
  int get hashCode {
    return Object.hash(
      stepId,
      verifiedAt,
      verifiedBy,
      verifiedById,
      verifiedByRole,
    );
  }
}

/// Types of verification work needed before handoff.
enum KitchenHandoffVerificationStepType {
  criticalAlerts,
  serviceAlerts,
  serviceNotes,
  timing;

  String get label => switch (this) {
    KitchenHandoffVerificationStepType.criticalAlerts => 'Critical alerts',
    KitchenHandoffVerificationStepType.serviceAlerts => 'Service alerts',
    KitchenHandoffVerificationStepType.serviceNotes => 'Service notes',
    KitchenHandoffVerificationStepType.timing => 'Timing',
  };
}

/// One checklist item in the handoff verification flow.
class KitchenHandoffVerificationStep {
  const KitchenHandoffVerificationStep({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    this.required = true,
  });

  final String id;
  final KitchenHandoffVerificationStepType type;
  final String label;
  final String description;
  final bool required;
}

/// Tracks which handoff verification steps are complete for a ready ticket.
class KitchenHandoffVerificationPlan {
  KitchenHandoffVerificationPlan({
    required Iterable<KitchenHandoffVerificationStep> steps,
    Iterable<String> verifiedStepIds = const [],
    Iterable<KitchenHandoffVerificationRecord> records = const [],
  }) : steps = List<KitchenHandoffVerificationStep>.unmodifiable(steps),
       verificationRecords =
           Map<String, KitchenHandoffVerificationRecord>.unmodifiable({
             for (final record in records) record.stepId: record,
           }),
       verifiedStepIds = Set<String>.unmodifiable({
         ...verifiedStepIds,
         for (final record in records) record.stepId,
       });

  /// Builds a verification plan from a ready ticket and its handoff readiness.
  factory KitchenHandoffVerificationPlan.fromTicket({
    required KitchenTicket ticket,
    required DateTime now,
    Iterable<String> verifiedStepIds = const [],
    Iterable<KitchenHandoffVerificationRecord> records = const [],
  }) {
    if (ticket.stage != KitchenTicketStage.ready) {
      return KitchenHandoffVerificationPlan(
        steps: const [],
        verifiedStepIds: verifiedStepIds,
        records: records,
      );
    }

    final readiness = KitchenHandoffReadiness(ticket: ticket, now: now);
    return KitchenHandoffVerificationPlan(
      steps: _stepsForReadiness(readiness),
      verifiedStepIds: verifiedStepIds,
      records: records,
    );
  }

  final List<KitchenHandoffVerificationStep> steps;
  final Map<String, KitchenHandoffVerificationRecord> verificationRecords;
  final Set<String> verifiedStepIds;

  bool get hasSteps => steps.isNotEmpty;

  Iterable<KitchenHandoffVerificationStep> get requiredSteps {
    return steps.where((step) => step.required);
  }

  int get requiredStepCount => requiredSteps.length;

  int get verifiedRequiredCount {
    return requiredSteps
        .where((step) => verifiedStepIds.contains(step.id))
        .length;
  }

  int get pendingRequiredCount {
    return requiredStepCount - verifiedRequiredCount;
  }

  bool get isComplete => pendingRequiredCount == 0;

  bool get blocksServing => hasSteps && !isComplete;

  String? get serveBlockReason {
    return blocksServing ? kitchenHandoffVerificationBlockReason : null;
  }

  String get progressLabel {
    if (!hasSteps) return 'No checks needed';
    return '$verifiedRequiredCount / $requiredStepCount verified';
  }

  String get statusLabel {
    if (!hasSteps) return 'Ready to serve';
    if (isComplete) return 'Handoff verified';
    return pendingRequiredCount == 1
        ? '1 check remaining'
        : '$pendingRequiredCount checks remaining';
  }

  bool isVerified(String stepId) {
    return verifiedStepIds.contains(stepId);
  }

  KitchenHandoffVerificationRecord? recordFor(String stepId) {
    return verificationRecords[stepId];
  }
}

List<KitchenHandoffVerificationStep> _stepsForReadiness(
  KitchenHandoffReadiness readiness,
) {
  final criticalAlerts = readiness.alerts
      .where((alert) => alert.critical)
      .toList(growable: false);
  final serviceAlerts = readiness.alerts
      .where((alert) => !alert.critical)
      .toList(growable: false);
  final steps = <KitchenHandoffVerificationStep>[];

  if (criticalAlerts.isNotEmpty) {
    steps.add(
      KitchenHandoffVerificationStep(
        id: 'critical-alerts',
        type: KitchenHandoffVerificationStepType.criticalAlerts,
        label: criticalAlerts.length == 1
            ? 'Verify critical alert'
            : 'Verify ${criticalAlerts.length} critical alerts',
        description: _alertDescription(criticalAlerts),
      ),
    );
  }

  if (serviceAlerts.isNotEmpty) {
    steps.add(
      KitchenHandoffVerificationStep(
        id: 'service-alerts',
        type: KitchenHandoffVerificationStepType.serviceAlerts,
        label: serviceAlerts.length == 1
            ? 'Review service alert'
            : 'Review ${serviceAlerts.length} service alerts',
        description: _alertDescription(serviceAlerts),
      ),
    );
  }

  final note = readiness.serviceNoteLabel;
  if (note != null) {
    steps.add(
      KitchenHandoffVerificationStep(
        id: 'service-notes',
        type: KitchenHandoffVerificationStepType.serviceNotes,
        label: 'Review service note',
        description: note,
      ),
    );
  }

  if (readiness.isLate) {
    steps.add(
      KitchenHandoffVerificationStep(
        id: 'handoff-timing',
        type: KitchenHandoffVerificationStepType.timing,
        label: 'Confirm delayed handoff',
        description: readiness.ticket.timingLabel(readiness.now),
      ),
    );
  }

  return steps;
}

String _alertDescription(List<FnbServiceAlert> alerts) {
  return alerts.map((alert) => alert.compactLabel).join(', ');
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
