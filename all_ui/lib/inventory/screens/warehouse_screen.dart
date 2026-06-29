import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/warehouse.dart';
import '../states/warehouse_provider.dart';

class WarehousePage extends ConsumerWidget {
  const WarehousePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouses = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditWarehouseDialog(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warehouses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows:
                        warehouses.map((warehouse) {
                          return DataRow(
                            cells: [
                              DataCell(Text(warehouse.name)),
                              DataCell(Text(warehouse.location)),
                              DataCell(
                                Text(
                                  warehouse.description != null
                                      ? warehouse.description!
                                      : '',
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () => _showAddEditWarehouseDialog(
                                            context,
                                            ref,
                                            warehouse,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed:
                                          () => _showDeleteConfirmation(
                                            context,
                                            ref,
                                            warehouse,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditWarehouseDialog(
    BuildContext context,
    WidgetRef ref, [
    Warehouse? warehouse,
  ]) {
    final isEditing = warehouse != null;

    final nameController = TextEditingController(text: warehouse?.name ?? '');
    final locationController = TextEditingController(
      text: warehouse?.location ?? '',
    );
    final descriptionController = TextEditingController(
      text: warehouse?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Warehouse' : 'Add Warehouse'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final location = locationController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty || location.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  final updatedWarehouse = Warehouse(
                    id: warehouse.id,
                    name: name,
                    location: location,
                    description: description,
                  );
                  ref
                      .read(warehousesProvider.notifier)
                      .updateWarehouse(updatedWarehouse);
                } else {
                  final newWarehouse = Warehouse(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    location: location,
                    description: description,
                  );
                  ref
                      .read(warehousesProvider.notifier)
                      .addWarehouse(newWarehouse);
                }

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Warehouse warehouse,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Warehouse'),
          content: Text('Are you sure you want to delete ${warehouse.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(warehousesProvider.notifier)
                    .deleteWarehouse(warehouse.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
