enum EmployeeAccommodationType {
  ergonomic('Ergonomic'),
  medical('Medical'),
  schedule('Schedule'),
  assistiveTechnology('Assistive technology'),
  workplaceAccess('Workplace access'),
  leaveSupport('Leave support');

  final String label;

  const EmployeeAccommodationType(this.label);
}

enum EmployeeAccommodationStatus {
  requested('Requested'),
  approved('Approved'),
  active('Active'),
  reviewDue('Review due'),
  expired('Expired'),
  declined('Declined');

  final String label;

  const EmployeeAccommodationStatus(this.label);
}

enum EmployeeAccommodationSensitivity {
  standard('Standard'),
  confidential('Confidential'),
  restricted('Restricted');

  final String label;

  const EmployeeAccommodationSensitivity(this.label);
}

class EmployeeAccommodationRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeAccommodationType type;
  final String title;
  final String owner;
  final DateTime requestedAt;
  final DateTime startDate;
  final DateTime reviewDate;
  final DateTime? endDate;
  final EmployeeAccommodationStatus status;
  final EmployeeAccommodationSensitivity sensitivity;
  final String summary;

  const EmployeeAccommodationRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.title,
    required this.owner,
    required this.requestedAt,
    required this.startDate,
    required this.reviewDate,
    required this.endDate,
    required this.status,
    required this.sensitivity,
    required this.summary,
  });

  bool get canApprove => status == EmployeeAccommodationStatus.requested;

  bool get canActivate => status == EmployeeAccommodationStatus.approved;

  bool get canDecline => status == EmployeeAccommodationStatus.requested;

  bool get canReview {
    return status == EmployeeAccommodationStatus.active ||
        status == EmployeeAccommodationStatus.reviewDue;
  }

  bool get canExpire {
    return status == EmployeeAccommodationStatus.active ||
        status == EmployeeAccommodationStatus.reviewDue ||
        status == EmployeeAccommodationStatus.approved;
  }

  bool get isClosed {
    return status == EmployeeAccommodationStatus.expired ||
        status == EmployeeAccommodationStatus.declined;
  }

  bool isReviewDue(DateTime asOfDate) {
    if (!canReview) return false;
    if (status == EmployeeAccommodationStatus.reviewDue) return true;
    return !reviewDate.isAfter(
      _dateOnly(asOfDate).add(const Duration(days: 14)),
    );
  }

  bool isExpired(DateTime asOfDate) {
    final accommodationEndDate = endDate;
    if (status == EmployeeAccommodationStatus.expired) return true;
    if (accommodationEndDate == null) return false;
    return !isClosed && accommodationEndDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return status == EmployeeAccommodationStatus.requested ||
        status == EmployeeAccommodationStatus.approved ||
        isReviewDue(asOfDate) ||
        isExpired(asOfDate);
  }

  EmployeeAccommodationRecord copyWith({
    DateTime? reviewDate,
    DateTime? endDate,
    EmployeeAccommodationStatus? status,
  }) {
    return EmployeeAccommodationRecord(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title,
      owner: owner,
      requestedAt: requestedAt,
      startDate: startDate,
      reviewDate: reviewDate ?? this.reviewDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      sensitivity: sensitivity,
      summary: summary,
    );
  }
}

class EmployeeAccommodationProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeAccommodationRecord> records;

  const EmployeeAccommodationProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.records,
  });

  EmployeeAccommodationProfile copyWith({
    List<EmployeeAccommodationRecord>? records,
  }) {
    return EmployeeAccommodationProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      records: records ?? this.records,
    );
  }

  int get requestedCount {
    return records
        .where(
          (record) => record.status == EmployeeAccommodationStatus.requested,
        )
        .length;
  }

  int get approvedCount {
    return records
        .where(
          (record) => record.status == EmployeeAccommodationStatus.approved,
        )
        .length;
  }

  int get activeCount {
    return records
        .where((record) => record.status == EmployeeAccommodationStatus.active)
        .length;
  }

  int get reviewDueCount {
    return records.where((record) => record.isReviewDue(asOfDate)).length;
  }

  int get expiredCount {
    return records.where((record) => record.isExpired(asOfDate)).length;
  }

  int get restrictedCount {
    return records
        .where(
          (record) =>
              record.sensitivity == EmployeeAccommodationSensitivity.restricted,
        )
        .length;
  }

  int get attentionCount {
    return records.where((record) => record.needsAttention(asOfDate)).length;
  }

  String get nextAction {
    if (expiredCount > 0) {
      return 'Resolve $expiredCount expired accommodation${expiredCount == 1 ? '' : 's'}.';
    }
    if (reviewDueCount > 0) {
      return 'Review $reviewDueCount workplace support plan${reviewDueCount == 1 ? '' : 's'}.';
    }
    if (requestedCount > 0) {
      return 'Review $requestedCount accommodation request${requestedCount == 1 ? '' : 's'}.';
    }
    if (approvedCount > 0) {
      return 'Activate $approvedCount approved accommodation${approvedCount == 1 ? '' : 's'}.';
    }
    return 'Accommodation records are current.';
  }
}

class EmployeeAccommodationDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeAccommodationType type;
  final String title;
  final String owner;
  final DateTime startDate;
  final DateTime reviewDate;
  final EmployeeAccommodationSensitivity sensitivity;
  final String summary;

  const EmployeeAccommodationDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.owner,
    required this.startDate,
    required this.reviewDate,
    required this.sensitivity,
    required this.summary,
  });

  EmployeeAccommodationDraft copyWith({
    EmployeeAccommodationType? type,
    String? title,
    String? owner,
    DateTime? startDate,
    DateTime? reviewDate,
    EmployeeAccommodationSensitivity? sensitivity,
    String? summary,
  }) {
    return EmployeeAccommodationDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      startDate: startDate ?? this.startDate,
      reviewDate: reviewDate ?? this.reviewDate,
      sensitivity: sensitivity ?? this.sensitivity,
      summary: summary ?? this.summary,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Accommodation title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (startDate.isBefore(asOfDate)) {
      errors.add('Start date cannot be before today');
    }
    if (reviewDate.isBefore(startDate)) {
      errors.add('Review date cannot be before start date');
    }
    if (summary.trim().length < 12) {
      errors.add('Summary must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          title.trim().length >= 4,
          owner.trim().length >= 3,
          !startDate.isBefore(asOfDate),
          !reviewDate.isBefore(startDate),
          summary.trim().length >= 12,
        ].where((item) => item).length;
    return complete / 5;
  }

  EmployeeAccommodationRecord toRecord({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeAccommodationRecord(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      requestedAt: asOfDate,
      startDate: startDate,
      reviewDate: reviewDate,
      endDate: null,
      status: EmployeeAccommodationStatus.requested,
      sensitivity: sensitivity,
      summary: summary.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
