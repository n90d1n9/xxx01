import 'inventory_branch.dart';

class CompanyBranchGovernanceSummary {
  const CompanyBranchGovernanceSummary({required this.items});

  final List<CompanyBranchGovernanceItem> items;

  int get totalBranches => items.length;

  int get readyCount => items.where((item) => item.isReady).length;

  int get riskCount => items.where((item) => item.hasRisk).length;

  int get employeeCount {
    return items.fold<int>(0, (total, item) => total + item.employeeCount);
  }

  int get legalEntityCount {
    return items
        .map((item) => item.legalEntity)
        .where((entity) => entity != 'No entity')
        .toSet()
        .length;
  }

  int get averageReadiness {
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, item) => sum + item.readinessScore);
    return (total / items.length).round();
  }

  String get nextAction {
    final blocked = items.where((item) => item.isBlocked).toList();
    if (blocked.isNotEmpty) {
      return 'Resolve ${blocked.first.branchName} governance blockers.';
    }

    final risks = items.where((item) => item.hasRisk).toList();
    if (risks.isNotEmpty) {
      return 'Review ${risks.first.branchName} company readiness.';
    }

    return 'Keep company structure records current.';
  }

  factory CompanyBranchGovernanceSummary.fromBranches({
    required List<InventoryBranch> branches,
    required Map<String, int> warehouseCountByBranchId,
  }) {
    return CompanyBranchGovernanceSummary(
      items:
          branches
              .map(
                (branch) => CompanyBranchGovernanceItem.fromBranch(
                  branch: branch,
                  warehouseCount: warehouseCountByBranchId[branch.id] ?? 0,
                ),
              )
              .toList(),
    );
  }
}

class CompanyBranchGovernanceItem {
  const CompanyBranchGovernanceItem({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.city,
    required this.region,
    required this.legalEntity,
    required this.type,
    required this.status,
    required this.complianceTier,
    required this.employeeCount,
    required this.warehouseCount,
    required this.readinessScore,
    required this.issues,
  });

  final String branchId;
  final String branchName;
  final String branchCode;
  final String city;
  final String region;
  final String legalEntity;
  final InventoryBranchType type;
  final InventoryBranchStatus status;
  final InventoryBranchComplianceTier complianceTier;
  final int employeeCount;
  final int warehouseCount;
  final int readinessScore;
  final List<String> issues;

  bool get isReady => readinessScore >= 85 && issues.isEmpty;

  bool get hasRisk => readinessScore < 85 || issues.isNotEmpty;

  bool get isBlocked {
    return complianceTier == InventoryBranchComplianceTier.restricted ||
        issues.any((issue) => issue.startsWith('Missing'));
  }

  String get action {
    if (issues.isNotEmpty) return issues.first;
    return 'Keep company governance pack current.';
  }

  factory CompanyBranchGovernanceItem.fromBranch({
    required InventoryBranch branch,
    required int warehouseCount,
  }) {
    final issues = <String>[];
    var score = 100;

    void flag(String issue, int penalty) {
      issues.add(issue);
      score -= penalty;
    }

    if (branch.code.trim().isEmpty) flag('Missing branch code', 18);
    if (branch.region.trim().isEmpty) flag('Missing region', 18);
    if (branch.legalEntity.trim().isEmpty) flag('Missing legal entity', 18);
    if (branch.managerName.trim().isEmpty) flag('Missing manager owner', 12);
    if (branch.contact.trim().isEmpty) flag('Missing branch contact', 12);
    if (branch.employeeCount <= 0) flag('Add employee headcount', 6);
    if (warehouseCount == 0) flag('Link at least one warehouse', 6);

    switch (branch.status) {
      case InventoryBranchStatus.active:
        break;
      case InventoryBranchStatus.planning:
        flag('Planning branch needs activation review', 6);
      case InventoryBranchStatus.paused:
        flag('Paused branch needs reopening decision', 10);
    }

    switch (branch.complianceTier) {
      case InventoryBranchComplianceTier.standard:
        break;
      case InventoryBranchComplianceTier.monitored:
        flag('Monitored compliance tier needs review', 8);
      case InventoryBranchComplianceTier.restricted:
        flag('Restricted compliance tier blocks expansion', 18);
    }

    return CompanyBranchGovernanceItem(
      branchId: branch.id,
      branchName: branch.nameLabel,
      branchCode: branch.codeLabel,
      city: branch.cityLabel,
      region: branch.regionLabel,
      legalEntity: branch.legalEntityLabel,
      type: branch.type,
      status: branch.status,
      complianceTier: branch.complianceTier,
      employeeCount: branch.employeeCount < 0 ? 0 : branch.employeeCount,
      warehouseCount: warehouseCount,
      readinessScore: score.clamp(0, 100).toInt(),
      issues: issues,
    );
  }
}
