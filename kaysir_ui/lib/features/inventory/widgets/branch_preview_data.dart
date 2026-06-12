import 'package:flutter/material.dart';

import '../models/company_branch_governance.dart';
import '../models/inventory_branch.dart';

Widget inventoryBranchPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

InventoryBranch inventoryBranchPreviewBranch({
  InventoryBranchStatus status = InventoryBranchStatus.active,
}) {
  return InventoryBranch(
    id: 'branch-jakarta',
    name: 'Jakarta Central',
    city: 'Jakarta',
    managerName: 'Rina Wijaya',
    contact: 'jakarta.ops@kaysir.local',
    code: 'JKT-HQ',
    region: 'Java West',
    legalEntity: 'PT Kaysir Nusantara',
    type: InventoryBranchType.headquarters,
    complianceTier: InventoryBranchComplianceTier.monitored,
    employeeCount: 52,
    status: status,
    notes: 'Priority fulfillment branch',
  );
}

List<InventoryBranch> inventoryBranchPreviewBranches() {
  return [
    inventoryBranchPreviewBranch(),
    const InventoryBranch(
      id: 'branch-bandung',
      name: 'Bandung Retail',
      city: 'Bandung',
      managerName: 'Maya Lestari',
      contact: 'bandung.ops@kaysir.local',
      code: 'BDG-RT',
      region: 'Java West',
      legalEntity: 'PT Kaysir Retail Indonesia',
      type: InventoryBranchType.retailOutlet,
      complianceTier: InventoryBranchComplianceTier.standard,
      employeeCount: 18,
      status: InventoryBranchStatus.planning,
    ),
  ];
}

Map<String, int> inventoryBranchPreviewWarehouseCounts() {
  return const {'branch-jakarta': 3, 'branch-bandung': 0};
}

CompanyBranchGovernanceSummary inventoryBranchPreviewGovernanceSummary() {
  final branches = inventoryBranchPreviewBranches();
  final warehouseCounts = inventoryBranchPreviewWarehouseCounts();

  return CompanyBranchGovernanceSummary.fromBranches(
    branches: branches,
    warehouseCountByBranchId: warehouseCounts,
  );
}
