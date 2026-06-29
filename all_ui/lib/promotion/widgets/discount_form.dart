import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/discount.dart';
import '../models/enums.dart';
import '../states/promotion_provider.dart';

class DiscountForm extends ConsumerWidget {
  final Discount? discount;

  const DiscountForm({Key? key, this.discount}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDiscount =
        discount ??
        Discount(
          id: 0,
          name: '',
          type: DiscountType.Value,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          value: 0,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discount Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: currentDiscount.name,
              decoration: const InputDecoration(
                labelText: 'Discount Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                } else if (value.length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(promotionFormProvider.notifier)
                    .updateDiscount(name: value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DiscountType>(
              value: currentDiscount.type,
              decoration: const InputDecoration(
                labelText: 'Discount Type',
                border: OutlineInputBorder(),
              ),
              items:
                  DiscountType.values.map((type) {
                    return DropdownMenuItem<DiscountType>(
                      value: type,
                      child: Text(_getDiscountTypeLabel(type)),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(promotionFormProvider.notifier)
                      .updateDiscount(type: value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: currentDiscount.value.toString(),
              decoration: InputDecoration(
                labelText: 'Discount Value',
                border: OutlineInputBorder(),
                suffix:
                    currentDiscount.type == DiscountType.Percent
                        ? Text('%')
                        : null,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  ref
                      .read(promotionFormProvider.notifier)
                      .updateDiscount(value: double.tryParse(value) ?? 0.0);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    ref,
                    label: 'Start Date',
                    currentDate: currentDiscount.startDate,
                    onDateSelected: (date) {
                      ref
                          .read(promotionFormProvider.notifier)
                          .updateDiscount(startDate: date);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    context,
                    ref,
                    label: 'End Date',
                    currentDate: currentDiscount.endDate,
                    onDateSelected: (date) {
                      ref
                          .read(promotionFormProvider.notifier)
                          .updateDiscount(endDate: date);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: currentDiscount.description ?? '',
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
              onChanged: (value) {
                ref
                    .read(promotionFormProvider.notifier)
                    .updateDiscount(description: value.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    WidgetRef ref, {
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

  String _getDiscountTypeLabel(DiscountType type) {
    switch (type) {
      case DiscountType.Value:
        return 'Fixed Amount';
      case DiscountType.Percent:
        return 'Percentage';
      default:
        return type.toString().split('.').last;
    }
  }
}
