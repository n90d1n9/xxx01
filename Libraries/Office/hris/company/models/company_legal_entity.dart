enum CompanyLegalEntityStatus { verified, pending, needsReview, inactive }

enum CompanyLegalEntityIssue {
  missingRegistrationNumber,
  missingTaxId,
  missingHrOwner,
  payrollDisabled,
  pending,
  needsReview,
  inactive,
}

extension CompanyLegalEntityStatusLabels on CompanyLegalEntityStatus {
  String get label {
    switch (this) {
      case CompanyLegalEntityStatus.verified:
        return 'Verified';
      case CompanyLegalEntityStatus.pending:
        return 'Pending';
      case CompanyLegalEntityStatus.needsReview:
        return 'Needs review';
      case CompanyLegalEntityStatus.inactive:
        return 'Inactive';
    }
  }
}

extension CompanyLegalEntityIssueLabels on CompanyLegalEntityIssue {
  String get label {
    switch (this) {
      case CompanyLegalEntityIssue.missingRegistrationNumber:
        return 'Add registration';
      case CompanyLegalEntityIssue.missingTaxId:
        return 'Add tax ID';
      case CompanyLegalEntityIssue.missingHrOwner:
        return 'Assign HR owner';
      case CompanyLegalEntityIssue.payrollDisabled:
        return 'Enable payroll';
      case CompanyLegalEntityIssue.pending:
        return 'Complete verification';
      case CompanyLegalEntityIssue.needsReview:
        return 'Review entity setup';
      case CompanyLegalEntityIssue.inactive:
        return 'Resolve inactive entity';
    }
  }
}

class CompanyLegalEntity {
  final String id;
  final String name;
  final String registrationNumber;
  final String taxId;
  final String country;
  final String city;
  final String hrOwner;
  final bool payrollEnabled;
  final CompanyLegalEntityStatus status;

  const CompanyLegalEntity({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.taxId,
    required this.country,
    required this.city,
    required this.hrOwner,
    required this.payrollEnabled,
    required this.status,
  });

  List<CompanyLegalEntityIssue> get issues {
    return [
      if (registrationNumber.trim().isEmpty)
        CompanyLegalEntityIssue.missingRegistrationNumber,
      if (taxId.trim().isEmpty) CompanyLegalEntityIssue.missingTaxId,
      if (hrOwner.trim().isEmpty) CompanyLegalEntityIssue.missingHrOwner,
      if (!payrollEnabled) CompanyLegalEntityIssue.payrollDisabled,
      if (status == CompanyLegalEntityStatus.pending)
        CompanyLegalEntityIssue.pending,
      if (status == CompanyLegalEntityStatus.needsReview)
        CompanyLegalEntityIssue.needsReview,
      if (status == CompanyLegalEntityStatus.inactive)
        CompanyLegalEntityIssue.inactive,
    ];
  }

  bool get requiresAttention => issues.isNotEmpty;

  double get readinessScore {
    const totalChecks = 7;
    return ((totalChecks - issues.length) / totalChecks).clamp(0, 1);
  }

  CompanyLegalEntity copyWith({
    String? id,
    String? name,
    String? registrationNumber,
    String? taxId,
    String? country,
    String? city,
    String? hrOwner,
    bool? payrollEnabled,
    CompanyLegalEntityStatus? status,
  }) {
    return CompanyLegalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      taxId: taxId ?? this.taxId,
      country: country ?? this.country,
      city: city ?? this.city,
      hrOwner: hrOwner ?? this.hrOwner,
      payrollEnabled: payrollEnabled ?? this.payrollEnabled,
      status: status ?? this.status,
    );
  }
}

class CompanyLegalEntityDraft {
  final String name;
  final String registrationNumber;
  final String taxId;
  final String country;
  final String city;
  final String hrOwner;
  final bool payrollEnabled;
  final CompanyLegalEntityStatus status;

  const CompanyLegalEntityDraft({
    required this.name,
    required this.registrationNumber,
    required this.taxId,
    required this.country,
    required this.city,
    required this.hrOwner,
    required this.payrollEnabled,
    required this.status,
  });

  factory CompanyLegalEntityDraft.empty() {
    return const CompanyLegalEntityDraft(
      name: '',
      registrationNumber: '',
      taxId: '',
      country: 'Indonesia',
      city: '',
      hrOwner: '',
      payrollEnabled: true,
      status: CompanyLegalEntityStatus.pending,
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  bool get isReady {
    return name.trim().isNotEmpty &&
        registrationNumber.trim().isNotEmpty &&
        taxId.trim().isNotEmpty &&
        country.trim().isNotEmpty &&
        city.trim().isNotEmpty &&
        hrOwner.trim().isNotEmpty;
  }

  CompanyLegalEntity toLegalEntity(String id) {
    if (!isReady) {
      throw StateError('Complete legal entity fields before saving.');
    }

    return CompanyLegalEntity(
      id: id,
      name: name.trim(),
      registrationNumber: registrationNumber.trim(),
      taxId: taxId.trim(),
      country: country.trim(),
      city: city.trim(),
      hrOwner: hrOwner.trim(),
      payrollEnabled: payrollEnabled,
      status: status,
    );
  }

  CompanyLegalEntityDraft copyWith({
    String? name,
    String? registrationNumber,
    String? taxId,
    String? country,
    String? city,
    String? hrOwner,
    bool? payrollEnabled,
    CompanyLegalEntityStatus? status,
  }) {
    return CompanyLegalEntityDraft(
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      taxId: taxId ?? this.taxId,
      country: country ?? this.country,
      city: city ?? this.city,
      hrOwner: hrOwner ?? this.hrOwner,
      payrollEnabled: payrollEnabled ?? this.payrollEnabled,
      status: status ?? this.status,
    );
  }
}
