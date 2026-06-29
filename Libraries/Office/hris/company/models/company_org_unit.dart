enum CompanyOrgUnitStatus { active, hiring, review, paused }

enum CompanyOrgUnitIssue {
  missingCode,
  missingManager,
  headcountGap,
  overCapacity,
  paused,
  review,
}

extension CompanyOrgUnitStatusLabels on CompanyOrgUnitStatus {
  String get label {
    switch (this) {
      case CompanyOrgUnitStatus.active:
        return 'Active';
      case CompanyOrgUnitStatus.hiring:
        return 'Hiring';
      case CompanyOrgUnitStatus.review:
        return 'Review';
      case CompanyOrgUnitStatus.paused:
        return 'Paused';
    }
  }
}

extension CompanyOrgUnitIssueLabels on CompanyOrgUnitIssue {
  String get label {
    switch (this) {
      case CompanyOrgUnitIssue.missingCode:
        return 'Assign org code';
      case CompanyOrgUnitIssue.missingManager:
        return 'Assign manager';
      case CompanyOrgUnitIssue.headcountGap:
        return 'Close headcount gap';
      case CompanyOrgUnitIssue.overCapacity:
        return 'Review over-capacity';
      case CompanyOrgUnitIssue.paused:
        return 'Resolve paused unit';
      case CompanyOrgUnitIssue.review:
        return 'Complete structure review';
    }
  }
}

class CompanyOrgUnit {
  final String id;
  final String name;
  final String code;
  final String entityName;
  final String parentName;
  final String managerName;
  final String location;
  final int plannedHeadcount;
  final int activeHeadcount;
  final CompanyOrgUnitStatus status;

  const CompanyOrgUnit({
    required this.id,
    required this.name,
    required this.code,
    required this.entityName,
    required this.parentName,
    required this.managerName,
    required this.location,
    required this.plannedHeadcount,
    required this.activeHeadcount,
    required this.status,
  });

  int get headcountGap {
    final gap = plannedHeadcount - activeHeadcount;
    return gap < 0 ? 0 : gap;
  }

  double get staffingRatio {
    if (plannedHeadcount <= 0) return 0;
    return (activeHeadcount / plannedHeadcount).clamp(0, 1.25);
  }

  bool get needsAttention => issues.isNotEmpty;

  List<CompanyOrgUnitIssue> get issues {
    return [
      if (code.trim().isEmpty) CompanyOrgUnitIssue.missingCode,
      if (managerName.trim().isEmpty) CompanyOrgUnitIssue.missingManager,
      if (headcountGap > 0) CompanyOrgUnitIssue.headcountGap,
      if (activeHeadcount > plannedHeadcount && plannedHeadcount > 0)
        CompanyOrgUnitIssue.overCapacity,
      if (status == CompanyOrgUnitStatus.paused) CompanyOrgUnitIssue.paused,
      if (status == CompanyOrgUnitStatus.review) CompanyOrgUnitIssue.review,
    ];
  }

  CompanyOrgUnit copyWith({
    String? id,
    String? name,
    String? code,
    String? entityName,
    String? parentName,
    String? managerName,
    String? location,
    int? plannedHeadcount,
    int? activeHeadcount,
    CompanyOrgUnitStatus? status,
  }) {
    return CompanyOrgUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      entityName: entityName ?? this.entityName,
      parentName: parentName ?? this.parentName,
      managerName: managerName ?? this.managerName,
      location: location ?? this.location,
      plannedHeadcount: plannedHeadcount ?? this.plannedHeadcount,
      activeHeadcount: activeHeadcount ?? this.activeHeadcount,
      status: status ?? this.status,
    );
  }
}

class CompanyOrgUnitDraft {
  final String name;
  final String code;
  final String entityName;
  final String parentName;
  final String managerName;
  final String location;
  final String plannedHeadcountText;
  final String activeHeadcountText;
  final CompanyOrgUnitStatus status;

  const CompanyOrgUnitDraft({
    required this.name,
    required this.code,
    required this.entityName,
    required this.parentName,
    required this.managerName,
    required this.location,
    required this.plannedHeadcountText,
    required this.activeHeadcountText,
    required this.status,
  });

  factory CompanyOrgUnitDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyOrgUnitDraft(
      name: '',
      code: '',
      entityName: entityName,
      parentName: 'Executive',
      managerName: '',
      location: '',
      plannedHeadcountText: '',
      activeHeadcountText: '',
      status: CompanyOrgUnitStatus.hiring,
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateHeadcount(String? value) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count < 0) return 'Enter zero or greater';
    return null;
  }

  int? get plannedHeadcount => int.tryParse(plannedHeadcountText.trim());

  int? get activeHeadcount => int.tryParse(activeHeadcountText.trim());

  bool get isReady {
    return name.trim().isNotEmpty &&
        code.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        managerName.trim().isNotEmpty &&
        location.trim().isNotEmpty &&
        plannedHeadcount != null &&
        plannedHeadcount! >= 0 &&
        activeHeadcount != null &&
        activeHeadcount! >= 0;
  }

  CompanyOrgUnit toOrgUnit(String id) {
    if (!isReady) {
      throw StateError('Complete organization unit fields before saving.');
    }
    return CompanyOrgUnit(
      id: id,
      name: name.trim(),
      code: code.trim().toUpperCase(),
      entityName: entityName.trim(),
      parentName: parentName.trim().isEmpty ? 'Executive' : parentName.trim(),
      managerName: managerName.trim(),
      location: location.trim(),
      plannedHeadcount: plannedHeadcount!,
      activeHeadcount: activeHeadcount!,
      status: status,
    );
  }

  CompanyOrgUnitDraft copyWith({
    String? name,
    String? code,
    String? entityName,
    String? parentName,
    String? managerName,
    String? location,
    String? plannedHeadcountText,
    String? activeHeadcountText,
    CompanyOrgUnitStatus? status,
  }) {
    return CompanyOrgUnitDraft(
      name: name ?? this.name,
      code: code ?? this.code,
      entityName: entityName ?? this.entityName,
      parentName: parentName ?? this.parentName,
      managerName: managerName ?? this.managerName,
      location: location ?? this.location,
      plannedHeadcountText: plannedHeadcountText ?? this.plannedHeadcountText,
      activeHeadcountText: activeHeadcountText ?? this.activeHeadcountText,
      status: status ?? this.status,
    );
  }
}
