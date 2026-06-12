import 'billing_exception_event.dart';
import 'exception_relief_plan.dart';

/// Readiness state for applying an evaluated exception relief plan.
enum BillingExceptionReliefApplicationStatus { ready, blocked }

/// Issue that prevents a relief application packet from being executable.
enum BillingExceptionReliefApplicationIssueKind {
  planNotActionable,
  noCommands,
}

/// Immutable command generated from one operational relief action.
class BillingExceptionReliefApplicationCommand {
  final String id;
  final BillingExceptionReliefActionKind actionKind;
  final String label;
  final String description;
  final Map<String, Object?> payload;

  BillingExceptionReliefApplicationCommand({
    required this.id,
    required this.actionKind,
    required this.label,
    required this.description,
    Map<String, Object?> payload = const {},
  }) : payload = Map.unmodifiable(payload);

  bool get isEmpty => payload.isEmpty;
}

/// Display-safe audit fact captured with a relief application packet.
class BillingExceptionReliefAuditFact {
  final String label;
  final String value;

  const BillingExceptionReliefAuditFact({
    required this.label,
    required this.value,
  });
}

/// Human-readable blocker for relief application handoff.
class BillingExceptionReliefApplicationIssue {
  final BillingExceptionReliefApplicationIssueKind kind;
  final String message;
  final String? details;

  const BillingExceptionReliefApplicationIssue({
    required this.kind,
    required this.message,
    this.details,
  });
}

/// Auditable handoff packet for applying exception relief to billing records.
class BillingExceptionReliefApplicationPacket {
  final BillingExceptionReliefPlan plan;
  final String requestedBy;
  final DateTime requestedAt;
  final List<BillingExceptionReliefApplicationCommand> commands;
  final List<BillingExceptionReliefAuditFact> auditFacts;
  final List<BillingExceptionReliefApplicationIssue> issues;

  BillingExceptionReliefApplicationPacket({
    required this.plan,
    required this.requestedBy,
    required this.requestedAt,
    Iterable<BillingExceptionReliefApplicationCommand> commands = const [],
    Iterable<BillingExceptionReliefAuditFact> auditFacts = const [],
    Iterable<BillingExceptionReliefApplicationIssue> issues = const [],
  }) : commands = List.unmodifiable(commands),
       auditFacts = List.unmodifiable(auditFacts),
       issues = List.unmodifiable(issues);

  BillingExceptionReliefApplicationStatus get status {
    return isReady
        ? BillingExceptionReliefApplicationStatus.ready
        : BillingExceptionReliefApplicationStatus.blocked;
  }

  bool get isReady => issues.isEmpty && commands.isNotEmpty;

  bool get hasIssues => issues.isNotEmpty;

  int get commandCount => commands.length;

  int get auditFactCount => auditFacts.length;

  String get statusLabel {
    return switch (status) {
      BillingExceptionReliefApplicationStatus.ready => 'Ready',
      BillingExceptionReliefApplicationStatus.blocked => 'Blocked',
    };
  }

  String get summaryLabel {
    if (issues.isNotEmpty) {
      return 'Application is blocked until the relief plan is actionable.';
    }
    if (commands.isEmpty) {
      return 'No operational relief commands are available to apply.';
    }

    return '$commandCount relief ${commandCount == 1 ? 'command' : 'commands'} '
        'ready for ${plan.kind.label.toLowerCase()}.';
  }

  String get packetKey {
    return [
      plan.kind.name,
      plan.affectedInvoiceCount,
      plan.openAmount.toStringAsFixed(2),
      plan.reliefDurationDays,
      commandCount,
      requestedBy.trim().toLowerCase(),
    ].join(':');
  }

  bool hasIssueKind(BillingExceptionReliefApplicationIssueKind kind) {
    return issues.any((issue) => issue.kind == kind);
  }
}
