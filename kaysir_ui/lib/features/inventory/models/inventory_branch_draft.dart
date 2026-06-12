import 'inventory_branch.dart';

enum InventoryBranchIssue {
  missingName,
  missingCity,
  missingManager,
  missingContact,
  missingCode,
  missingRegion,
  missingLegalEntity,
  invalidEmployeeCount,
}

class InventoryBranchDraft {
  const InventoryBranchDraft({
    required this.name,
    required this.city,
    required this.managerName,
    required this.contact,
    this.code = '',
    this.region = '',
    this.legalEntity = '',
    this.type = InventoryBranchType.branchOffice,
    this.complianceTier = InventoryBranchComplianceTier.standard,
    this.employeeCount = 0,
    this.status = InventoryBranchStatus.active,
    this.notes = '',
  });

  final String name;
  final String city;
  final String managerName;
  final String contact;
  final String code;
  final String region;
  final String legalEntity;
  final InventoryBranchType type;
  final InventoryBranchComplianceTier complianceTier;
  final int employeeCount;
  final InventoryBranchStatus status;
  final String notes;

  factory InventoryBranchDraft.fromBranch(InventoryBranch branch) {
    return InventoryBranchDraft(
      name: branch.name,
      city: branch.city,
      managerName: branch.managerName,
      contact: branch.contact,
      code: branch.code,
      region: branch.region,
      legalEntity: branch.legalEntity,
      type: branch.type,
      complianceTier: branch.complianceTier,
      employeeCount: branch.employeeCount,
      status: branch.status,
      notes: branch.notes ?? '',
    );
  }

  InventoryBranch toBranch({required String id}) {
    return InventoryBranch(
      id: id,
      name: name.trim(),
      city: city.trim(),
      managerName: managerName.trim(),
      contact: contact.trim(),
      code: code.trim(),
      region: region.trim(),
      legalEntity: legalEntity.trim(),
      type: type,
      complianceTier: complianceTier,
      employeeCount: employeeCount < 0 ? 0 : employeeCount,
      status: status,
      notes: _normalizedNotes,
    );
  }

  String? get _normalizedNotes {
    final value = notes.trim();
    return value.isEmpty ? null : value;
  }
}

InventoryBranchIssue? validateInventoryBranchDraft(InventoryBranchDraft draft) {
  if (draft.name.trim().isEmpty) return InventoryBranchIssue.missingName;
  if (draft.city.trim().isEmpty) return InventoryBranchIssue.missingCity;
  if (draft.managerName.trim().isEmpty) {
    return InventoryBranchIssue.missingManager;
  }
  if (draft.contact.trim().isEmpty) return InventoryBranchIssue.missingContact;
  if (draft.code.trim().isEmpty) return InventoryBranchIssue.missingCode;
  if (draft.region.trim().isEmpty) return InventoryBranchIssue.missingRegion;
  if (draft.legalEntity.trim().isEmpty) {
    return InventoryBranchIssue.missingLegalEntity;
  }
  if (draft.employeeCount < 0) {
    return InventoryBranchIssue.invalidEmployeeCount;
  }

  return null;
}

String inventoryBranchIssueLabel(InventoryBranchIssue issue) {
  switch (issue) {
    case InventoryBranchIssue.missingName:
      return 'Enter a branch name.';
    case InventoryBranchIssue.missingCity:
      return 'Enter the branch city.';
    case InventoryBranchIssue.missingManager:
      return 'Enter the branch manager.';
    case InventoryBranchIssue.missingContact:
      return 'Enter a branch contact.';
    case InventoryBranchIssue.missingCode:
      return 'Enter a branch code.';
    case InventoryBranchIssue.missingRegion:
      return 'Enter the company region.';
    case InventoryBranchIssue.missingLegalEntity:
      return 'Enter the legal entity.';
    case InventoryBranchIssue.invalidEmployeeCount:
      return 'Enter 0 or more employees.';
  }
}
