import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bogo.dart';

class BogoForm extends ConsumerWidget {
  final Bogo? bogo;

  const BogoForm({Key? key, this.bogo}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Since we don't have the full implementation for updating BOGO, we'll create a simple UI
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buy One Get One Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: bogo?.quantity.toString() ?? '1',
              decoration: const InputDecoration(
                labelText: 'Minimum Purchase Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // We would update the state here if we had implemented the BOGO state update method
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Apply to All Variants'),
              value: bogo?.isAllVariant ?? false,
              onChanged: (value) {
                // We would update the state here if we had implemented the BOGO state update method
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Product Selection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Product selector would go here
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Select Product'),
              tileColor: Colors.grey[200],
            ),
            const SizedBox(height: 16),
            const Text(
              'Variant Selections',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Variant list would go here
            ListTile(
              title: Text('No variants selected'),
              subtitle: Text('Select a product to see available variants'),
              tileColor: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }
}
