import 'financial_report_pack.dart';

enum FinancialReportEvidenceCloseTaskPriority { monitor, action }

extension FinancialReportEvidenceCloseTaskPriorityLabel
    on FinancialReportEvidenceCloseTaskPriority {
  String get label {
    switch (this) {
      case FinancialReportEvidenceCloseTaskPriority.monitor:
        return 'Monitor';
      case FinancialReportEvidenceCloseTaskPriority.action:
        return 'Action';
    }
  }
}

enum FinancialReportEvidenceCloseTaskResolutionStatus {
  completed,
  approved,
  deferred,
}

extension FinancialReportEvidenceCloseTaskResolutionStatusLabel
    on FinancialReportEvidenceCloseTaskResolutionStatus {
  String get label {
    switch (this) {
      case FinancialReportEvidenceCloseTaskResolutionStatus.completed:
        return 'Completed';
      case FinancialReportEvidenceCloseTaskResolutionStatus.approved:
        return 'Approved';
      case FinancialReportEvidenceCloseTaskResolutionStatus.deferred:
        return 'Deferred';
    }
  }
}

enum FinancialReportEvidenceTaskAuditAction { evidenceSaved }

extension FinancialReportEvidenceTaskAuditActionLabel
    on FinancialReportEvidenceTaskAuditAction {
  String get label {
    switch (this) {
      case FinancialReportEvidenceTaskAuditAction.evidenceSaved:
        return 'Evidence saved';
    }
  }
}

class FinancialReportEvidenceCloseTask {
  final String id;
  final FinancialReportSupportingScheduleKind scheduleKind;
  final String scheduleTitle;
  final FinancialReportEvidenceCloseTaskPriority priority;
  final String title;
  final String actionLabel;
  final String owner;
  final DateTime dueDate;
  final String reviewer;
  final String evidenceLabel;
  final String reference;
  final int criticalSignalCount;
  final int watchSignalCount;
  final int readySignalCount;

  const FinancialReportEvidenceCloseTask({
    required this.id,
    required this.scheduleKind,
    required this.scheduleTitle,
    required this.priority,
    required this.title,
    required this.actionLabel,
    required this.owner,
    required this.dueDate,
    required this.reviewer,
    required this.evidenceLabel,
    required this.reference,
    required this.criticalSignalCount,
    required this.watchSignalCount,
    required this.readySignalCount,
  });

  bool get blocksClose =>
      priority == FinancialReportEvidenceCloseTaskPriority.action;

  String get signalLabel {
    final labels = <String>[
      if (criticalSignalCount > 0) '$criticalSignalCount critical',
      if (watchSignalCount > 0) '$watchSignalCount watch',
      if (readySignalCount > 0) '$readySignalCount ready',
    ];
    return labels.isEmpty ? 'No open signals' : labels.join(' / ');
  }
}

class FinancialReportEvidenceCloseTaskResolution {
  final String taskId;
  final FinancialReportEvidenceCloseTaskResolutionStatus status;
  final String reviewer;
  final DateTime resolvedAt;
  final String note;
  final String? evidenceReference;

  const FinancialReportEvidenceCloseTaskResolution({
    required this.taskId,
    required this.status,
    required this.reviewer,
    required this.resolvedAt,
    required this.note,
    this.evidenceReference,
  });

  factory FinancialReportEvidenceCloseTaskResolution.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportEvidenceCloseTaskResolution(
      taskId: json['taskId'] as String,
      status: _resolutionStatusFromJson(json['status'] as String?),
      reviewer: json['reviewer'] as String? ?? '',
      resolvedAt: _dateTimeFromJson(json['resolvedAt']) ?? DateTime.now(),
      note: json['note'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
    );
  }

  bool get clearsCloseBlocker {
    switch (status) {
      case FinancialReportEvidenceCloseTaskResolutionStatus.completed:
      case FinancialReportEvidenceCloseTaskResolutionStatus.approved:
        return true;
      case FinancialReportEvidenceCloseTaskResolutionStatus.deferred:
        return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'status': status.name,
      'reviewer': reviewer,
      'resolvedAt': resolvedAt.toIso8601String(),
      'note': note,
      'evidenceReference': evidenceReference,
    };
  }
}

class FinancialReportEvidenceCloseTaskReviewItem {
  final FinancialReportEvidenceCloseTask task;
  final FinancialReportEvidenceCloseTaskResolution? resolution;

  const FinancialReportEvidenceCloseTaskReviewItem({
    required this.task,
    this.resolution,
  });

  String get id => task.id;

  bool get isResolved => resolution?.clearsCloseBlocker ?? false;

  bool get blocksClose => task.blocksClose && !isResolved;

  FinancialReportEvidenceCloseTaskPriority get priority => task.priority;
}

class FinancialReportEvidenceTaskAuditEvent {
  final String id;
  final String periodKey;
  final String periodLabel;
  final String taskId;
  final String taskTitle;
  final String scheduleTitle;
  final FinancialReportEvidenceTaskAuditAction action;
  final DateTime occurredAt;
  final String actor;
  final FinancialReportEvidenceCloseTaskResolutionStatus status;
  final String note;
  final String? evidenceReference;

  const FinancialReportEvidenceTaskAuditEvent({
    required this.id,
    required this.periodKey,
    required this.periodLabel,
    required this.taskId,
    required this.taskTitle,
    required this.scheduleTitle,
    required this.action,
    required this.occurredAt,
    required this.actor,
    required this.status,
    required this.note,
    this.evidenceReference,
  });

  factory FinancialReportEvidenceTaskAuditEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportEvidenceTaskAuditEvent(
      id: json['id'] as String,
      periodKey: json['periodKey'] as String,
      periodLabel: json['periodLabel'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String? ?? '',
      scheduleTitle: json['scheduleTitle'] as String? ?? '',
      action: _auditActionFromJson(json['action'] as String?),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      actor: json['actor'] as String? ?? 'Unknown',
      status: _resolutionStatusFromJson(json['status'] as String?),
      note: json['note'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodKey': periodKey,
      'periodLabel': periodLabel,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'scheduleTitle': scheduleTitle,
      'action': action.name,
      'occurredAt': occurredAt.toIso8601String(),
      'actor': actor,
      'status': status.name,
      'note': note,
      'evidenceReference': evidenceReference,
    };
  }
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}

FinancialReportEvidenceCloseTaskResolutionStatus _resolutionStatusFromJson(
  String? value,
) {
  switch (value) {
    case 'completed':
      return FinancialReportEvidenceCloseTaskResolutionStatus.completed;
    case 'deferred':
      return FinancialReportEvidenceCloseTaskResolutionStatus.deferred;
    case 'approved':
    default:
      return FinancialReportEvidenceCloseTaskResolutionStatus.approved;
  }
}

FinancialReportEvidenceTaskAuditAction _auditActionFromJson(String? value) {
  switch (value) {
    case 'evidenceSaved':
    default:
      return FinancialReportEvidenceTaskAuditAction.evidenceSaved;
  }
}
