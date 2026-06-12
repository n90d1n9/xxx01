enum FinancialReportReleaseDistributionChannel {
  secureLink,
  email,
  portal,
  printedPack,
}

extension FinancialReportReleaseDistributionChannelLabel
    on FinancialReportReleaseDistributionChannel {
  String get label {
    switch (this) {
      case FinancialReportReleaseDistributionChannel.secureLink:
        return 'Secure link';
      case FinancialReportReleaseDistributionChannel.email:
        return 'Email';
      case FinancialReportReleaseDistributionChannel.portal:
        return 'Portal';
      case FinancialReportReleaseDistributionChannel.printedPack:
        return 'Printed pack';
    }
  }
}

enum FinancialReportReleaseDistributionStatus {
  pending,
  sent,
  acknowledged,
  exception,
}

extension FinancialReportReleaseDistributionStatusLabel
    on FinancialReportReleaseDistributionStatus {
  String get label {
    switch (this) {
      case FinancialReportReleaseDistributionStatus.pending:
        return 'Pending';
      case FinancialReportReleaseDistributionStatus.sent:
        return 'Sent';
      case FinancialReportReleaseDistributionStatus.acknowledged:
        return 'Acknowledged';
      case FinancialReportReleaseDistributionStatus.exception:
        return 'Exception';
    }
  }
}

enum FinancialReportReleaseDistributionAuditAction {
  sent,
  acknowledged,
  exception,
  cleared,
}

extension FinancialReportReleaseDistributionAuditActionLabel
    on FinancialReportReleaseDistributionAuditAction {
  String get label {
    switch (this) {
      case FinancialReportReleaseDistributionAuditAction.sent:
        return 'Sent';
      case FinancialReportReleaseDistributionAuditAction.acknowledged:
        return 'Acknowledged';
      case FinancialReportReleaseDistributionAuditAction.exception:
        return 'Exception';
      case FinancialReportReleaseDistributionAuditAction.cleared:
        return 'Cleared';
    }
  }
}

class FinancialReportReleaseDistributionRecipient {
  final String id;
  final String name;
  final String role;
  final String organization;
  final FinancialReportReleaseDistributionChannel channel;
  final bool requiresAcknowledgement;
  final DateTime dueDate;
  final String purpose;

  const FinancialReportReleaseDistributionRecipient({
    required this.id,
    required this.name,
    required this.role,
    required this.organization,
    required this.channel,
    required this.requiresAcknowledgement,
    required this.dueDate,
    required this.purpose,
  });
}

class FinancialReportReleaseDistributionResolution {
  final String recipientId;
  final FinancialReportReleaseDistributionStatus status;
  final String owner;
  final DateTime updatedAt;
  final String note;
  final String? evidenceReference;

  const FinancialReportReleaseDistributionResolution({
    required this.recipientId,
    required this.status,
    required this.owner,
    required this.updatedAt,
    required this.note,
    this.evidenceReference,
  });

  factory FinancialReportReleaseDistributionResolution.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportReleaseDistributionResolution(
      recipientId: json['recipientId'] as String? ?? '',
      status: _statusFromJson(json['status'] as String?),
      owner: json['owner'] as String? ?? '',
      updatedAt: _dateTimeFromJson(json['updatedAt']) ?? DateTime.now(),
      note: json['note'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'status': status.name,
      'owner': owner,
      'updatedAt': updatedAt.toIso8601String(),
      'note': note,
      'evidenceReference': evidenceReference,
    };
  }
}

class FinancialReportReleaseDistributionItem {
  final FinancialReportReleaseDistributionRecipient recipient;
  final FinancialReportReleaseDistributionResolution? resolution;

  const FinancialReportReleaseDistributionItem({
    required this.recipient,
    this.resolution,
  });

  String get id => recipient.id;

  FinancialReportReleaseDistributionStatus get status =>
      resolution?.status ?? FinancialReportReleaseDistributionStatus.pending;

  String get statusLabel => status.label;

  bool get isSent =>
      status == FinancialReportReleaseDistributionStatus.sent ||
      status == FinancialReportReleaseDistributionStatus.acknowledged;

  bool get isAcknowledged =>
      status == FinancialReportReleaseDistributionStatus.acknowledged;

  bool get hasException =>
      status == FinancialReportReleaseDistributionStatus.exception;

  bool get isComplete {
    if (recipient.requiresAcknowledgement) {
      return isAcknowledged;
    }
    return isSent;
  }

  bool isOverdue(DateTime asOf) {
    return !isComplete && asOf.isAfter(recipient.dueDate);
  }
}

class FinancialReportReleaseDistributionAuditEvent {
  final String id;
  final String periodKey;
  final String periodLabel;
  final String recipientId;
  final String recipientName;
  final FinancialReportReleaseDistributionChannel channel;
  final FinancialReportReleaseDistributionAuditAction action;
  final DateTime occurredAt;
  final String actor;
  final FinancialReportReleaseDistributionStatus? status;
  final String note;
  final String? evidenceReference;

  const FinancialReportReleaseDistributionAuditEvent({
    required this.id,
    required this.periodKey,
    required this.periodLabel,
    required this.recipientId,
    required this.recipientName,
    required this.channel,
    required this.action,
    required this.occurredAt,
    required this.actor,
    this.status,
    required this.note,
    this.evidenceReference,
  });

  factory FinancialReportReleaseDistributionAuditEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportReleaseDistributionAuditEvent(
      id: json['id'] as String? ?? '',
      periodKey: json['periodKey'] as String? ?? '',
      periodLabel: json['periodLabel'] as String? ?? '',
      recipientId: json['recipientId'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      channel: _channelFromJson(json['channel'] as String?),
      action: _auditActionFromJson(json['action'] as String?),
      occurredAt: _dateTimeFromJson(json['occurredAt']) ?? DateTime.now(),
      actor: json['actor'] as String? ?? '',
      status: _nullableStatusFromJson(json['status'] as String?),
      note: json['note'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'channel': channel.name,
      'action': action.name,
      'occurredAt': occurredAt.toIso8601String(),
      'actor': actor,
      'status': status?.name,
      'note': note,
      'evidenceReference': evidenceReference,
    };
  }
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value as String);
}

FinancialReportReleaseDistributionStatus _statusFromJson(String? value) {
  return _nullableStatusFromJson(value) ??
      FinancialReportReleaseDistributionStatus.pending;
}

FinancialReportReleaseDistributionStatus? _nullableStatusFromJson(
  String? value,
) {
  switch (value) {
    case 'sent':
      return FinancialReportReleaseDistributionStatus.sent;
    case 'acknowledged':
      return FinancialReportReleaseDistributionStatus.acknowledged;
    case 'exception':
      return FinancialReportReleaseDistributionStatus.exception;
    case 'pending':
      return FinancialReportReleaseDistributionStatus.pending;
    default:
      return null;
  }
}

FinancialReportReleaseDistributionChannel _channelFromJson(String? value) {
  switch (value) {
    case 'email':
      return FinancialReportReleaseDistributionChannel.email;
    case 'portal':
      return FinancialReportReleaseDistributionChannel.portal;
    case 'printedPack':
      return FinancialReportReleaseDistributionChannel.printedPack;
    case 'secureLink':
    default:
      return FinancialReportReleaseDistributionChannel.secureLink;
  }
}

FinancialReportReleaseDistributionAuditAction _auditActionFromJson(
  String? value,
) {
  switch (value) {
    case 'acknowledged':
      return FinancialReportReleaseDistributionAuditAction.acknowledged;
    case 'exception':
      return FinancialReportReleaseDistributionAuditAction.exception;
    case 'cleared':
      return FinancialReportReleaseDistributionAuditAction.cleared;
    case 'sent':
    default:
      return FinancialReportReleaseDistributionAuditAction.sent;
  }
}
