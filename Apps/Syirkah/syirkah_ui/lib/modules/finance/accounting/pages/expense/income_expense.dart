import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

class IncomeExpenseWidget extends ConsumerWidget {
  const IncomeExpenseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final income = ref.watch(incomeProvider);
    final expense = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                ).then((value) {
                  if (value != null) {
                    ref.read(selectedDateProvider.notifier).state = value;
                  }
                });
              },
              child: const Text('Choose Date'),
            ),
            const SizedBox(height: 16.0),
            Text(
              DateFormat('dd MMM yyyy').format(selectedDate),
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_forward),
                          const SizedBox(height: 16.0),
                          Text(
                            income.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 20.0),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(incomeProvider.notifier).state += 100000;
                            },
                            child: const Text('+ Income'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_back),
                          const SizedBox(height: 16.0),
                          Text(
                            expense.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 20.0),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(expenseProvider.notifier).state +=
                                  100000;
                            },
                            child: const Text('+ Expense'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Total Sales',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              (income - expense).toStringAsFixed(0),
              style: const TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Final Balance',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              (income + expense).toStringAsFixed(0),
              style: const TextStyle(fontSize: 24.0),
            ),
          ],
        ),
      ),
    );
  }
}

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final incomeProvider = StateProvider<double>((ref) => 200000);
final expenseProvider = StateProvider<double>((ref) => 0);
