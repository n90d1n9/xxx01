enum EmployeeBenefitPlanType {
  medical('Medical'),
  dental('Dental'),
  vision('Vision'),
  retirement('Retirement'),
  wellness('Wellness');

  final String label;

  const EmployeeBenefitPlanType(this.label);
}

enum EmployeeBenefitCoverageTier {
  employeeOnly('Employee only'),
  employeeSpouse('Employee + spouse'),
  employeeChildren('Employee + children'),
  family('Family');

  final String label;

  const EmployeeBenefitCoverageTier(this.label);
}

enum EmployeeBenefitEnrollmentStatus {
  active('Active'),
  pending('Pending'),
  waived('Waived'),
  actionRequired('Action required');

  final String label;

  const EmployeeBenefitEnrollmentStatus(this.label);
}

enum EmployeeDependentRelationship {
  spouse('Spouse'),
  child('Child'),
  parent('Parent'),
  partner('Partner');

  final String label;

  const EmployeeDependentRelationship(this.label);
}

enum EmployeeDependentVerificationStatus {
  verified('Verified'),
  pending('Pending'),
  expiring('Expiring'),
  missing('Missing');

  final String label;

  const EmployeeDependentVerificationStatus(this.label);
}

class EmployeeBenefitEnrollment {
  final String id;
  final String employeeId;
  final EmployeeBenefitPlanType type;
  final String planName;
  final String provider;
  final EmployeeBenefitCoverageTier coverageTier;
  final double monthlyEmployerContribution;
  final double monthlyEmployeeContribution;
  final DateTime effectiveDate;
  final DateTime renewalDate;
  final EmployeeBenefitEnrollmentStatus status;

  const EmployeeBenefitEnrollment({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.planName,
    required this.provider,
    required this.coverageTier,
    required this.monthlyEmployerContribution,
    required this.monthlyEmployeeContribution,
    required this.effectiveDate,
    required this.renewalDate,
    required this.status,
  });

  double get monthlyTotalContribution {
    return monthlyEmployerContribution + monthlyEmployeeContribution;
  }

  bool get isActive => status == EmployeeBenefitEnrollmentStatus.active;

  bool needsAttention(DateTime asOfDate) {
    if (status == EmployeeBenefitEnrollmentStatus.actionRequired ||
        status == EmployeeBenefitEnrollmentStatus.pending) {
      return true;
    }
    if (status == EmployeeBenefitEnrollmentStatus.waived) {
      return false;
    }
    return !renewalDate.isAfter(
      _dateOnly(asOfDate).add(const Duration(days: 30)),
    );
  }

  EmployeeBenefitEnrollment copyWith({
    EmployeeBenefitCoverageTier? coverageTier,
    double? monthlyEmployeeContribution,
    DateTime? effectiveDate,
    DateTime? renewalDate,
    EmployeeBenefitEnrollmentStatus? status,
  }) {
    return EmployeeBenefitEnrollment(
      id: id,
      employeeId: employeeId,
      type: type,
      planName: planName,
      provider: provider,
      coverageTier: coverageTier ?? this.coverageTier,
      monthlyEmployerContribution: monthlyEmployerContribution,
      monthlyEmployeeContribution:
          monthlyEmployeeContribution ?? this.monthlyEmployeeContribution,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      renewalDate: renewalDate ?? this.renewalDate,
      status: status ?? this.status,
    );
  }
}

class EmployeeDependentRecord {
  final String id;
  final String employeeId;
  final String fullName;
  final EmployeeDependentRelationship relationship;
  final DateTime birthDate;
  final EmployeeDependentVerificationStatus verificationStatus;
  final bool eligibleForCoverage;

  const EmployeeDependentRecord({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.relationship,
    required this.birthDate,
    required this.verificationStatus,
    required this.eligibleForCoverage,
  });

  int age(DateTime asOfDate) {
    final birthdayPassed =
        asOfDate.month > birthDate.month ||
        (asOfDate.month == birthDate.month && asOfDate.day >= birthDate.day);
    return asOfDate.year - birthDate.year - (birthdayPassed ? 0 : 1);
  }

  bool get isVerified {
    return verificationStatus == EmployeeDependentVerificationStatus.verified;
  }

  bool get needsAttention {
    return verificationStatus == EmployeeDependentVerificationStatus.pending ||
        verificationStatus == EmployeeDependentVerificationStatus.expiring ||
        verificationStatus == EmployeeDependentVerificationStatus.missing;
  }

  EmployeeDependentRecord copyWith({
    EmployeeDependentVerificationStatus? verificationStatus,
    bool? eligibleForCoverage,
  }) {
    return EmployeeDependentRecord(
      id: id,
      employeeId: employeeId,
      fullName: fullName,
      relationship: relationship,
      birthDate: birthDate,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      eligibleForCoverage: eligibleForCoverage ?? this.eligibleForCoverage,
    );
  }
}

class EmployeeBenefitsProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeBenefitEnrollment> enrollments;
  final List<EmployeeDependentRecord> dependents;

  const EmployeeBenefitsProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.enrollments,
    required this.dependents,
  });

  EmployeeBenefitsProfile copyWith({
    List<EmployeeBenefitEnrollment>? enrollments,
    List<EmployeeDependentRecord>? dependents,
  }) {
    return EmployeeBenefitsProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      enrollments: enrollments ?? this.enrollments,
      dependents: dependents ?? this.dependents,
    );
  }

  int get activeEnrollmentCount {
    return enrollments.where((enrollment) => enrollment.isActive).length;
  }

  int get actionRequiredCount {
    return enrollments
        .where((enrollment) => enrollment.needsAttention(asOfDate))
        .length;
  }

  int get pendingDependentCount {
    return dependents.where((dependent) => dependent.needsAttention).length;
  }

  int get coveredDependentCount {
    return dependents
        .where((dependent) => dependent.eligibleForCoverage)
        .length;
  }

  double get monthlyEmployerContribution {
    return enrollments
        .where((enrollment) => enrollment.isActive)
        .fold<double>(
          0,
          (total, enrollment) => total + enrollment.monthlyEmployerContribution,
        );
  }

  double get monthlyEmployeeContribution {
    return enrollments
        .where((enrollment) => enrollment.isActive)
        .fold<double>(
          0,
          (total, enrollment) => total + enrollment.monthlyEmployeeContribution,
        );
  }

  String get nextAction {
    if (actionRequiredCount > 0) {
      return 'Resolve $actionRequiredCount benefit action${actionRequiredCount == 1 ? '' : 's'}.';
    }
    if (pendingDependentCount > 0) {
      return 'Verify $pendingDependentCount dependent record${pendingDependentCount == 1 ? '' : 's'}.';
    }
    if (!enrollments.any(
      (enrollment) =>
          enrollment.type == EmployeeBenefitPlanType.medical &&
          enrollment.isActive,
    )) {
      return 'Confirm medical coverage election.';
    }
    return 'Benefits profile is current.';
  }
}

class EmployeeDependentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String fullName;
  final EmployeeDependentRelationship relationship;
  final DateTime? birthDate;
  final bool eligibleForCoverage;

  const EmployeeDependentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.fullName,
    required this.relationship,
    required this.birthDate,
    required this.eligibleForCoverage,
  });

  EmployeeDependentDraft copyWith({
    String? fullName,
    EmployeeDependentRelationship? relationship,
    DateTime? birthDate,
    bool? eligibleForCoverage,
  }) {
    return EmployeeDependentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      birthDate: birthDate ?? this.birthDate,
      eligibleForCoverage: eligibleForCoverage ?? this.eligibleForCoverage,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (fullName.trim().length < 3) {
      errors.add('Dependent name must be at least 3 characters');
    }
    if (birthDate == null) {
      errors.add('Birth date is required');
    } else if (birthDate!.isAfter(asOfDate)) {
      errors.add('Birth date cannot be in the future');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (fullName.trim().length >= 3) complete++;
    if (birthDate != null && !birthDate!.isAfter(asOfDate)) complete++;
    if (relationship.label.isNotEmpty) complete++;
    return complete / 3;
  }

  EmployeeDependentRecord toDependent({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeDependentRecord(
      id: id,
      employeeId: employeeId,
      fullName: fullName.trim(),
      relationship: relationship,
      birthDate: birthDate!,
      verificationStatus: EmployeeDependentVerificationStatus.pending,
      eligibleForCoverage: eligibleForCoverage,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
