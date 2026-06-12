enum EmployeeComplianceDocumentType {
  identity('Identity'),
  agreement('Agreement'),
  tax('Tax'),
  policy('Policy'),
  workPermit('Work permit'),
  performance('Performance'),
  certification('Certification');

  final String label;

  const EmployeeComplianceDocumentType(this.label);
}

enum EmployeeComplianceDocumentStatus {
  pending('Pending'),
  verified('Verified'),
  rejected('Rejected'),
  expired('Expired'),
  waived('Waived');

  final String label;

  const EmployeeComplianceDocumentStatus(this.label);
}

class EmployeeComplianceDocumentRecord {
  final String id;
  final String employeeId;
  final String title;
  final EmployeeComplianceDocumentType type;
  final String owner;
  final DateTime dueDate;
  final DateTime? expiresAt;
  final DateTime uploadedAt;
  final EmployeeComplianceDocumentStatus status;
  final String notes;
  final String correlationId;

  const EmployeeComplianceDocumentRecord({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.type,
    required this.owner,
    required this.dueDate,
    required this.expiresAt,
    required this.uploadedAt,
    required this.status,
    required this.notes,
    this.correlationId = '',
  });

  bool get isVerified => status == EmployeeComplianceDocumentStatus.verified;

  bool isOverdue(DateTime asOfDate) {
    return !isVerified &&
        status != EmployeeComplianceDocumentStatus.waived &&
        dueDate.isBefore(_dateOnly(asOfDate));
  }

  bool isExpired(DateTime asOfDate) {
    final expiry = expiresAt;
    if (expiry == null) {
      return status == EmployeeComplianceDocumentStatus.expired;
    }
    return expiry.isBefore(_dateOnly(asOfDate)) ||
        status == EmployeeComplianceDocumentStatus.expired;
  }

  bool isExpiringSoon(DateTime asOfDate) {
    final expiry = expiresAt;
    if (expiry == null || isExpired(asOfDate)) return false;
    final today = _dateOnly(asOfDate);
    return !expiry.isAfter(today.add(const Duration(days: 45)));
  }

  bool needsAttention(DateTime asOfDate) {
    return status == EmployeeComplianceDocumentStatus.pending ||
        status == EmployeeComplianceDocumentStatus.rejected ||
        isOverdue(asOfDate) ||
        isExpired(asOfDate) ||
        isExpiringSoon(asOfDate);
  }

  EmployeeComplianceDocumentRecord copyWith({
    DateTime? expiresAt,
    EmployeeComplianceDocumentStatus? status,
    String? notes,
    String? correlationId,
  }) {
    return EmployeeComplianceDocumentRecord(
      id: id,
      employeeId: employeeId,
      title: title,
      type: type,
      owner: owner,
      dueDate: dueDate,
      expiresAt: expiresAt ?? this.expiresAt,
      uploadedAt: uploadedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      correlationId: correlationId ?? this.correlationId,
    );
  }
}

class EmployeeComplianceDocumentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String title;
  final EmployeeComplianceDocumentType type;
  final String owner;
  final DateTime? dueDate;
  final DateTime? expiresAt;
  final String notes;
  final String correlationId;

  const EmployeeComplianceDocumentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.title,
    required this.type,
    required this.owner,
    required this.dueDate,
    required this.expiresAt,
    required this.notes,
    this.correlationId = '',
  });

  EmployeeComplianceDocumentDraft copyWith({
    String? title,
    EmployeeComplianceDocumentType? type,
    String? owner,
    DateTime? dueDate,
    DateTime? expiresAt,
    String? notes,
    String? correlationId,
  }) {
    return EmployeeComplianceDocumentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      title: title ?? this.title,
      type: type ?? this.type,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      expiresAt: expiresAt ?? this.expiresAt,
      notes: notes ?? this.notes,
      correlationId: correlationId ?? this.correlationId,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Document title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Document owner is required');
    }
    if (dueDate == null) {
      errors.add('Due date is required');
    }
    if (expiresAt != null && dueDate != null && expiresAt!.isBefore(dueDate!)) {
      errors.add('Expiry date cannot be before due date');
    }
    if (notes.trim().length < 8) {
      errors.add('Notes must be at least 8 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (title.trim().length >= 4) complete++;
    if (owner.trim().length >= 3) complete++;
    if (dueDate != null) complete++;
    if (expiresAt == null || !expiresAt!.isBefore(dueDate ?? asOfDate)) {
      complete++;
    }
    if (notes.trim().length >= 8) complete++;
    return complete / 5;
  }

  EmployeeComplianceDocumentRecord toRecord({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeComplianceDocumentRecord(
      id: id,
      employeeId: employeeId,
      title: title.trim(),
      type: type,
      owner: owner.trim(),
      dueDate: dueDate!,
      expiresAt: expiresAt,
      uploadedAt: asOfDate,
      status: EmployeeComplianceDocumentStatus.pending,
      notes: notes.trim(),
      correlationId: correlationId.trim(),
    );
  }
}

class EmployeeComplianceDocumentSummary {
  final int totalCount;
  final int pendingCount;
  final int verifiedCount;
  final int rejectedCount;
  final int overdueCount;
  final int expiringSoonCount;

  const EmployeeComplianceDocumentSummary({
    required this.totalCount,
    required this.pendingCount,
    required this.verifiedCount,
    required this.rejectedCount,
    required this.overdueCount,
    required this.expiringSoonCount,
  });

  factory EmployeeComplianceDocumentSummary.fromRecords({
    required List<EmployeeComplianceDocumentRecord> records,
    required DateTime asOfDate,
  }) {
    return EmployeeComplianceDocumentSummary(
      totalCount: records.length,
      pendingCount:
          records
              .where(
                (record) =>
                    record.status == EmployeeComplianceDocumentStatus.pending,
              )
              .length,
      verifiedCount:
          records
              .where(
                (record) =>
                    record.status == EmployeeComplianceDocumentStatus.verified,
              )
              .length,
      rejectedCount:
          records
              .where(
                (record) =>
                    record.status == EmployeeComplianceDocumentStatus.rejected,
              )
              .length,
      overdueCount:
          records.where((record) => record.isOverdue(asOfDate)).length,
      expiringSoonCount:
          records.where((record) => record.isExpiringSoon(asOfDate)).length,
    );
  }

  String get nextAction {
    if (rejectedCount > 0) {
      return 'Resolve $rejectedCount rejected document${rejectedCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Review $overdueCount overdue document${overdueCount == 1 ? '' : 's'}.';
    }
    if (expiringSoonCount > 0) {
      return 'Renew $expiringSoonCount expiring document${expiringSoonCount == 1 ? '' : 's'}.';
    }
    if (pendingCount > 0) {
      return 'Verify $pendingCount pending document${pendingCount == 1 ? '' : 's'}.';
    }
    return 'Compliance documents are current.';
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
