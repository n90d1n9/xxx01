enum EmployeeWorkAuthorizationType {
  citizen('Citizen'),
  permanentResident('Permanent resident'),
  workVisa('Work visa'),
  dependentVisa('Dependent visa'),
  studentPermit('Student permit'),
  contractorPermit('Contractor permit');

  final String label;

  const EmployeeWorkAuthorizationType(this.label);
}

enum EmployeeWorkAuthorizationStatus {
  valid('Valid'),
  renewalDue('Renewal due'),
  pendingReview('Pending review'),
  missing('Missing'),
  expired('Expired'),
  suspended('Suspended');

  final String label;

  const EmployeeWorkAuthorizationStatus(this.label);
}

enum EmployeeWorkAuthorizationSponsorship {
  notRequired('Not required'),
  companySponsored('Company sponsored'),
  employeeManaged('Employee managed'),
  vendorManaged('Vendor managed');

  final String label;

  const EmployeeWorkAuthorizationSponsorship(this.label);
}

enum EmployeeWorkAuthorizationEvidenceStatus {
  verified('Verified'),
  pendingUpload('Pending upload'),
  rejected('Rejected'),
  expiring('Expiring'),
  missing('Missing');

  final String label;

  const EmployeeWorkAuthorizationEvidenceStatus(this.label);
}

class EmployeeWorkAuthorizationRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeWorkAuthorizationType type;
  final EmployeeWorkAuthorizationStatus status;
  final EmployeeWorkAuthorizationSponsorship sponsorship;
  final EmployeeWorkAuthorizationEvidenceStatus evidenceStatus;
  final String title;
  final String country;
  final String owner;
  final String documentNumberMasked;
  final DateTime issuedAt;
  final DateTime expiryDate;
  final DateTime reviewDate;
  final String notes;

  const EmployeeWorkAuthorizationRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.sponsorship,
    required this.evidenceStatus,
    required this.title,
    required this.country,
    required this.owner,
    required this.documentNumberMasked,
    required this.issuedAt,
    required this.expiryDate,
    required this.reviewDate,
    required this.notes,
  });

  bool get canVerifyEvidence {
    return evidenceStatus != EmployeeWorkAuthorizationEvidenceStatus.verified;
  }

  bool get canStartRenewal {
    return status == EmployeeWorkAuthorizationStatus.valid ||
        status == EmployeeWorkAuthorizationStatus.renewalDue ||
        status == EmployeeWorkAuthorizationStatus.expired;
  }

  bool get canMarkValid {
    return status == EmployeeWorkAuthorizationStatus.pendingReview ||
        status == EmployeeWorkAuthorizationStatus.renewalDue ||
        status == EmployeeWorkAuthorizationStatus.missing ||
        status == EmployeeWorkAuthorizationStatus.expired ||
        status == EmployeeWorkAuthorizationStatus.suspended;
  }

  bool isExpired(DateTime asOfDate) {
    return status == EmployeeWorkAuthorizationStatus.expired ||
        expiryDate.isBefore(_dateOnly(asOfDate));
  }

  bool isExpiringSoon(DateTime asOfDate) {
    if (isExpired(asOfDate)) return false;
    return !expiryDate.isAfter(
          _dateOnly(asOfDate).add(const Duration(days: 60)),
        ) ||
        status == EmployeeWorkAuthorizationStatus.renewalDue ||
        evidenceStatus == EmployeeWorkAuthorizationEvidenceStatus.expiring;
  }

  bool isReviewDue(DateTime asOfDate) {
    return status == EmployeeWorkAuthorizationStatus.pendingReview ||
        !reviewDate.isAfter(_dateOnly(asOfDate).add(const Duration(days: 14)));
  }

  bool get hasEvidenceGap {
    return evidenceStatus ==
            EmployeeWorkAuthorizationEvidenceStatus.pendingUpload ||
        evidenceStatus == EmployeeWorkAuthorizationEvidenceStatus.rejected ||
        evidenceStatus == EmployeeWorkAuthorizationEvidenceStatus.expiring ||
        evidenceStatus == EmployeeWorkAuthorizationEvidenceStatus.missing;
  }

  bool get needsEvidence => hasEvidenceGap;

  bool needsAttention(DateTime asOfDate) {
    return status != EmployeeWorkAuthorizationStatus.valid ||
        hasEvidenceGap ||
        isExpired(asOfDate) ||
        isExpiringSoon(asOfDate) ||
        isReviewDue(asOfDate);
  }

  EmployeeWorkAuthorizationRecord copyWith({
    EmployeeWorkAuthorizationStatus? status,
    EmployeeWorkAuthorizationEvidenceStatus? evidenceStatus,
    DateTime? expiryDate,
    DateTime? reviewDate,
    String? notes,
  }) {
    return EmployeeWorkAuthorizationRecord(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      status: status ?? this.status,
      sponsorship: sponsorship,
      evidenceStatus: evidenceStatus ?? this.evidenceStatus,
      title: title,
      country: country,
      owner: owner,
      documentNumberMasked: documentNumberMasked,
      issuedAt: issuedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      reviewDate: reviewDate ?? this.reviewDate,
      notes: notes ?? this.notes,
    );
  }
}

class EmployeeWorkAuthorizationProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkAuthorizationRecord> records;

  const EmployeeWorkAuthorizationProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.records,
  });

  EmployeeWorkAuthorizationProfile copyWith({
    List<EmployeeWorkAuthorizationRecord>? records,
  }) {
    return EmployeeWorkAuthorizationProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      records: records ?? this.records,
    );
  }

  int get validCount {
    return records
        .where(
          (record) => record.status == EmployeeWorkAuthorizationStatus.valid,
        )
        .length;
  }

  int get renewalDueCount {
    return records.where((record) => record.isExpiringSoon(asOfDate)).length;
  }

  int get reviewDueCount {
    return records.where((record) => record.isReviewDue(asOfDate)).length;
  }

  int get evidenceGapCount {
    return records.where((record) => record.hasEvidenceGap).length;
  }

  int get evidenceIssueCount => evidenceGapCount;

  int get expiredCount {
    return records.where((record) => record.isExpired(asOfDate)).length;
  }

  int get sponsorshipCount {
    return records
        .where(
          (record) =>
              record.sponsorship ==
                  EmployeeWorkAuthorizationSponsorship.companySponsored ||
              record.sponsorship ==
                  EmployeeWorkAuthorizationSponsorship.vendorManaged,
        )
        .length;
  }

  int get attentionCount {
    return records.where((record) => record.needsAttention(asOfDate)).length;
  }

  String get nextAction {
    if (expiredCount > 0) {
      return 'Resolve $expiredCount expired work authorization${expiredCount == 1 ? '' : 's'}.';
    }
    if (evidenceGapCount > 0) {
      return 'Collect $evidenceGapCount right-to-work evidence item${evidenceGapCount == 1 ? '' : 's'}.';
    }
    if (renewalDueCount > 0) {
      return 'Start $renewalDueCount work authorization renewal${renewalDueCount == 1 ? '' : 's'}.';
    }
    if (reviewDueCount > 0) {
      return 'Review $reviewDueCount work authorization record${reviewDueCount == 1 ? '' : 's'}.';
    }
    return 'Work authorization records are current.';
  }
}

class EmployeeWorkAuthorizationDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeWorkAuthorizationType type;
  final EmployeeWorkAuthorizationSponsorship sponsorship;
  final String title;
  final String country;
  final String owner;
  final DateTime expiryDate;
  final DateTime reviewDate;
  final String notes;

  const EmployeeWorkAuthorizationDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.sponsorship,
    required this.title,
    required this.country,
    required this.owner,
    required this.expiryDate,
    required this.reviewDate,
    required this.notes,
  });

  EmployeeWorkAuthorizationDraft copyWith({
    EmployeeWorkAuthorizationType? type,
    EmployeeWorkAuthorizationSponsorship? sponsorship,
    String? title,
    String? country,
    String? owner,
    DateTime? expiryDate,
    DateTime? reviewDate,
    String? notes,
  }) {
    return EmployeeWorkAuthorizationDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      sponsorship: sponsorship ?? this.sponsorship,
      title: title ?? this.title,
      country: country ?? this.country,
      owner: owner ?? this.owner,
      expiryDate: expiryDate ?? this.expiryDate,
      reviewDate: reviewDate ?? this.reviewDate,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Authorization title must be at least 4 characters');
    }
    if (country.trim().length < 2) {
      errors.add('Country is required');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (!expiryDate.isAfter(asOfDate)) {
      errors.add('Expiry date must be after today');
    }
    if (reviewDate.isAfter(expiryDate)) {
      errors.add('Review date cannot be after expiry date');
    }
    if (reviewDate.isBefore(asOfDate)) {
      errors.add('Review date cannot be before today');
    }
    if (notes.trim().length < 12) {
      errors.add('Notes must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          title.trim().length >= 4,
          country.trim().length >= 2,
          owner.trim().length >= 3,
          expiryDate.isAfter(asOfDate),
          !reviewDate.isAfter(expiryDate),
          !reviewDate.isBefore(asOfDate),
          notes.trim().length >= 12,
        ].where((item) => item).length;
    return complete / 7;
  }

  EmployeeWorkAuthorizationRecord toRecord({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeWorkAuthorizationRecord(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      status: EmployeeWorkAuthorizationStatus.pendingReview,
      sponsorship: sponsorship,
      evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.pendingUpload,
      title: title.trim(),
      country: country.trim(),
      owner: owner.trim(),
      documentNumberMasked: 'AUTH-$employeeId-NEW',
      issuedAt: asOfDate,
      expiryDate: expiryDate,
      reviewDate: reviewDate,
      notes: notes.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
