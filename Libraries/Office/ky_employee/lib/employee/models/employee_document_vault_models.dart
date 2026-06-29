enum EmployeeDocumentVaultCategory {
  identity('Identity'),
  contract('Contract'),
  payrollTax('Payroll and tax'),
  compliance('Compliance'),
  workAuthorization('Work authorization'),
  benefits('Benefits'),
  training('Training'),
  custom('Custom');

  final String label;

  const EmployeeDocumentVaultCategory(this.label);
}

enum EmployeeDocumentVaultStatus {
  verified('Verified'),
  pendingReview('Pending review'),
  needsUpload('Needs upload'),
  expiringSoon('Expiring soon'),
  expired('Expired'),
  rejected('Rejected'),
  archived('Archived');

  final String label;

  const EmployeeDocumentVaultStatus(this.label);
}

enum EmployeeDocumentVaultAccess {
  employeeVisible('Employee visible'),
  hrOnly('HR only'),
  restricted('Restricted');

  final String label;

  const EmployeeDocumentVaultAccess(this.label);
}

class EmployeeDocumentVaultRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeDocumentVaultCategory category;
  final EmployeeDocumentVaultStatus status;
  final EmployeeDocumentVaultAccess access;
  final String title;
  final String owner;
  final String source;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final DateTime? verifiedAt;
  final String summary;

  const EmployeeDocumentVaultRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.category,
    required this.status,
    required this.access,
    required this.title,
    required this.owner,
    required this.source,
    required this.uploadedAt,
    required this.expiresAt,
    required this.verifiedAt,
    required this.summary,
  });

  bool get canVerify {
    return status == EmployeeDocumentVaultStatus.pendingReview ||
        status == EmployeeDocumentVaultStatus.needsUpload ||
        status == EmployeeDocumentVaultStatus.expiringSoon ||
        status == EmployeeDocumentVaultStatus.expired ||
        status == EmployeeDocumentVaultStatus.rejected;
  }

  bool get canReject => status == EmployeeDocumentVaultStatus.pendingReview;

  bool get canRequestUpload {
    return status != EmployeeDocumentVaultStatus.archived &&
        status != EmployeeDocumentVaultStatus.needsUpload;
  }

  bool get canArchive => status != EmployeeDocumentVaultStatus.archived;

  bool isExpired(DateTime asOfDate) {
    if (status == EmployeeDocumentVaultStatus.archived) return false;
    if (status == EmployeeDocumentVaultStatus.expired) return true;
    final expiry = expiresAt;
    if (expiry == null) return false;
    return expiry.isBefore(_dateOnly(asOfDate));
  }

  bool isExpiringSoon(DateTime asOfDate) {
    if (isExpired(asOfDate)) return false;
    if (status == EmployeeDocumentVaultStatus.expiringSoon) return true;
    final expiry = expiresAt;
    if (expiry == null) return false;
    return !expiry.isAfter(_dateOnly(asOfDate).add(const Duration(days: 45)));
  }

  bool needsAttention(DateTime asOfDate) {
    if (status == EmployeeDocumentVaultStatus.archived) return false;
    return status == EmployeeDocumentVaultStatus.pendingReview ||
        status == EmployeeDocumentVaultStatus.needsUpload ||
        status == EmployeeDocumentVaultStatus.rejected ||
        isExpired(asOfDate) ||
        isExpiringSoon(asOfDate);
  }

  EmployeeDocumentVaultRecord copyWith({
    EmployeeDocumentVaultStatus? status,
    EmployeeDocumentVaultAccess? access,
    String? title,
    String? owner,
    String? source,
    DateTime? uploadedAt,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    DateTime? verifiedAt,
    bool clearVerifiedAt = false,
    String? summary,
  }) {
    return EmployeeDocumentVaultRecord(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      category: category,
      status: status ?? this.status,
      access: access ?? this.access,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      source: source ?? this.source,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      verifiedAt: clearVerifiedAt ? null : verifiedAt ?? this.verifiedAt,
      summary: summary ?? this.summary,
    );
  }
}

class EmployeeDocumentVaultProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDocumentVaultRecord> records;

  const EmployeeDocumentVaultProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.records,
  });

  EmployeeDocumentVaultProfile copyWith({
    List<EmployeeDocumentVaultRecord>? records,
  }) {
    return EmployeeDocumentVaultProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      records: records ?? this.records,
    );
  }

  int get verifiedCount {
    return records
        .where(
          (record) =>
              record.status == EmployeeDocumentVaultStatus.verified &&
              !record.needsAttention(asOfDate),
        )
        .length;
  }

  int get pendingReviewCount {
    return records
        .where(
          (record) =>
              record.status == EmployeeDocumentVaultStatus.pendingReview,
        )
        .length;
  }

  int get uploadNeededCount {
    return records
        .where(
          (record) => record.status == EmployeeDocumentVaultStatus.needsUpload,
        )
        .length;
  }

  int get expiringSoonCount {
    return records.where((record) => record.isExpiringSoon(asOfDate)).length;
  }

  int get expiredCount {
    return records.where((record) => record.isExpired(asOfDate)).length;
  }

  int get restrictedCount {
    return records
        .where(
          (record) => record.access == EmployeeDocumentVaultAccess.restricted,
        )
        .length;
  }

  int get attentionCount {
    return records.where((record) => record.needsAttention(asOfDate)).length;
  }

  String get nextAction {
    if (expiredCount > 0) {
      return 'Replace $expiredCount expired document${expiredCount == 1 ? '' : 's'}.';
    }
    if (uploadNeededCount > 0) {
      return 'Collect $uploadNeededCount missing document${uploadNeededCount == 1 ? '' : 's'}.';
    }
    if (pendingReviewCount > 0) {
      return 'Review $pendingReviewCount uploaded document${pendingReviewCount == 1 ? '' : 's'}.';
    }
    if (expiringSoonCount > 0) {
      return 'Renew $expiringSoonCount document${expiringSoonCount == 1 ? '' : 's'} before expiry.';
    }
    return 'Employee document vault is current.';
  }
}

class EmployeeDocumentVaultDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeDocumentVaultCategory category;
  final EmployeeDocumentVaultAccess access;
  final String title;
  final String owner;
  final DateTime? expiresAt;
  final String summary;

  const EmployeeDocumentVaultDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.category,
    required this.access,
    required this.title,
    required this.owner,
    required this.expiresAt,
    required this.summary,
  });

  EmployeeDocumentVaultDraft copyWith({
    EmployeeDocumentVaultCategory? category,
    EmployeeDocumentVaultAccess? access,
    String? title,
    String? owner,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    String? summary,
  }) {
    return EmployeeDocumentVaultDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      category: category ?? this.category,
      access: access ?? this.access,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      summary: summary ?? this.summary,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Document title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    final expiry = expiresAt;
    if (expiry != null && expiry.isBefore(asOfDate)) {
      errors.add('Expiry date cannot be before today');
    }
    if (summary.trim().length < 12) {
      errors.add('Summary must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    final expiry = expiresAt;
    final complete =
        [
          title.trim().length >= 4,
          owner.trim().length >= 3,
          expiry == null || !expiry.isBefore(asOfDate),
          summary.trim().length >= 12,
        ].where((item) => item).length;
    return complete / 4;
  }

  EmployeeDocumentVaultRecord toRecord({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeDocumentVaultRecord(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      category: category,
      status: EmployeeDocumentVaultStatus.pendingReview,
      access: access,
      title: title.trim(),
      owner: owner.trim(),
      source: 'Manual upload',
      uploadedAt: asOfDate,
      expiresAt: expiresAt,
      verifiedAt: null,
      summary: summary.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
