import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/bundling.dart';

class BundlingForm extends ConsumerWidget {
  final Bundling? bundling;

  const BundlingForm({super.key, this.bundling});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bundle Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: bundling?.bundlingPrice.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Bundle Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // We would update the state here if we had implemented the bundling state update method
              },
            ),
            const SizedBox(height: 16),
            const Text('Unit', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Unit selector would go here
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Select Unit'),
              tileColor: Colors.grey[200],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bundle Items',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Bundle items list would go here
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text('Add Product to Bundle'),
              tileColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            // Example of a bundled item (would be in a list in real implementation)
            ListTile(
              title: Text('No items in bundle'),
              subtitle: Text('Add products to create your bundle'),
              tileColor: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }
}
