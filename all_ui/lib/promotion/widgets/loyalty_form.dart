import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty.dart';
import '../models/enums.dart';

class LoyaltyForm extends ConsumerWidget {
  final Loyalty? loyalty;

  const LoyaltyForm({super.key, this.loyalty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLoyalty =
        loyalty ??
        Loyalty(
          value: 0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          type: DiscountType.Value,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loyalty Program Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DiscountType>(
              value: currentLoyalty.type,
              decoration: const InputDecoration(
                labelText: 'Reward Type',
                border: OutlineInputBorder(),
              ),
              items:
                  DiscountType.values.map((type) {
                    return DropdownMenuItem<DiscountType>(
                      value: type,
                      child: Text(
                        type == DiscountType.Value
                            ? 'Fixed Amount'
                            : 'Percentage',
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                // We would update the state here if we had implemented the loyalty state update method
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: currentLoyalty.value.toString(),
              decoration: InputDecoration(
                labelText: 'Reward Value',
                border: OutlineInputBorder(),
                suffix:
                    currentLoyalty.type == DiscountType.Percent
                        ? Text('%')
                        : null,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // We would update the state here if we had implemented the loyalty state update method
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    label: 'Start Date',
                    currentDate: currentLoyalty.startDate,
                    onDateSelected: (date) {
                      // We would update the state here if we had implemented the loyalty state update method
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    context,
                    label: 'End Date',
                    currentDate: currentLoyalty.endDate,
                    onDateSelected: (date) {
                      // We would update the state here if we had implemented the loyalty state update method
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Customer Selection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Customer selector would go here
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Select Customer Group'),
              tileColor: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime currentDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          '${currentDate.day}/${currentDate.month}/${currentDate.year}',
        ),
      ),
    );
  }
}
