import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_branch.dart';

const inventoryBranchJakartaCentralId = 'branch-jakarta-central';
const inventoryBranchSurabayaNorthId = 'branch-surabaya-north';
const inventoryBranchBandungSouthId = 'branch-bandung-south';

final inventoryBranchesProvider =
    StateNotifierProvider<InventoryBranchesNotifier, List<InventoryBranch>>((
      ref,
    ) {
      return InventoryBranchesNotifier();
    });

class InventoryBranchesNotifier extends StateNotifier<List<InventoryBranch>> {
  InventoryBranchesNotifier()
    : super(const [
        InventoryBranch(
          id: inventoryBranchJakartaCentralId,
          name: 'Jakarta Central',
          city: 'Jakarta',
          managerName: 'Rina Wijaya',
          contact: 'jakarta.ops@kaysir.local',
          code: 'JKT-HQ',
          region: 'Java West',
          legalEntity: 'PT Kaysir Nusantara',
          type: InventoryBranchType.headquarters,
          employeeCount: 52,
          notes: 'Primary branch for central replenishment.',
        ),
        InventoryBranch(
          id: inventoryBranchSurabayaNorthId,
          name: 'Surabaya North',
          city: 'Surabaya',
          managerName: 'Agus Pratama',
          contact: 'surabaya.ops@kaysir.local',
          code: 'SUB-NR',
          region: 'Java East',
          legalEntity: 'PT Kaysir Nusantara',
          type: InventoryBranchType.fulfillmentHub,
          complianceTier: InventoryBranchComplianceTier.monitored,
          employeeCount: 34,
          notes: 'Regional branch for north-east distribution.',
        ),
        InventoryBranch(
          id: inventoryBranchBandungSouthId,
          name: 'Bandung South',
          city: 'Bandung',
          managerName: 'Maya Lestari',
          contact: 'bandung.ops@kaysir.local',
          code: 'BDG-ST',
          region: 'Java West',
          legalEntity: 'PT Kaysir Retail Indonesia',
          type: InventoryBranchType.retailOutlet,
          employeeCount: 18,
          status: InventoryBranchStatus.planning,
          notes: 'Capacity expansion branch.',
        ),
      ]);

  void addBranch(InventoryBranch branch) {
    state = [...state, branch];
  }

  void updateBranch(InventoryBranch branch) {
    state =
        state
            .map((existing) => existing.id == branch.id ? branch : existing)
            .toList();
  }

  void deleteBranch(String id) {
    state = state.where((branch) => branch.id != id).toList();
  }
}
