enum CompanyPositionControlType {
  permanent,
  contract,
  internship,
  outsourced,
  executive,
}

enum CompanyPositionControlStatus {
  approved,
  recruiting,
  pendingApproval,
  frozen,
  closed,
}

enum CompanyPositionControlIssue {
  missingTitle,
  missingEntity,
  missingOrgUnit,
  missingOwner,
  missingCompensationBand,
  missingHiringPlan,
  noAuthorizedSeat,
  overfilled,
  reviewOverdue,
  reviewDueSoon,
  pendingApproval,
  recruitingOpen,
  frozen,
  closed,
}

extension CompanyPositionControlTypeLabels on CompanyPositionControlType {
  String get label {
    switch (this) {
      case CompanyPositionControlType.permanent:
        return 'Permanent';
      case CompanyPositionControlType.contract:
        return 'Contract';
      case CompanyPositionControlType.internship:
        return 'Internship';
      case CompanyPositionControlType.outsourced:
        return 'Outsourced';
      case CompanyPositionControlType.executive:
        return 'Executive';
    }
  }
}

extension CompanyPositionControlStatusLabels on CompanyPositionControlStatus {
  String get label {
    switch (this) {
      case CompanyPositionControlStatus.approved:
        return 'Approved';
      case CompanyPositionControlStatus.recruiting:
        return 'Recruiting';
      case CompanyPositionControlStatus.pendingApproval:
        return 'Pending approval';
      case CompanyPositionControlStatus.frozen:
        return 'Frozen';
      case CompanyPositionControlStatus.closed:
        return 'Closed';
    }
  }
}

extension CompanyPositionControlIssueLabels on CompanyPositionControlIssue {
  String get label {
    switch (this) {
      case CompanyPositionControlIssue.missingTitle:
        return 'Add title';
      case CompanyPositionControlIssue.missingEntity:
        return 'Assign entity';
      case CompanyPositionControlIssue.missingOrgUnit:
        return 'Assign org unit';
      case CompanyPositionControlIssue.missingOwner:
        return 'Assign owner';
      case CompanyPositionControlIssue.missingCompensationBand:
        return 'Add band';
      case CompanyPositionControlIssue.missingHiringPlan:
        return 'Add hiring plan';
      case CompanyPositionControlIssue.noAuthorizedSeat:
        return 'Authorize seat';
      case CompanyPositionControlIssue.overfilled:
        return 'Seat overfilled';
      case CompanyPositionControlIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyPositionControlIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyPositionControlIssue.pendingApproval:
        return 'Approve position';
      case CompanyPositionControlIssue.recruitingOpen:
        return 'Close recruiting';
      case CompanyPositionControlIssue.frozen:
        return 'Unfreeze position';
      case CompanyPositionControlIssue.closed:
        return 'Closed';
    }
  }
}

class CompanyPositionControl {
  final String id;
  final String positionTitle;
  final String entityName;
  final String orgUnitName;
  final CompanyPositionControlType type;
  final CompanyPositionControlStatus status;
  final String ownerName;
  final int authorizedSeats;
  final int filledSeats;
  final double fte;
  final String compensationBand;
  final DateTime nextReviewDate;
  final String hiringPlan;
  final String linkedRequisition;

  const CompanyPositionControl({
    required this.id,
    required this.positionTitle,
    required this.entityName,
    required this.orgUnitName,
    required this.type,
    required this.status,
    required this.ownerName,
    required this.authorizedSeats,
    required this.filledSeats,
    required this.fte,
    required this.compensationBand,
    required this.nextReviewDate,
    required this.hiringPlan,
    required this.linkedRequisition,
  });

  int get availableSeats => authorizedSeats - filledSeats;

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyPositionControlIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (positionTitle.trim().isEmpty)
        CompanyPositionControlIssue.missingTitle,
      if (entityName.trim().isEmpty) CompanyPositionControlIssue.missingEntity,
      if (orgUnitName.trim().isEmpty)
        CompanyPositionControlIssue.missingOrgUnit,
      if (ownerName.trim().isEmpty) CompanyPositionControlIssue.missingOwner,
      if (compensationBand.trim().isEmpty)
        CompanyPositionControlIssue.missingCompensationBand,
      if (status == CompanyPositionControlStatus.recruiting &&
          hiringPlan.trim().isEmpty)
        CompanyPositionControlIssue.missingHiringPlan,
      if (authorizedSeats <= 0) CompanyPositionControlIssue.noAuthorizedSeat,
      if (filledSeats > authorizedSeats) CompanyPositionControlIssue.overfilled,
      if (days < 0) CompanyPositionControlIssue.reviewOverdue,
      if (days >= 0 && days <= 30) CompanyPositionControlIssue.reviewDueSoon,
      if (status == CompanyPositionControlStatus.pendingApproval)
        CompanyPositionControlIssue.pendingApproval,
      if (status == CompanyPositionControlStatus.recruiting)
        CompanyPositionControlIssue.recruitingOpen,
      if (status == CompanyPositionControlStatus.frozen)
        CompanyPositionControlIssue.frozen,
      if (status == CompanyPositionControlStatus.closed)
        CompanyPositionControlIssue.closed,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyPositionControl copyWith({
    String? id,
    String? positionTitle,
    String? entityName,
    String? orgUnitName,
    CompanyPositionControlType? type,
    CompanyPositionControlStatus? status,
    String? ownerName,
    int? authorizedSeats,
    int? filledSeats,
    double? fte,
    String? compensationBand,
    DateTime? nextReviewDate,
    String? hiringPlan,
    String? linkedRequisition,
  }) {
    return CompanyPositionControl(
      id: id ?? this.id,
      positionTitle: positionTitle ?? this.positionTitle,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      type: type ?? this.type,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      authorizedSeats: authorizedSeats ?? this.authorizedSeats,
      filledSeats: filledSeats ?? this.filledSeats,
      fte: fte ?? this.fte,
      compensationBand: compensationBand ?? this.compensationBand,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      hiringPlan: hiringPlan ?? this.hiringPlan,
      linkedRequisition: linkedRequisition ?? this.linkedRequisition,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyPositionControlDraft {
  final String positionTitle;
  final String entityName;
  final String orgUnitName;
  final CompanyPositionControlType type;
  final CompanyPositionControlStatus status;
  final String ownerName;
  final String authorizedSeatsText;
  final String filledSeatsText;
  final String fteText;
  final String compensationBand;
  final String nextReviewDateText;
  final String hiringPlan;
  final String linkedRequisition;

  const CompanyPositionControlDraft({
    required this.positionTitle,
    required this.entityName,
    required this.orgUnitName,
    required this.type,
    required this.status,
    required this.ownerName,
    required this.authorizedSeatsText,
    required this.filledSeatsText,
    required this.fteText,
    required this.compensationBand,
    required this.nextReviewDateText,
    required this.hiringPlan,
    required this.linkedRequisition,
  });

  factory CompanyPositionControlDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String orgUnitName = 'People Operations',
  }) {
    return CompanyPositionControlDraft(
      positionTitle: '',
      entityName: entityName,
      orgUnitName: orgUnitName,
      type: CompanyPositionControlType.permanent,
      status: CompanyPositionControlStatus.approved,
      ownerName: '',
      authorizedSeatsText: '',
      filledSeatsText: '0',
      fteText: '1',
      compensationBand: '',
      nextReviewDateText: '',
      hiringPlan: '',
      linkedRequisition: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validatePositiveInt(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number <= 0 ? 'Enter $label' : null;
  }

  static String? validateNonNegativeInt(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'Enter $label' : null;
  }

  static String? validatePositiveDecimal(String? value, String label) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || number <= 0 ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);
  int? get authorizedSeats => int.tryParse(authorizedSeatsText.trim());
  int? get filledSeats => int.tryParse(filledSeatsText.trim());
  double? get fte => double.tryParse(fteText.trim());

  bool get isReady {
    final authorized = authorizedSeats;
    final filled = filledSeats;
    final parsedFte = fte;
    return positionTitle.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        orgUnitName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        authorized != null &&
        authorized > 0 &&
        filled != null &&
        filled >= 0 &&
        parsedFte != null &&
        parsedFte > 0 &&
        compensationBand.trim().isNotEmpty &&
        nextReviewDate != null;
  }

  CompanyPositionControl toPositionControl(String id) {
    if (!isReady) {
      throw StateError('Complete position control fields before saving.');
    }
    return CompanyPositionControl(
      id: id,
      positionTitle: positionTitle.trim(),
      entityName: entityName.trim(),
      orgUnitName: orgUnitName.trim(),
      type: type,
      status: status,
      ownerName: ownerName.trim(),
      authorizedSeats: authorizedSeats!,
      filledSeats: filledSeats!,
      fte: fte!,
      compensationBand: compensationBand.trim(),
      nextReviewDate: nextReviewDate!,
      hiringPlan: hiringPlan.trim(),
      linkedRequisition: linkedRequisition.trim(),
    );
  }

  CompanyPositionControlDraft copyWith({
    String? positionTitle,
    String? entityName,
    String? orgUnitName,
    CompanyPositionControlType? type,
    CompanyPositionControlStatus? status,
    String? ownerName,
    String? authorizedSeatsText,
    String? filledSeatsText,
    String? fteText,
    String? compensationBand,
    String? nextReviewDateText,
    String? hiringPlan,
    String? linkedRequisition,
  }) {
    return CompanyPositionControlDraft(
      positionTitle: positionTitle ?? this.positionTitle,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      type: type ?? this.type,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      authorizedSeatsText: authorizedSeatsText ?? this.authorizedSeatsText,
      filledSeatsText: filledSeatsText ?? this.filledSeatsText,
      fteText: fteText ?? this.fteText,
      compensationBand: compensationBand ?? this.compensationBand,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      hiringPlan: hiringPlan ?? this.hiringPlan,
      linkedRequisition: linkedRequisition ?? this.linkedRequisition,
    );
  }

  static DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }
}
