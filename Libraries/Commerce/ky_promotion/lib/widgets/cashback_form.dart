import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/cashback.dart';

class CashbackForm extends ConsumerWidget {
  final Cashback? cashback;

  const CashbackForm({super.key, this.cashback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cashback Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: cashback?.amount.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Cashback Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // We would update the state here if we had implemented the cashback state update method
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: cashback?.minPurchase.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Minimum Purchase Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // We would update the state here if we had implemented the cashback state update method
              },
            ),
          ],
        ),
      ),
    );
  }
}
