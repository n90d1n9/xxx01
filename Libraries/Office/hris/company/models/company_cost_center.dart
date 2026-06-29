enum CompanyCostCenterStatus { active, planning, needsReview, archived }

enum CompanyCostCenterIssue {
  missingCode,
  missingEntity,
  missingOrgUnit,
  missingOwner,
  invalidBudget,
  headcountVariance,
  needsReview,
  archived,
}

extension CompanyCostCenterStatusLabels on CompanyCostCenterStatus {
  String get label {
    switch (this) {
      case CompanyCostCenterStatus.active:
        return 'Active';
      case CompanyCostCenterStatus.planning:
        return 'Planning';
      case CompanyCostCenterStatus.needsReview:
        return 'Needs review';
      case CompanyCostCenterStatus.archived:
        return 'Archived';
    }
  }
}

extension CompanyCostCenterIssueLabels on CompanyCostCenterIssue {
  String get label {
    switch (this) {
      case CompanyCostCenterIssue.missingCode:
        return 'Assign code';
      case CompanyCostCenterIssue.missingEntity:
        return 'Assign entity';
      case CompanyCostCenterIssue.missingOrgUnit:
        return 'Assign org unit';
      case CompanyCostCenterIssue.missingOwner:
        return 'Assign owner';
      case CompanyCostCenterIssue.invalidBudget:
        return 'Set budget';
      case CompanyCostCenterIssue.headcountVariance:
        return 'Review headcount';
      case CompanyCostCenterIssue.needsReview:
        return 'Review center';
      case CompanyCostCenterIssue.archived:
        return 'Resolve archive';
    }
  }
}

class CompanyCostCenter {
  final String id;
  final String code;
  final String name;
  final String entityName;
  final String orgUnitName;
  final String ownerName;
  final int annualBudget;
  final int allocatedHeadcount;
  final int activeHeadcount;
  final CompanyCostCenterStatus status;

  const CompanyCostCenter({
    required this.id,
    required this.code,
    required this.name,
    required this.entityName,
    required this.orgUnitName,
    required this.ownerName,
    required this.annualBudget,
    required this.allocatedHeadcount,
    required this.activeHeadcount,
    required this.status,
  });

  int get headcountVariance => activeHeadcount - allocatedHeadcount;

  double get headcountUtilization {
    if (allocatedHeadcount <= 0) return 0;
    return (activeHeadcount / allocatedHeadcount).clamp(0, 1.5);
  }

  List<CompanyCostCenterIssue> get issues {
    return [
      if (code.trim().isEmpty) CompanyCostCenterIssue.missingCode,
      if (entityName.trim().isEmpty) CompanyCostCenterIssue.missingEntity,
      if (orgUnitName.trim().isEmpty) CompanyCostCenterIssue.missingOrgUnit,
      if (ownerName.trim().isEmpty) CompanyCostCenterIssue.missingOwner,
      if (annualBudget <= 0) CompanyCostCenterIssue.invalidBudget,
      if (headcountVariance.abs() > 2) CompanyCostCenterIssue.headcountVariance,
      if (status == CompanyCostCenterStatus.needsReview)
        CompanyCostCenterIssue.needsReview,
      if (status == CompanyCostCenterStatus.archived)
        CompanyCostCenterIssue.archived,
    ];
  }

  bool get requiresAttention => issues.isNotEmpty;

  CompanyCostCenter copyWith({
    String? id,
    String? code,
    String? name,
    String? entityName,
    String? orgUnitName,
    String? ownerName,
    int? annualBudget,
    int? allocatedHeadcount,
    int? activeHeadcount,
    CompanyCostCenterStatus? status,
  }) {
    return CompanyCostCenter(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      ownerName: ownerName ?? this.ownerName,
      annualBudget: annualBudget ?? this.annualBudget,
      allocatedHeadcount: allocatedHeadcount ?? this.allocatedHeadcount,
      activeHeadcount: activeHeadcount ?? this.activeHeadcount,
      status: status ?? this.status,
    );
  }
}

class CompanyCostCenterDraft {
  final String code;
  final String name;
  final String entityName;
  final String orgUnitName;
  final String ownerName;
  final String annualBudgetText;
  final String allocatedHeadcountText;
  final String activeHeadcountText;
  final CompanyCostCenterStatus status;

  const CompanyCostCenterDraft({
    required this.code,
    required this.name,
    required this.entityName,
    required this.orgUnitName,
    required this.ownerName,
    required this.annualBudgetText,
    required this.allocatedHeadcountText,
    required this.activeHeadcountText,
    required this.status,
  });

  factory CompanyCostCenterDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyCostCenterDraft(
      code: '',
      name: '',
      entityName: entityName,
      orgUnitName: '',
      ownerName: '',
      annualBudgetText: '',
      allocatedHeadcountText: '',
      activeHeadcountText: '',
      status: CompanyCostCenterStatus.planning,
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validatePositiveNumber(String? value, String label) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count <= 0) return 'Enter $label';
    return null;
  }

  static String? validateZeroOrGreater(String? value) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count < 0) return 'Enter zero or greater';
    return null;
  }

  int? get annualBudget => int.tryParse(annualBudgetText.trim());

  int? get allocatedHeadcount => int.tryParse(allocatedHeadcountText.trim());

  int? get activeHeadcount => int.tryParse(activeHeadcountText.trim());

  bool get isReady {
    return code.trim().isNotEmpty &&
        name.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        orgUnitName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        annualBudget != null &&
        annualBudget! > 0 &&
        allocatedHeadcount != null &&
        allocatedHeadcount! >= 0 &&
        activeHeadcount != null &&
        activeHeadcount! >= 0;
  }

  CompanyCostCenter toCostCenter(String id) {
    if (!isReady) {
      throw StateError('Complete cost center fields before saving.');
    }

    return CompanyCostCenter(
      id: id,
      code: code.trim().toUpperCase(),
      name: name.trim(),
      entityName: entityName.trim(),
      orgUnitName: orgUnitName.trim(),
      ownerName: ownerName.trim(),
      annualBudget: annualBudget!,
      allocatedHeadcount: allocatedHeadcount!,
      activeHeadcount: activeHeadcount!,
      status: status,
    );
  }

  CompanyCostCenterDraft copyWith({
    String? code,
    String? name,
    String? entityName,
    String? orgUnitName,
    String? ownerName,
    String? annualBudgetText,
    String? allocatedHeadcountText,
    String? activeHeadcountText,
    CompanyCostCenterStatus? status,
  }) {
    return CompanyCostCenterDraft(
      code: code ?? this.code,
      name: name ?? this.name,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      ownerName: ownerName ?? this.ownerName,
      annualBudgetText: annualBudgetText ?? this.annualBudgetText,
      allocatedHeadcountText:
          allocatedHeadcountText ?? this.allocatedHeadcountText,
      activeHeadcountText: activeHeadcountText ?? this.activeHeadcountText,
      status: status ?? this.status,
    );
  }
}
