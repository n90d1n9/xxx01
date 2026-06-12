import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_item.dart';
import '../states/inventory_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: inventory.isEmpty
          ? const Center(child: Text('No inventory items yet'))
          : ListView.builder(
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                final item = inventory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Quantity: ${item.quantity} ${item.unit}'),
                        Text('Expiry Date: ${_formatDate(item.expiryDate)}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _showUpdateQuantityDialog(context, ref, item);
                              },
                              child: const Text('Update Quantity'),
                            ),
                            TextButton(
                              onPressed: () {
                                _showEditItemDialog(context, ref, item);
                              },
                              child: const Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () {
                                _confirmDelete(context, ref, item.id);
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final priceController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Inventory Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit (kg, liter, etc.)',
                  ),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expiry Date:'),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                        }
                      },
                      child: Text(_formatDate(selectedDate)),
                    ),
                  ],
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
                if (nameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    unitController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final newItem = InventoryItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    quantity: double.parse(quantityController.text),
                    unit: unitController.text,
                    price: double.parse(priceController.text),
                    expiryDate: selectedDate,
                  );
                  ref.read(inventoryProvider.notifier).addItem(newItem);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
  ) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final unitController = TextEditingController(text: item.unit);
    final priceController = TextEditingController(text: item.price.toString());
    DateTime selectedDate = item.expiryDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Inventory Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit (kg, liter, etc.)',
                  ),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expiry Date:'),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                        }
                      },
                      child: Text(_formatDate(selectedDate)),
                    ),
                  ],
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
                if (nameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    unitController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final updatedItem = InventoryItem(
                    id: item.id,
                    name: nameController.text,
                    quantity: double.parse(quantityController.text),
                    unit: unitController.text,
                    price: double.parse(priceController.text),
                    expiryDate: selectedDate,
                  );
                  ref.read(inventoryProvider.notifier).updateItem(updatedItem);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateQuantityDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
  ) {
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Quantity'),
          content: TextField(
            controller: quantityController,
            decoration: InputDecoration(labelText: 'Quantity (${item.unit})'),
            keyboardType: TextInputType.number,
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
                if (quantityController.text.isNotEmpty) {
                  ref
                      .read(inventoryProvider.notifier)
                      .updateQuantity(
                        item.id,
                        double.parse(quantityController.text),
                      );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(inventoryProvider.notifier).deleteItem(id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
