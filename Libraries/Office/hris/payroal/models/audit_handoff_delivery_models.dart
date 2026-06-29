import 'audit_handoff_package_models.dart';

/// Defines the channel used to route the audit handoff package.
enum AuditHandoffDeliveryChannel {
  auditWorkspace('Audit workspace'),
  secureEmail('Secure email'),
  governancePortal('Governance portal');

  final String label;

  const AuditHandoffDeliveryChannel(this.label);
}

/// Captures reviewer routing evidence for an audit handoff package.
class AuditHandoffDeliveryRecord {
  final String packageId;
  final String routedBy;
  final DateTime routedAt;
  final AuditHandoffDeliveryChannel channel;
  final List<String> recipients;
  final String note;

  const AuditHandoffDeliveryRecord({
    required this.packageId,
    required this.routedBy,
    required this.routedAt,
    required this.channel,
    required this.recipients,
    required this.note,
  });

  bool get isComplete {
    return packageId.trim().isNotEmpty &&
        routedBy.trim().isNotEmpty &&
        recipients.isNotEmpty &&
        note.trim().length >= 16;
  }

  String get recipientLabel => recipients.join(', ');
}

/// Stores editable routing input before audit handoff delivery is recorded.
class AuditHandoffDeliveryDraft {
  final String routedBy;
  final DateTime routedAt;
  final AuditHandoffDeliveryChannel channel;
  final String note;

  const AuditHandoffDeliveryDraft({
    required this.routedBy,
    required this.routedAt,
    required this.channel,
    required this.note,
  });

  factory AuditHandoffDeliveryDraft.empty(DateTime routedAt) {
    return AuditHandoffDeliveryDraft(
      routedBy: 'Payroll Controller',
      routedAt: routedAt,
      channel: AuditHandoffDeliveryChannel.auditWorkspace,
      note: 'Audit handoff package routed for reviewer validation.',
    );
  }

  AuditHandoffDeliveryDraft copyWith({
    String? routedBy,
    DateTime? routedAt,
    AuditHandoffDeliveryChannel? channel,
    String? note,
  }) {
    return AuditHandoffDeliveryDraft(
      routedBy: routedBy ?? this.routedBy,
      routedAt: routedAt ?? this.routedAt,
      channel: channel ?? this.channel,
      note: note ?? this.note,
    );
  }

  List<String> get validationErrors {
    return [
      if (routedBy.trim().isEmpty) 'Enter a routing owner',
      if (note.trim().length < 16) 'Enter routing notes',
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  AuditHandoffDeliveryRecord toRecord({
    required String packageId,
    required List<String> recipients,
  }) {
    return AuditHandoffDeliveryRecord(
      packageId: packageId,
      routedBy: routedBy.trim(),
      routedAt: routedAt,
      channel: channel,
      recipients: recipients,
      note: note.trim(),
    );
  }
}

/// Summarizes delivery readiness for the audit handoff package.
class AuditHandoffDeliverySummary {
  final AuditHandoffPackageSummary package;
  final AuditHandoffDeliveryDraft draft;
  final AuditHandoffDeliveryRecord? record;

  const AuditHandoffDeliverySummary({
    required this.package,
    required this.draft,
    required this.record,
  });

  bool get isDelivered => record?.isComplete == true;

  bool get canRoute => package.canHandoff && !isDelivered;

  bool get canReopen => isDelivered;

  String get periodLabel => package.periodLabel;

  String get statusLabel {
    if (isDelivered) return 'Delivered';
    if (package.canHandoff) return 'Ready';
    return 'Blocked';
  }

  String get nextAction {
    if (isDelivered) {
      return '${package.packageId} routed via ${record!.channel.label}.';
    }
    if (!package.canHandoff) return package.nextAction;
    return 'Route audit handoff package to reviewers.';
  }
}
