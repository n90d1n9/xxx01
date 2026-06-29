import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Operational',
                  child: Text('Operational'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                // Handle category change
              },
            ),

            // Name
            const TextField(
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),

            // Total Expense
            const TextField(
              decoration: InputDecoration(
                labelText: 'Total Expense',
              ),
              keyboardType: TextInputType.number,
            ),

            // Date
            Row(
              children: [
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final selectedDate = ref.watch(selectedDateProvider);
                      return GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            ref.read(selectedDateProvider.notifier).state =
                                picked;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final selectedTime = ref.watch(selectedTimeProvider);
                      return GestureDetector(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            ref.read(selectedTimeProvider.notifier).state =
                                picked;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            selectedTime.format(context),
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Remarks
            const TextField(
              decoration: InputDecoration(
                labelText: 'Remarks',
              ),
              maxLines: null,
            ),

            const SizedBox(height: 32.0),

            // Process Button
            ElevatedButton(
              onPressed: () {
                // Handle process button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Process',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedTimeProvider = StateProvider<TimeOfDay>((ref) => TimeOfDay.now());
