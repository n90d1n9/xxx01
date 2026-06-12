import 'package:flutter/material.dart';

import '../models/warehouse.dart';

Widget inventoryWarehouseDirectoryPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

Warehouse inventoryWarehouseDirectoryPreviewWarehouse({
  bool capacityTracked = true,
}) {
  return Warehouse(
    id: 'warehouse-main',
    name: 'Main Fulfillment Hub',
    branchId: 'central',
    branchName: 'Central Branch',
    location: 'Jakarta',
    description: 'Primary storage for fast-moving products',
    capacity: capacityTracked ? 140 : null,
  );
}

List<Warehouse> inventoryWarehouseDirectoryPreviewWarehouses() {
  return [
    inventoryWarehouseDirectoryPreviewWarehouse(),
    Warehouse(
      id: 'warehouse-north',
      name: 'North Warehouse',
      branchId: 'north',
      branchName: 'North Branch',
      location: 'Surabaya',
      description: 'Overflow storage for slower-moving inventory',
    ),
  ];
}
