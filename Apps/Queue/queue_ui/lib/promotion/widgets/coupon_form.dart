import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coupon.dart';
import '../models/enums.dart';
import '../states/promotion_provider.dart';

class CouponForm extends ConsumerWidget {
  final Coupons? coupon;

  const CouponForm({super.key, this.coupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCoupon =
        coupon ??
        Coupons(
          code: '',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          value: 0,
          type: DiscountType.Value,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coupon Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: currentCoupon.code,
              decoration: const InputDecoration(
                labelText: 'Coupon Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a code';
                } else if (value.length < 3) {
                  return 'Code must be at least 3 characters';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(promotionFormProvider.notifier)
                    .updateCoupon(code: value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DiscountType>(
              value: currentCoupon.type,
              decoration: const InputDecoration(
                labelText: 'Coupon Type',
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
                if (value != null) {
                  ref
                      .read(promotionFormProvider.notifier)
                      .updateCoupon(type: value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: currentCoupon.value.toString(),
              decoration: InputDecoration(
                labelText: 'Coupon Value',
                border: OutlineInputBorder(),
                suffix:
                    currentCoupon.type == DiscountType.Percent
                        ? Text('%')
                        : null,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  ref
                      .read(promotionFormProvider.notifier)
                      .updateCoupon(value: double.tryParse(value) ?? 0.0);
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
                    currentDate: currentCoupon.startDate,
                    onDateSelected: (date) {
                      ref
                          .read(promotionFormProvider.notifier)
                          .updateCoupon(startDate: date);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    context,
                    ref,
                    label: 'End Date',
                    currentDate: currentCoupon.endDate,
                    onDateSelected: (date) {
                      ref
                          .read(promotionFormProvider.notifier)
                          .updateCoupon(endDate: date);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: currentCoupon.description ?? '',
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
              onChanged: (value) {
                ref
                    .read(promotionFormProvider.notifier)
                    .updateCoupon(description: value.isEmpty ? null : value);
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
}
