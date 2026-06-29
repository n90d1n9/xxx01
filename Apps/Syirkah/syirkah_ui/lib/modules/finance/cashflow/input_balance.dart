import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final initialBalanceProvider = StateProvider<int>((ref) => 0);

class InitialBalanceScreen extends ConsumerWidget {
  const InitialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialBalance = ref.watch(initialBalanceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
              ),
              onChanged: (value) {
                ref.read(initialBalanceProvider.notifier).state =
                    int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save the initial balance
                // ...
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 16.0),
            Visibility(
              visible: initialBalance == 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Income & Expense feature needs initial balance to calculate correctly.\nPlease input initial balance to start calculation.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
