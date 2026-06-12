enum CompanyStatus { active, onboarding, needsReview, inactive }

enum CompanyProfileIssue {
  missingLegalName,
  missingRegistrationNumber,
  missingTaxId,
  missingWebsite,
  missingHeadquarters,
  missingPrimaryContact,
  invalidEmployeeCount,
}

extension CompanyStatusLabels on CompanyStatus {
  String get label {
    switch (this) {
      case CompanyStatus.active:
        return 'Active';
      case CompanyStatus.onboarding:
        return 'Onboarding';
      case CompanyStatus.needsReview:
        return 'Needs review';
      case CompanyStatus.inactive:
        return 'Inactive';
    }
  }
}

extension CompanyProfileIssueLabels on CompanyProfileIssue {
  String get label {
    switch (this) {
      case CompanyProfileIssue.missingLegalName:
        return 'Legal name is required';
      case CompanyProfileIssue.missingRegistrationNumber:
        return 'Registration number is required';
      case CompanyProfileIssue.missingTaxId:
        return 'Tax ID is required';
      case CompanyProfileIssue.missingWebsite:
        return 'Website is required';
      case CompanyProfileIssue.missingHeadquarters:
        return 'Headquarters is required';
      case CompanyProfileIssue.missingPrimaryContact:
        return 'Primary contact is required';
      case CompanyProfileIssue.invalidEmployeeCount:
        return 'Employee count must be greater than zero';
    }
  }
}

class CompanyProfile {
  final String id;
  final String legalName;
  final String displayName;
  final String registrationNumber;
  final String taxId;
  final String industry;
  final String website;
  final String headquarters;
  final String primaryContact;
  final CompanyStatus status;
  final DateTime foundedDate;
  final int employeeCount;

  const CompanyProfile({
    required this.id,
    required this.legalName,
    required this.displayName,
    required this.registrationNumber,
    required this.taxId,
    required this.industry,
    required this.website,
    required this.headquarters,
    required this.primaryContact,
    required this.status,
    required this.foundedDate,
    required this.employeeCount,
  });

  String get title => displayName.trim().isEmpty ? legalName : displayName;

  List<CompanyProfileIssue> get issues {
    return [
      if (legalName.trim().isEmpty) CompanyProfileIssue.missingLegalName,
      if (registrationNumber.trim().isEmpty)
        CompanyProfileIssue.missingRegistrationNumber,
      if (taxId.trim().isEmpty) CompanyProfileIssue.missingTaxId,
      if (website.trim().isEmpty) CompanyProfileIssue.missingWebsite,
      if (headquarters.trim().isEmpty) CompanyProfileIssue.missingHeadquarters,
      if (primaryContact.trim().isEmpty)
        CompanyProfileIssue.missingPrimaryContact,
      if (employeeCount <= 0) CompanyProfileIssue.invalidEmployeeCount,
    ];
  }

  bool get isReady => issues.isEmpty && status != CompanyStatus.inactive;

  double get readinessScore {
    const totalChecks = 7;
    final score = (totalChecks - issues.length) / totalChecks;
    if (status == CompanyStatus.inactive) return 0;
    if (status == CompanyStatus.needsReview) return (score * 0.82).clamp(0, 1);
    if (status == CompanyStatus.onboarding) return (score * 0.9).clamp(0, 1);
    return score.clamp(0, 1);
  }

  CompanyProfile copyWith({
    String? id,
    String? legalName,
    String? displayName,
    String? registrationNumber,
    String? taxId,
    String? industry,
    String? website,
    String? headquarters,
    String? primaryContact,
    CompanyStatus? status,
    DateTime? foundedDate,
    int? employeeCount,
  }) {
    return CompanyProfile(
      id: id ?? this.id,
      legalName: legalName ?? this.legalName,
      displayName: displayName ?? this.displayName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      taxId: taxId ?? this.taxId,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      headquarters: headquarters ?? this.headquarters,
      primaryContact: primaryContact ?? this.primaryContact,
      status: status ?? this.status,
      foundedDate: foundedDate ?? this.foundedDate,
      employeeCount: employeeCount ?? this.employeeCount,
    );
  }
}

class CompanyProfileDraft {
  final String legalName;
  final String displayName;
  final String registrationNumber;
  final String taxId;
  final String industry;
  final String website;
  final String headquarters;
  final String primaryContact;
  final CompanyStatus status;
  final DateTime foundedDate;
  final String employeeCountText;

  const CompanyProfileDraft({
    required this.legalName,
    required this.displayName,
    required this.registrationNumber,
    required this.taxId,
    required this.industry,
    required this.website,
    required this.headquarters,
    required this.primaryContact,
    required this.status,
    required this.foundedDate,
    required this.employeeCountText,
  });

  factory CompanyProfileDraft.fromProfile(CompanyProfile profile) {
    return CompanyProfileDraft(
      legalName: profile.legalName,
      displayName: profile.displayName,
      registrationNumber: profile.registrationNumber,
      taxId: profile.taxId,
      industry: profile.industry,
      website: profile.website,
      headquarters: profile.headquarters,
      primaryContact: profile.primaryContact,
      status: profile.status,
      foundedDate: profile.foundedDate,
      employeeCountText: '${profile.employeeCount}',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateEmployeeCount(String? value) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count <= 0) {
      return 'Enter a positive employee count';
    }
    return null;
  }

  int? get employeeCount => int.tryParse(employeeCountText.trim());

  List<CompanyProfileIssue> get issues {
    return CompanyProfile(
      id: 'draft',
      legalName: legalName,
      displayName: displayName,
      registrationNumber: registrationNumber,
      taxId: taxId,
      industry: industry,
      website: website,
      headquarters: headquarters,
      primaryContact: primaryContact,
      status: status,
      foundedDate: foundedDate,
      employeeCount: employeeCount ?? 0,
    ).issues;
  }

  bool get isReady => issues.isEmpty;

  double get completionRatio {
    const totalChecks = 7;
    return ((totalChecks - issues.length) / totalChecks).clamp(0, 1);
  }

  CompanyProfile toProfile(String id) {
    if (!isReady) {
      throw StateError('Complete company profile fields before saving.');
    }
    return CompanyProfile(
      id: id,
      legalName: legalName.trim(),
      displayName: displayName.trim(),
      registrationNumber: registrationNumber.trim(),
      taxId: taxId.trim(),
      industry: industry.trim(),
      website: website.trim(),
      headquarters: headquarters.trim(),
      primaryContact: primaryContact.trim(),
      status: status,
      foundedDate: foundedDate,
      employeeCount: employeeCount!,
    );
  }

  CompanyProfileDraft copyWith({
    String? legalName,
    String? displayName,
    String? registrationNumber,
    String? taxId,
    String? industry,
    String? website,
    String? headquarters,
    String? primaryContact,
    CompanyStatus? status,
    DateTime? foundedDate,
    String? employeeCountText,
  }) {
    return CompanyProfileDraft(
      legalName: legalName ?? this.legalName,
      displayName: displayName ?? this.displayName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      taxId: taxId ?? this.taxId,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      headquarters: headquarters ?? this.headquarters,
      primaryContact: primaryContact ?? this.primaryContact,
      status: status ?? this.status,
      foundedDate: foundedDate ?? this.foundedDate,
      employeeCountText: employeeCountText ?? this.employeeCountText,
    );
  }
}
