import 'package:flutter/material.dart';

import '../models/inventory_branch.dart';
import '../models/warehouse.dart';

Widget inventoryWarehouseFormPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

List<InventoryBranch> inventoryWarehouseFormPreviewBranches() {
  return const [
    InventoryBranch(
      id: 'branch-jakarta',
      name: 'Jakarta Central',
      city: 'Jakarta',
      managerName: 'Rina Wijaya',
      contact: 'jakarta.ops@kaysir.local',
    ),
    InventoryBranch(
      id: 'branch-bandung',
      name: 'Bandung South',
      city: 'Bandung',
      managerName: 'Maya Lestari',
      contact: 'bandung.ops@kaysir.local',
    ),
  ];
}

Warehouse inventoryWarehouseFormPreviewWarehouse() {
  return Warehouse(
    id: 'warehouse-main',
    name: 'Main Fulfillment Hub',
    branchId: 'branch-jakarta',
    branchName: 'Jakarta Central',
    location: 'Jakarta',
    description: 'Primary storage for fast-moving products',
    capacity: 140,
  );
}
