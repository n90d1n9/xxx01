import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/customize.dart';

class CustomizeForm extends ConsumerWidget {
  final Customize? customize;

  const CustomizeForm({Key? key, this.customize}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Promotion Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: customize?.conditionLogic ?? '',
              decoration: const InputDecoration(
                labelText: 'Custom Logic',
                hintText: 'Enter the condition logic for this promotion',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 6,
              onChanged: (value) {
                // We would update the state here if we had implemented the customize state update method
              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Customize your promotion with specific business rules. This could include:',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            const Text('• Time-based conditions (e.g., happy hours)'),
            const Text('• User behavior triggers'),
            const Text('• Seasonal or event-specific rules'),
            const Text('• Inventory-based conditions'),
          ],
        ),
      ),
    );
  }
}
